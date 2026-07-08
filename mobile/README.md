# FitnessPro — Mobile

Application Flutter pour FitnessPro (musculation + nutrition avec IA).

Pour une vue d'ensemble du projet (mobile + backend), voir le [README racine](../README.md).

## Stack

- **Framework** : Flutter / Dart 3+
- **State management** : Provider + ChangeNotifier (1 Provider par domaine, pas de ViewModel séparé par écran)
- **Navigation** : routes nommées (`Navigator.pushNamed`), pas de package de routing tiers
- **Thème** : clair/sombre via `ThemeMode.system` + toggle manuel persistant (`FPColorScheme`, `ThemeExtension`)
- **Tests** : `flutter_test` + `mocktail`
- **Abonnement** : RevenueCat (`purchases_flutter` + `purchases_ui_flutter`)
- **Vidéo** : `youtube_player_flutter`

## Démarrage rapide

```bash
flutter pub get
flutter run
```

L'app pointe par défaut sur le backend local (`http://localhost:8000` via `ApiService`) — démarrer le backend en premier (voir [backend/README.md](../backend/README.md)).

### Comptes de test

Voir les seeders backend : `test@fitnesspro.local` / `password` (utilisateur standard).

### Clé RevenueCat

La clé API RevenueCat par défaut (sandbox) est codée dans `lib/core/config/revenuecat_config.dart` via `String.fromEnvironment`. Pour une build staging/prod avec une vraie clé :

```bash
flutter build apk --dart-define=REVENUECAT_API_KEY=<clé_réelle>
```

Ne jamais committer une clé de production en dur dans ce fichier.

## Tests

```bash
flutter test
flutter analyze
```

110 tests au moment de la rédaction (providers, écrans, flux d'intégration complets). Certains tests mockent les méthode channels natifs RevenueCat directement (`test/support/revenuecat_test_mocks.dart`) plutôt que de doubler `SubscriptionProvider`, pour exercer le vrai code de bout en bout.

## Structure

```
lib/
├── core/
│   ├── config/       # RevenueCatConfig
│   ├── constants/     # FPColors, FPColorScheme (thème)
│   └── theme/          # AppTheme (ThemeData clair/sombre)
├── models/            # User, Exercise, Program, WorkoutSession, Meal, QuizData...
├── providers/          # 1 provider par domaine (Auth, Exercise, Program, Meal,
│                        #   WorkoutSession, Subscription, Theme)
├── screens/            # 1 dossier par écran/flux
│   ├── landing/, signup/, login/, quiz/, onboarding/, paywall/
│   ├── main/           # Shell de navigation par onglets (bottom nav)
│   ├── dashboard/, coach/, food_scanner/, exercises/, workouts/, planning/
├── services/           # ApiService (HTTP), StorageService (SharedPreferences)
└── widgets/            # Composants partagés (BackHeader, TagChip, DiffChip...)
```

## Écrans et flux

| Écran | Route | Notes |
|---|---|---|
| Landing | `/` | CTA inscription + lien connexion |
| Signup | `/signup` | Création de compte (paiement délégué à RevenueCat, pas de saisie carte) |
| Login | `/login` | Connexion pour utilisateur existant |
| Paywall | `/paywall`, `/paywall-recheck` | Paywall natif RevenueCat ; re-présenté à chaque lancement si l'abonnement n'est pas actif |
| Quiz | `/quiz` | Onboarding adaptatif en 6 ou 7 étapes selon le lieu d'entraînement choisi |
| Onboarding slides | (poussé depuis Quiz) | 4 slides post-quiz, skippables |
| Dashboard | `/dashboard` | Shell principal avec bottom nav (Dashboard, Coach IA, Scanner, Exercices, Séances) |
| Coach IA | (onglet) | Placeholder "Bientôt disponible" — scope non confirmé, voir le plan d'implémentation |
| Scanner alimentaire | `/food-scanner` | **Mock** — l'intégration Passio.ai réelle est bloquée faute de clé API |
| Bibliothèque exercices | `/exercises` | Liste filtrable + détail avec lecteur YouTube intégré |
| Bibliothèque séances | `/workouts` | Liste filtrable + ajout au planning |
| Planning | `/planning` | Séances planifiées groupées par date |

## Points d'attention / dette connue

- **Scanner alimentaire (Passio.ai)** : reste un mock (résultat de reconnaissance simulé). Passer au SDK réel nécessite une clé API Passio, pas encore disponible.
- **Coach IA** : simple placeholder, le périmètre exact n'est pas confirmé (absent du tableau de fonctionnalités initial).
- **Accessibilité** : pas de plan d'action formalisé (contrastes, tailles de police, labels).

## Conventions

- **Classes** : `FooProvider` pour l'état, `FooScreen` pour l'UI
- **Théming** : toujours lire les couleurs via `FPColorScheme.of(context)`, jamais les constantes `FPColors.*` statiques directement dans un écran (celles-ci ne suivent pas le mode clair/sombre)
- **Navigation** : routes nommées déclarées dans `lib/main.dart`
