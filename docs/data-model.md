# Modèle de données

Toutes les tables ci-dessous vivent dans PostgreSQL, gérées par les migrations dans `backend/database/migrations/`.

## Diagramme (MLD simplifié)

```
users (1) ──────< (N) subscriptions
  │
  ├──────< (N) workout_sessions >────── (0..1) programs
  │                                            │
  └──────< (N) meals                           └──< (N) program_exercises >── (1) exercises
```

## Tables

### `users`
Comptes utilisateurs. `is_admin` gère l'autorisation de créer/modifier/supprimer des programmes (voir `ProgramPolicy`).

| Colonne | Type | Notes |
|---|---|---|
| `id` | bigint PK | |
| `name` | string | |
| `email` | string | unique |
| `password` | string | hashé |
| `is_admin` | boolean | défaut `false` |
| `email_verified_at` | timestamp | nullable |
| `created_at` / `updated_at` | timestamp | |

### `subscriptions`
Statut d'abonnement, synchronisé depuis RevenueCat via webhook (`SubscriptionService::handleRevenueCatEvent`).

| Colonne | Type | Notes |
|---|---|---|
| `id` | bigint PK | |
| `user_id` | FK → users, cascade delete | |
| `is_active` | boolean | défaut `false` |
| `provider` | string, nullable | ex. `"revenuecat"` |
| `external_id` | string, nullable | ID de transaction RevenueCat |
| `started_at` / `expires_at` | timestamp, nullable | |

Un utilisateur peut avoir plusieurs lignes `subscriptions` dans le temps (historique) ; `User::activeSubscription()` renvoie la plus récente avec `is_active = true`.

### `exercises`
Catalogue d'exercices (indépendant des programmes — un exercice peut apparaître dans plusieurs programmes).

| Colonne | Type | Notes |
|---|---|---|
| `id` | bigint PK | |
| `name` | string | |
| `category` | string | indexée, ex. "Poitrine", "Jambes" |
| `muscles` | json, nullable | tableau de chaînes |
| `difficulty` | string | indexée, ex. "Débutant" |
| `description` | text, nullable | |
| `instructions` | json, nullable | tableau d'étapes |
| `youtube_url` | string, nullable | lu côté mobile via `youtube_player_flutter` |

### `programs`
Programmes d'entraînement (séances types réutilisables, ex. "Push Day A").

| Colonne | Type | Notes |
|---|---|---|
| `id` | bigint PK | |
| `name` | string | |
| `muscles` | json, nullable | |
| `difficulty` | string | indexée |
| `duration` | unsigned int, nullable | minutes |
| `description` | text, nullable | |

### `program_exercises` (pivot)
Relie `programs` ↔ `exercises` avec les paramètres spécifiques à ce programme (sets/reps/ordre).

| Colonne | Type | Notes |
|---|---|---|
| `id` | bigint PK | |
| `program_id` | FK → programs, cascade delete | |
| `exercise_id` | FK → exercises, cascade delete | |
| `sets` | unsigned int | |
| `reps` | unsigned int | |
| `order` | unsigned int | défaut `0`, définit l'ordre d'affichage |

Index composé `(program_id, order)` pour charger un programme avec ses exercices déjà triés.

### `workout_sessions`
Séances planifiées ou complétées par un utilisateur. `program_id` est nullable — une séance peut exister sans référencer un programme du catalogue (bien que l'app ne construise actuellement que des séances liées à un programme).

| Colonne | Type | Notes |
|---|---|---|
| `id` | bigint PK | |
| `user_id` | FK → users, cascade delete | |
| `program_id` | FK → programs, nullable, **null on delete** | |
| `scheduled_date` | date | |
| `scheduled_time` | time, nullable | |
| `completed_at` | timestamp, nullable | rempli automatiquement au passage à `status = completed` |
| `status` | string | défaut `"planned"` (`planned` / `completed` / `cancelled`) |

### `meals`
Historique des repas loggés. Alimentée soit par le SDK Passio.ai côté mobile (résultat photo → calories/macros), soit par saisie manuelle — le backend ne fait aucune distinction entre les deux, il reçoit juste le résultat final.

| Colonne | Type | Notes |
|---|---|---|
| `id` | bigint PK | |
| `user_id` | FK → users, cascade delete | |
| `name` | string | |
| `calories` | unsigned int | défaut `0` |
| `proteins` / `carbs` / `fats` | unsigned int | grammes, défaut `0` |
| `logged_at` | timestamp | date/heure du repas (peut différer de `created_at`) |

### `personal_access_tokens`
Table standard Laravel Sanctum (tokens d'API), polymorphique sur `tokenable`.

## Notes de conception

- Toutes les FK vers `users` sont en `cascadeOnDelete()` : supprimer un utilisateur supprime ses abonnements, séances et repas.
- `workout_sessions.program_id` est en `nullOnDelete()` (pas cascade) : supprimer un programme du catalogue ne doit pas effacer l'historique des séances qui le référençaient.
- Les champs `muscles`/`instructions` sont stockés en `json` plutôt que dans des tables de jointure séparées — c'est un choix pragmatique pour des listes courtes et non interrogées individuellement (pas de recherche "tous les exercices ciblant les quadriceps").
