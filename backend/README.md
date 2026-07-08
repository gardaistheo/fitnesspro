# FitnessPro — Backend

API REST Laravel pour l'application FitnessPro (musculation + nutrition avec IA).

Pour une vue d'ensemble du projet (mobile + backend), voir le [README racine](../README.md).

## Stack

- **Framework** : Laravel 13 (PHP 8.3+)
- **Base de données** : PostgreSQL
- **Auth** : Laravel Sanctum (tokens)
- **Architecture** : Controller → Service → Model
- **Validation** : Form Requests
- **Tests** : Pest
- **Documentation API** : Swagger/OpenAPI (`darkaonline/l5-swagger`)

## Démarrage rapide

### Avec Docker (recommandé)

```bash
cd ..  # racine du repo
docker compose up -d --build
docker compose exec backend php artisan migrate --seed
```

L'API est alors servie sur `http://localhost:8000`.

### En local (sans Docker)

```bash
cd backend
cp .env.example .env
composer install
php artisan key:generate
# configurer DB_* dans .env pour pointer vers un Postgres local
php artisan migrate --seed
php artisan serve
```

## Tests

```bash
vendor/bin/pest
```

87 tests / 191 assertions au moment de la rédaction (feature tests par endpoint + tests unitaires sur les Services/Models/Policies). Le seuil de couverture visé en CI est ≥ 70 % (voir `.github/workflows/lint-test-backend.yml`, qui utilise pcov).

## Modèle de données

| Table | Description |
|---|---|
| `users` | Comptes utilisateurs (`is_admin` gère les droits sur les programmes) |
| `subscriptions` | Statut d'abonnement synchronisé depuis RevenueCat |
| `exercises` | Catalogue d'exercices (catégorie, difficulté, instructions, vidéo YouTube) |
| `programs` | Programmes d'entraînement (séances types) |
| `program_exercises` | Table pivot programme ↔ exercice (sets, reps, ordre) |
| `workout_sessions` | Séances planifiées/complétées par un utilisateur |
| `meals` | Historique des repas loggés (calories, macros) |

Voir les migrations dans `database/migrations/` pour le détail des colonnes, et `database/seeders/` pour les données de démo (10 exercices, 5 programmes, comptes de test).

## Endpoints API

Toutes les routes sous `auth:sanctum` nécessitent un header `Authorization: Bearer <token>`.

| Méthode | Route | Description | Auth |
|---|---|---|---|
| POST | `/api/auth/register` | Inscription | non |
| POST | `/api/auth/login` | Connexion | non |
| POST | `/api/auth/logout` | Déconnexion (révoque le token) | oui |
| GET | `/api/auth/me` | Utilisateur courant | oui |
| GET | `/api/exercises` | Liste des exercices (filtrable par catégorie/difficulté) | oui |
| GET | `/api/exercises/{id}` | Détail d'un exercice | oui |
| GET | `/api/programs` | Liste des programmes (filtrable par difficulté) | oui |
| GET | `/api/programs/{id}` | Détail d'un programme + exercices | oui |
| POST | `/api/programs` | Créer un programme | oui, admin |
| PUT | `/api/programs/{id}` | Modifier un programme | oui, admin |
| DELETE | `/api/programs/{id}` | Supprimer un programme | oui, admin |
| GET | `/api/workout-sessions` | Séances planifiées de l'utilisateur | oui |
| GET | `/api/workout-sessions/{id}` | Détail d'une séance (propriétaire uniquement) | oui |
| POST | `/api/workout-sessions` | Planifier une séance | oui |
| PUT | `/api/workout-sessions/{id}` | Modifier une séance (propriétaire uniquement) | oui |
| DELETE | `/api/workout-sessions/{id}` | Supprimer une séance (propriétaire uniquement) | oui |
| GET | `/api/meals` | Historique des repas (filtrable par période) | oui |
| POST | `/api/meals` | Logger un repas | oui |
| POST | `/api/subscriptions/webhook` | Webhook RevenueCat (secret partagé, pas Sanctum) | non |

Toutes les réponses suivent la structure `{status, message, data, errors}` (voir `app/Http/Responses/ApiResponse.php`).

### Documentation interactive (Swagger)

Une fois le serveur lancé :

- Interface Swagger UI : `http://localhost:8000/api/documentation`
- Spec OpenAPI brute (JSON) : `http://localhost:8000/docs`

Pour régénérer la doc après avoir modifié les annotations `#[OA\...]` des controllers :

```bash
php artisan l5-swagger:generate
```

## Webhook RevenueCat

`POST /api/subscriptions/webhook` reçoit les événements RevenueCat (achat, renouvellement, expiration, annulation) et met à jour la table `subscriptions`. L'authentification se fait via un secret partagé dans le header `Authorization`, configuré via `REVENUECAT_WEBHOOK_SECRET` dans `.env` — **pas** de Sanctum, puisque l'appel vient directement de RevenueCat et non d'un utilisateur authentifié de l'app.

Point important : RevenueCat identifie les utilisateurs via un `app_user_id` qui **doit correspondre** à l'ID utilisateur Laravel (voir `App\Services\SubscriptionService::handleRevenueCatEvent`, qui résout via `User::find($app_user_id)`). Côté mobile, `SubscriptionProvider.login(userId)` est appelé juste après l'inscription/connexion pour garantir cette correspondance.

## Comptes de test (seeders)

Après `php artisan migrate --seed` :

| Email | Mot de passe | Rôle |
|---|---|---|
| `test@fitnesspro.local` | `password` | Utilisateur standard |
| `admin@fitnesspro.local` | `password` | Admin (peut gérer les programmes) |

## Conventions

- **Migrations** : 1 migration = 1 concept, colonnes `snake_case`
- **Models** : PascalCase singulier (`WorkoutSession`, pas `WorkoutSessions`)
- **Routes** : kebab-case (`/workout-sessions`, pas `/workoutSessions`)
- **Validation** : toujours via Form Request dédiée, jamais dans le controller
- **Autorisation** : via Policy (`app/Policies/`), pas de vérifications ad-hoc dans les controllers

## Déploiement

Hébergement backend prévu sur Render (push sur `main` → déploiement auto + migrations). Voir le [Plan d'implémentation](../project/Plan-implementation-FitnessPro.md) pour le détail des phases.
