# Architecture

## Vue d'ensemble

FitnessPro est composé de deux applications indépendantes qui communiquent via une API REST :

```
┌─────────────────┐         HTTPS/JSON          ┌──────────────────┐
│   Mobile Flutter  │ ───────────────────────────▶│  Backend Laravel  │
│   (Provider MVVM) │◀─────────────────────────── │  (REST + Sanctum)  │
└─────────────────┘                              └──────────────────┘
        │                                                  │
        │                                                  ▼
        │                                          ┌──────────────┐
        │                                          │  PostgreSQL   │
        │                                          └──────────────┘
        ▼
┌─────────────────┐
│   RevenueCat      │  (SDK direct + webhook vers le backend)
│   YouTube Player  │  (SDK direct, pas de trafic backend)
│   Passio.ai (mock) │  (prévu : SDK direct, pas de trafic backend)
└─────────────────┘
```

Point clé : les SDK tiers (RevenueCat, Passio.ai) parlent **directement** au mobile, pas via le backend Laravel. Le backend n'intervient que pour :
- l'authentification et les données métier (exercices, programmes, séances, repas)
- recevoir le **webhook** RevenueCat pour synchroniser le statut d'abonnement en base

## Backend — Controller → Service → Model

Chaque endpoint suit strictement ce flux :

1. **Route** (`routes/api.php`) → **Controller** (validation déléguée à un Form Request)
2. **Controller** → **Service** (logique métier, transactions, orchestration)
3. **Service** → **Model** (Eloquent, accès données)
4. Réponse formatée via `App\Http\Responses\ApiResponse::success()/error()`

Exemple concret (`POST /api/programs`) :

```
StoreProgramRequest (validation + policy 'create')
  → ProgramController::store()
    → ProgramService::create()
      → DB::transaction { Program::create() + syncExercises() }
  → ApiResponse::success($program, ..., 201)
```

Les autorisations passent par des **Policies** (`app/Policies/`), jamais par des `if` ad-hoc dans les controllers.

## Mobile — Provider par domaine

Pas de ViewModel par écran : un **Provider** par domaine métier, injecté globalement via `MultiProvider` dans `lib/main.dart`, consommé par les écrans qui en ont besoin.

| Provider | Domaine |
|---|---|
| `AuthProvider` | Session utilisateur (register/login/logout/restoreSession) |
| `SubscriptionProvider` | Wrapper RevenueCat (isPro, purchase, restore, login/logout) |
| `ThemeProvider` | Mode clair/sombre |
| `ExerciseProvider`, `ProgramProvider`, `WorkoutSessionProvider`, `MealProvider` | Données métier, un appel API = une méthode |

### Couleurs et thème

Les couleurs ne sont **jamais** lues directement depuis les constantes statiques `FPColors.*` dans un écran — c'est le piège classique qui casse le mode clair/sombre. Le point d'accès correct est `FPColorScheme.of(context)`, une `ThemeExtension` qui résout la bonne palette selon le `ThemeMode` actif. Voir `lib/core/constants/colors.dart` et `lib/core/theme/app_theme.dart`.

## Authentification & synchronisation RevenueCat

Le point le plus subtil du système : **l'ID utilisateur RevenueCat doit être identique à l'ID utilisateur Laravel**, sans quoi le webhook ne peut pas relier un achat à un compte.

```
Mobile: register()/login() réussit
  → SubscriptionProvider.login(user.id.toString())   [RevenueCat.logIn]
  → RevenueCat associe désormais cet appareil à l'app_user_id = ID Laravel

...plus tard, achat effectué...

RevenueCat → POST /api/subscriptions/webhook (secret partagé, pas Sanctum)
  → SubscriptionService::handleRevenueCatEvent()
    → User::find($event['app_user_id'])   ← doit correspondre à l'ID Laravel
    → Subscription::updateOrCreate(...)
```

Si cette correspondance casse (ex: connexion sans appel à `SubscriptionProvider.login`), les achats ne se rattachent à aucun compte côté backend.

## Gating de l'abonnement

Conforme au plan d'implémentation ("gate d'accès aux fonctionnalités si abonnement inactif") et à ce que montre le design : **une seule porte à l'entrée de l'app**, pas de verrouillage fonctionnalité par fonctionnalité.

- Nouvel utilisateur : Signup → Paywall → Quiz → Onboarding → Dashboard
- Utilisateur qui revient sans abonnement actif (jamais souscrit après l'essai, ou expiré) : repasse par `/paywall-recheck` à chaque lancement, avec toujours l'échappatoire "Continuer sans abonnement"
- Utilisateur avec abonnement actif : accès direct au Dashboard

Voir `resolveInitialRoute()` dans `mobile/lib/main.dart`.

## CI/CD

Deux pipelines GitHub Actions indépendants (`.github/workflows/`) :
- `lint-test-backend.yml` : Pint (lint) + Pest (tests) + couverture pcov ≥ 70 %
- `lint-test-mobile.yml` : `flutter analyze` + `flutter test`

Déploiement backend prévu sur Render (push `main` → migrations auto).
