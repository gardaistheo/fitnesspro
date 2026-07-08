# Guide de démarrage (développement local)

## Prérequis

- Docker Desktop (pour le backend)
- Flutter SDK 3.9+ (`flutter --version`)
- PHP 8.3+ et Composer (si vous préférez lancer le backend sans Docker)

## Backend

### Avec Docker (recommandé)

```bash
docker compose up -d --build
docker compose exec backend php artisan migrate --seed
```

Vérifier que ça fonctionne :

```bash
curl http://localhost:8000/api/auth/me -H "Accept: application/json"
# → {"status":"error","message":"Unauthenticated.",...}  (attendu, sans token)
```

### Sans Docker

```bash
cd backend
cp .env.example .env
composer install
php artisan key:generate
# éditer .env : DB_HOST=127.0.0.1 (au lieu de "postgres") si Postgres tourne en local
php artisan migrate --seed
php artisan serve
```

### Lancer les tests

```bash
cd backend
vendor/bin/pest
```

## Mobile

```bash
cd mobile
flutter pub get
flutter run
```

L'app pointe sur `http://localhost:8000` par défaut (voir `lib/services/api_service.dart`). Si vous testez sur un émulateur Android, `localhost` depuis l'émulateur pointe vers l'émulateur lui-même, pas votre machine hôte — utiliser `10.0.2.2` à la place, ou lancer sur un simulateur iOS / device physique sur le même réseau.

### Lancer les tests

```bash
cd mobile
flutter test
flutter analyze
```

## Se connecter avec un compte de test

Après le `migrate --seed` backend :

| Email | Mot de passe |
|---|---|
| `test@fitnesspro.local` | `password` |
| `admin@fitnesspro.local` (admin, peut gérer les programmes) | `password` |

## Documentation API interactive

Une fois le backend lancé : `http://localhost:8000/api/documentation` (Swagger UI).

## Problèmes courants

**"Connection refused" depuis le mobile vers l'API** : vérifier que le backend Docker tourne (`docker compose ps`) et que l'émulateur/simulateur utilise la bonne adresse (voir note Android ci-dessus).

**Les migrations échouent avec "role does not exist"** : la base Postgres n'a pas encore terminé son health check au moment où `migrate` s'exécute — relancer `docker compose exec backend php artisan migrate --seed` après quelques secondes.

**Le paywall RevenueCat ne s'affiche pas en local** : la clé API sandbox par défaut (`lib/core/config/revenuecat_config.dart`) nécessite que l'offering "monthly"/"yearly" et l'entitlement "FitnessPro Pro" soient configurés côté dashboard RevenueCat — sans ça, `Purchases.getOfferings()` renvoie une liste vide. Voir [docs/architecture.md](architecture.md#authentification--synchronisation-revenuecat).
