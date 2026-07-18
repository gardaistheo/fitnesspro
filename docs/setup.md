# Guide de démarrage (développement local)

## Prérequis

- Docker Desktop (pour le backend)
- Flutter SDK 3.9+ (`flutter --version`)
- PHP 8.3+ et Composer (si vous préférez lancer le backend sans Docker)

## Backend

### Avec Docker (recommandé)

> **Docker Desktop doit être lancé et son moteur prêt** avant `docker compose up`. Sur Windows, ouvrez l'application Docker Desktop et attendez que l'icône de la barre des tâches indique qu'elle est prête (pas juste "en cours de démarrage") avant de lancer la commande — sinon vous obtiendrez une erreur `open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified` (voir "Problèmes courants" ci-dessous).

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

L'app pointe sur `http://10.0.2.2:8000` par défaut (voir `lib/services/api_service.dart`), l'adresse spéciale qui, depuis un émulateur Android, redirige vers `localhost` de la machine hôte. Sur simulateur iOS ou device physique sur le même réseau, adapter `baseUrl` en conséquence (`http://localhost:8000` pour iOS, ou l'IP LAN de votre machine pour un device physique).

### Désactiver RevenueCat en local

Le SDK RevenueCat Android peut crasher nativement au démarrage (`Purchases.configure()`) avec la clé Test Store par défaut — l'app se ferme juste après le log `Using a Test Store API key` et `flutter run` affiche `Lost connection to device`. Si ça arrive, lancer avec RevenueCat désactivé :

```bash
flutter run --dart-define=DISABLE_REVENUECAT=true
```

Dans ce mode, `SubscriptionProvider` court-circuite tous les appels RevenueCat et `isPro` est forcé à `true` (pas de blocage sur le paywall). Voir `lib/core/config/revenuecat_config.dart`.

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

**`flutter run` affiche "Lost connection to device" juste après le log RevenueCat** : crash natif connu du SDK Android avec la clé Test Store. Relancer avec `flutter run --dart-define=DISABLE_REVENUECAT=true` (voir section Mobile ci-dessus).

**`docker compose up` échoue avec `unable to get image '...'` / `open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified`** (Windows) : Docker Desktop n'est pas lancé, ou son moteur n'a pas fini de démarrer. Vérifier avec `docker info` — si la section `Server:` affiche une erreur de connexion au lieu des infos du moteur, ouvrir/attendre Docker Desktop puis relancer `docker compose up -d --build`.
