# FitnessPro

Une application mobile de musculation et nutrition avec intelligence artificielle, couplée d'un backend API REST.

## Stack technique

### Backend
- **Framework** : Laravel (PHP 8+)
- **Auth** : Laravel Sanctum (tokens)
- **DB** : PostgreSQL
- **Architecture** : Controller → Service → Model
- **Validation** : Form Requests
- **Tests** : Pest
- **Docs API** : Swagger/OpenAPI

### Mobile
- **Framework** : Flutter (Dart 3+)
- **State Management** : Provider + ChangeNotifier (MVVM)
- **Tests** : flutter_test + mocktail
- **Thème** : Mode clair/sombre dynamique

### Infrastructure & Intégrations
- **CI/CD** : GitHub Actions (lint + tests + coverage ≥ 70%)
- **Hébergement backend** : Render
- **Abonnement** : RevenueCat (SDK mobile + webhook)
- **Analyse nutritionnelle** : Passio.ai SDK (Flutter)
- **Vidéos exercices** : YouTube Player intégré

## Structure du projet

```
fitnesspro/
├── backend/                  # API Laravel
│   ├── app/
│   ├── database/
│   ├── routes/
│   ├── tests/
│   └── README.md
├── mobile/                   # App Flutter
│   ├── lib/
│   │   ├── screens/
│   │   ├── viewmodels/
│   │   ├── models/
│   │   ├── services/
│   │   └── theme/
│   ├── test/
│   └── README.md
├── docs/                     # Documentation
├── .github/
│   └── workflows/            # GitHub Actions pipelines
└── project/
    └── design_handoff_fitnesspro/  # Référence design (HTML prototypes)
```

## Phases d'implémentation

- **Phase 0** : Setup environnements & CI/CD
- **Phase 1** : Backend Laravel (API REST)
- **Phase 2** : Mobile Flutter (écrans)
- **Phase 3** : Intégrations tierces
- **Phase 4** : Recette & qualité
- **Phase 5** : Documentation complète

Voir `project/Plan-implementation-FitnessPro.md` pour le plan détaillé.

## Git Workflow

- `main` : production stable (releases)
- `develop` : intégration continue
- `feature/*` : nouvelles fonctionnalités
- `fix/*` : corrections de bugs

Les PRs doivent passer les checks CI (lint + tests + coverage).
