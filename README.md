# FitnessPro

Une application mobile de musculation et nutrition avec intelligence artificielle, couplée d'un backend API REST.

## Stack technique

### Backend
- **Framework** : Laravel 13 (PHP 8.3+)
- **Auth** : Laravel Sanctum (tokens)
- **DB** : PostgreSQL
- **Architecture** : Controller → Service → Model
- **Validation** : Form Requests
- **Tests** : Pest (87 tests / 191 assertions)
- **Docs API** : Swagger/OpenAPI

### Mobile
- **Framework** : Flutter (Dart 3+)
- **State Management** : Provider + ChangeNotifier
- **Tests** : flutter_test + mocktail (110 tests)
- **Thème** : Mode clair/sombre dynamique (système + toggle manuel persistant)

### Infrastructure & Intégrations
- **CI/CD** : GitHub Actions (lint + tests + coverage ≥ 70%)
- **Hébergement backend** : Render
- **Abonnement** : RevenueCat (SDK mobile + webhook + gating à l'entrée de l'app)
- **Analyse nutritionnelle** : Passio.ai — **mock actuellement**, l'intégration réelle est bloquée faute de clé API
- **Vidéos exercices** : YouTube Player intégré (branché, fonctionnel)

## Structure du projet

```
fitnesspro/
├── backend/                  # API Laravel — voir backend/README.md
│   ├── app/
│   │   ├── Http/Controllers, Requests, Responses/
│   │   ├── Models/
│   │   ├── Policies/
│   │   └── Services/
│   ├── database/migrations, seeders/
│   ├── routes/api.php
│   └── tests/
├── mobile/                   # App Flutter — voir mobile/README.md
│   ├── lib/
│   │   ├── core/            # config, constants (thème), theme
│   │   ├── models/
│   │   ├── providers/       # 1 provider par domaine (pas de dossier viewmodels/)
│   │   ├── screens/         # 1 dossier par écran/flux
│   │   ├── services/
│   │   └── widgets/
│   └── test/
├── docs/                     # Documentation complémentaire
├── .github/workflows/        # CI (lint-test-backend.yml, lint-test-mobile.yml)
└── project/
    ├── Plan-implementation-FitnessPro.md
    └── design_handoff_fitnesspro/  # Référence design (HTML prototypes)
```

## État d'avancement

- ✅ **Phase 0** — Setup environnements & CI/CD
- ✅ **Phase 1** — Backend Laravel (modèles, auth, endpoints, Swagger, tests, seeders)
- ✅ **Phase 2** — Mobile Flutter (écrans, navigation, thème, onboarding)
- 🟡 **Phase 3** — Intégrations tierces : RevenueCat ✅, YouTube ✅, **Passio.ai en mock** (clé API manquante)
- ⬜ **Phase 4** — Recette & qualité (cahier de recettes, process GitHub Issues)
- ✅ **Phase 5** — Documentation : Swagger, READMEs et `/docs`

Voir [project/Plan-implementation-FitnessPro.md](project/Plan-implementation-FitnessPro.md) pour le plan détaillé.

### Points ouverts (nécessitent une décision produit/légale, pas technique)

- Distribution mobile : Codemagic vs stores directement
- Accessibilité : pas de plan d'action formalisé
- RGPD : classification de sensibilité des données repas/corporelles à faire avec un juriste

## Démarrage rapide

```bash
# Backend (Docker)
docker compose up -d --build
docker compose exec backend php artisan migrate --seed

# Mobile
cd mobile && flutter pub get && flutter run
```

Détails complets : [backend/README.md](backend/README.md) · [mobile/README.md](mobile/README.md) · [guide de démarrage complet](docs/setup.md)

## Documentation

Voir [docs/](docs/README.md) pour l'architecture détaillée, le modèle de données, et le guide de démarrage pas à pas.

## Git Workflow

- `main` : production stable (releases)
- `develop` : intégration continue
- `feature/*` : nouvelles fonctionnalités
- `fix/*` : corrections de bugs

Les PRs doivent passer les checks CI (lint + tests + coverage).
