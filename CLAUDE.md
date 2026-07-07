# CLAUDE.md — FitnessPro Implementation Guide

## Project Overview

FitnessPro est une app mobile complète de musculation avec IA, composée d'un backend Laravel REST API et d'une app Flutter native.

**Référence design** : `project/design_handoff_fitnesspro/FitnessPro.html` + README design

## Stack & Conventions

### Backend (Laravel)
- **Architecture** : Controller → Service → Model (clean separation)
- **Migrations** : Eloquent, 1 migration = 1 concept
- **Tests** : Pest, feature tests pour chaque endpoint, 70% coverage minimum
- **Validation** : Form Requests (jamais dans le controller)
- **Auth** : Laravel Sanctum token-based
- **API Response** : JSON avec structure `{data, status, message, errors}`
- **Errors** : middleware custom pour gérer les exceptions

### Mobile (Flutter)
- **Architecture** : Provider + ChangeNotifier (1 ViewModel = 1 écran)
- **Naming** : `FooViewModel` pour l'état, `FooScreen` pour l'UI
- **State Management** : Changé via notifyListeners() après opérations
- **Tests** : mocktail pour les services, flutter_test pour les widgets
- **Theming** : ThemeData light + dark via `ThemeMode.system`
- **Navigation** : Named routes avec `MaterialPageRoute` (pas Riverpod/GetX)
- **APIs** : Classe `ApiService` centralisée pour tout appel réseau

### Shared Standards
- **Git branching** : main / develop / feature/* / fix/*
- **Commits** : Atomic, avec préfixe (feat:, fix:, refactor:, test:, docs:)
- **PR reviews** : Minimum 1 approval avant merge
- **CI/CD** : GitHub Actions pour lint + test + coverage check

## Key Design Decisions

### Why Provider?
- Lightweight, officiel Flutter, facile à tester avec mocktail
- Pas d'ajout de dépendance heavyweight (Riverpod, GetX)
- État prévisible avec ChangeNotifier

### Why Pest (not PHPUnit)?
- Syntaxe plus claire et expressive
- Mieux intégré avec Laravel
- Test doubles et expectations plus lisibles

### Why Sanctum (not JWT)?
- Officiellement supporté par Laravel
- Gestion token native
- Revocation facile

### Why Flutter, not React Native?
- Performance native supérieure
- Single codebase iOS + Android
- Theming builtin plus robuste

## Phases d'Implémentation

1. **Phase 0** : Init repo, branches, CI/CD
2. **Phase 1** : Modèle de données Laravel + migrations
3. **Phase 2** : API endpoints (Auth, Exercises, Programs, etc.)
4. **Phase 3** : Tests Pest pour l'API
5. **Phase 4** : Écrans Flutter (landing → dashboard)
6. **Phase 5** : Intégrations tierces (RevenueCat, Passio)
7. **Phase 6** : Tests Flutter
8. **Phase 7** : Documentation complète

## Design Reference Rules

**IMPORTANT** : Lire `project/design_handoff_fitnesspro/README.md` pour :
- Typo, couleurs (light + dark modes)
- Espacements, alignements, dimensions
- Micro-interactions (hover, focus, transitions)
- Tailles de police et styles

Ne pas copier le HTML tel quel — recrée nativement en Flutter.

## Testing Strategy

### Backend (Pest)
```php
// Feature tests pour chaque endpoint
test('POST /auth/register crée un utilisateur et retourne un token')
test('GET /exercises filtre par catégorie et difficulté')
// Unit tests pour Services/Models si logique complexe
```

### Mobile (flutter_test + mocktail)
```dart
// Widget tests pour écrans principaux
testWidgets('DashboardScreen affiche le prochain workout')
// ViewModel tests avec mocks API
test('ExerciseViewModel charge les exercices')
```

### Coverage Goals
- Backend : 70% minimum (phased)
- Mobile : Tests des ViewModels + écrans critiques

## Performance & Security

### Backend
- Pagination des listes (50 items par défaut)
- Rate limiting sur login/register
- Validation stricte des inputs (Form Requests)
- HTTPS obligatoire en prod

### Mobile
- Images optimisées (compression côté backend)
- Cache local des listes (SQFLite si besoin)
- Tokens stockés dans FlutterSecureStorage
- Pas de logs sensibles en prod

## Deployment

### Backend (Render)
- GitHub push → Render auto-deploy
- Migrations auto sur deploy
- Env vars gérées via Render dashboard

### Mobile
- Codemagic ou Play Store / TestFlight (TBD avec user)
- Versioning sémantique (MAJOR.MINOR.PATCH)

## Points Ouverts (à trancher avec user)

- [ ] Coach IA : confirmer si dans le scope (pas dans Bloc 2)
- [ ] Distribution mobile : Codemagic vs Fastlane vs stores
- [ ] Accessibilité : plan d'action minimal
- [ ] RGPD : data classification avant prod

## Conventions de Nommage

- Laravel models : PascalCase singulier (User, Exercise, WorkoutSession)
- DB tables : snake_case pluriel (users, exercises, workout_sessions)
- API routes : kebab-case (POST /auth/register, GET /workout-sessions)
- Flutter classes : PascalCase (ExerciseViewModel, DashboardScreen)
- Variables : camelCase (currentUser, isLoading)

## Workflow Quotidien

1. Créer une branche : `git checkout -b feature/my-feature`
2. Coder et tester localement
3. Pusher et créer une PR vers `develop`
4. Attendre CI (lint + tests)
5. Code review + merge
6. Vérifier staging (Render pour backend)
7. Merger `develop` → `main` pour une release

## Contacts & Ressources

- **Design** : `project/design_handoff_fitnesspro/`
- **Plan** : `project/Plan-implementation-FitnessPro.md`
- **API Docs** : Sera générée via Swagger
- **Documentation** : `/docs` folder

---

Last updated : 2026-07-07
