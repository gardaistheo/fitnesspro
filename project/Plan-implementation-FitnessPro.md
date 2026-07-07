# Plan d'implémentation — FitnessPro
Backend Laravel + PostgreSQL / Mobile Flutter · Référence design : `FitnessPro.html`

## Phase 0 — Setup environnements & CI/CD
- Init repo GitHub, branches `main` / `develop` / `feature/*`
- Backend Laravel : Docker (ou Sail/Herd), PostgreSQL local
- Mobile Flutter : projet Flutter (Android + iOS targets)
- GitHub Actions : pipeline lint (Pint, PHPStan/Larastan, flutter analyze) + tests (Pest, flutter_test) + coverage (seuil 70%)
- 3 environnements : Local / Staging / Production (Render pour le backend)

## Phase 1 — Backend Laravel (API)
1. **Modèle de données** (migrations Eloquent) : `User`, `Subscription`, `Exercise`, `Program`, `WorkoutSession`, `Meal`
2. **Auth** : Laravel Sanctum (tokens), endpoints register/login/logout
3. **Architecture** : Controller → Service → Model, validation via Form Requests
4. **Endpoints REST** :
   - `/auth/*` (inscription, connexion)
   - `/exercises` (catalogue + filtres catégorie/difficulté)
   - `/programs` (bibliothèque de séances + détail)
   - `/workout-sessions` (planning : CRUD séances planifiées, historique)
   - `/meals` (historique repas — reçoit les résultats du SDK Passio côté app, pas les photos)
   - `/subscriptions/webhook` (webhook RevenueCat → mise à jour statut abonnement)
5. **Doc API** : Swagger/OpenAPI généré, exposé via Swagger UI
6. **Tests** : Pest (unitaires + feature) sur chaque endpoint

## Phase 2 — Mobile Flutter
1. **Architecture** : Provider + ChangeNotifier (MVVM) — 1 ViewModel par écran
2. **Écrans** (recréer depuis `FitnessPro.html`, adapter au thème clair/sombre déjà prototypé) :
   - Landing / Signup (paiement délégué à RevenueCat, pas de saisie carte manuelle)
   - Quiz onboarding (7 étapes adaptatives)
   - Onboarding slides
   - Dashboard (streak, hydratation, calories, prochaine séance)
   - Coach IA (chat — si conservé, connecter à un vrai backend IA ou retirer du périmètre confirmé)
   - Scanner alimentaire → intégration **SDK Passio.ai natif** (appels réseau propres au SDK, hors API Laravel) ; résultat (calories/macros) envoyé à `/meals`
   - Bibliothèque exercices (+ lecteur vidéo YouTube intégré)
   - Bibliothèque séances / programmes
   - Planning
3. **Abonnement** : intégration RevenueCat SDK, gate d'accès aux fonctionnalités si abonnement inactif
4. **Thème clair/sombre** : `ThemeMode` Flutter piloté par préférence système + toggle manuel (persist local)
5. **Tests** : flutter_test + mocktail sur ViewModels et widgets clés

## Phase 3 — Intégrations tierces
- RevenueCat : SDK mobile + webhook Laravel pour synchroniser l'état d'abonnement en base
- Passio.ai : SDK Flutter, flux caméra → résultat nutritionnel (vérifier RGPD/localisation des données)
- Vidéos YouTube : lecteur intégré (`youtube_player_flutter` ou équivalent) dans les fiches exercices

## Phase 4 — Recette & qualité
- Cahier de recettes manuel rejoué sur staging avant chaque prod
- Bugs trackés sur GitHub Issues (labels sévérité, lien PR), cycle Ouvert→...→Fermé
- Chaque correctif de bug accompagné d'un test de non-régression (Pest ou flutter_test) sur branche `fix/*`

## Phase 5 — Documentation
- README + dossier `/docs` versionnés (Markdown)
- Swagger/OpenAPI pour l'API
- Diagramme MLD (optionnel) pour le modèle de données

## Points à trancher avant/pendant l'implémentation
- Écran Coach IA : à confirmer si dans le périmètre (absent du tableau fonctionnalités du Bloc 2) — sinon le retirer du prototype de référence
- Distribution mobile : test interne stores vs Codemagic/Fastlane
- Accessibilité : non traitée — prévoir un plan d'action minimal (contrastes, tailles de police, labels)
- RGPD : qualifier la sensibilité des données repas/corporelles avec un juriste avant mise en prod

---

## Prompt à donner à Claude Code

```
Je démarre l'implémentation de FitnessPro, une app de musculation avec IA.

STACK IMPOSÉE :
- Mobile : Flutter/Dart, architecture Provider + ChangeNotifier (MVVM)
- Backend : PHP/Laravel (Controller → Service → Model), API REST
- Base de données : PostgreSQL
- Auth : Laravel Sanctum (tokens)
- Validation : Form Requests Laravel
- Abonnement : RevenueCat (SDK mobile + webhook Laravel côté API)
- Analyse repas par photo : SDK Passio.ai intégré côté Flutter (appels réseau propres au SDK, ne passe pas par mon API)
- Vidéos d'exercices : lecteur YouTube intégré
- Tests : Pest (backend), flutter_test + mocktail (mobile)
- CI/CD : GitHub Actions (lint + tests + coverage ≥ 70%), repo Git avec branches main/develop/feature
- Hébergement backend : Render
- Doc API : Swagger/OpenAPI

RÉFÉRENCE DESIGN :
Un prototype HTML/React haute-fidélité est fourni (FitnessPro.html + README.md dans le dossier design_handoff_fitnesspro/). Utilise-le comme référence EXACTE pour :
- les écrans et leur contenu (Landing, Signup, Quiz 7 étapes, Onboarding, Dashboard, Scanner alimentaire, Bibliothèque exercices, Bibliothèque séances, Planning)
- le thème clair ET sombre (les deux existent déjà dans le prototype — recrée les deux dans Flutter via ThemeData)
- les couleurs, typographie, espacements, micro-interactions décrits dans le README

Ne recopie pas le HTML tel quel — recrée l'UI nativement en Flutter en respectant fidèlement le rendu visuel et les interactions.

TÂCHE :
1. Initialise la structure du projet (repo Git, dossiers backend Laravel + mobile Flutter, CI GitHub Actions)
2. Mets en place le modèle de données PostgreSQL (User, Subscription, Exercise, Program, WorkoutSession, Meal) + migrations Laravel
3. Implémente l'API Laravel (Sanctum, Form Requests, Controller/Service/Model, endpoints listés) avec tests Pest
4. Implémente l'app Flutter écran par écran en suivant le design de référence, architecture Provider/MVVM
5. Intègre RevenueCat (SDK + webhook) et Passio.ai (SDK caméra)
6. Ajoute les tests flutter_test/mocktail sur les ViewModels clés
7. Documente (README + /docs + Swagger)

Commence par l'initialisation du repo et le modèle de données backend, puis avance phase par phase. Demande-moi confirmation avant de démarrer une nouvelle phase majeure.
```
