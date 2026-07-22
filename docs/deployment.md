# Déploiement

Ce document décrit le processus de déploiement du backend (Render) et de l'application mobile (stores officiels).

## Backend (Render)

### Principe

Le backend Laravel est déployé sur [Render](https://render.com) via déploiement automatique : chaque push sur la branche de production déclenche un build et un déploiement, sans étape manuelle.

### Flux de déploiement

1. Merge de `develop` → `main` (voir workflow Git dans [CLAUDE.md](../CLAUDE.md))
2. Render détecte le push sur `main` et lance un nouveau build
3. Build : `composer install --no-dev --optimize-autoloader`
4. Migrations : exécutées automatiquement au démarrage (`php artisan migrate --force`)
5. Le nouveau service remplace l'ancien une fois les health checks passés (zero-downtime)

> **Important** : le déploiement sur Render ne rejoue pas la CI GitHub Actions. Un push sur `main` doit donc toujours passer par une PR avec CI verte (lint + tests + coverage ≥ 70%, voir [.github/workflows/lint-test-backend.yml](../.github/workflows/lint-test-backend.yml)) avant merge.

### Configuration Render

Le service Render doit être configuré avec :

| Paramètre | Valeur |
|---|---|
| Runtime | PHP (ou Docker si `Dockerfile` backend utilisé) |
| Build command | `composer install --no-dev --optimize-autoloader && php artisan config:cache && php artisan route:cache` |
| Start command | `php artisan migrate --force && php artisan serve --host 0.0.0.0 --port $PORT` |
| Root directory | `backend/` |
| Base de données | PostgreSQL managé (add-on Render) |

### Variables d'environnement

Les variables d'environnement de production sont gérées **exclusivement via le dashboard Render** (jamais commitées). Se baser sur [backend/.env.example](../backend/.env.example) pour la liste des clés à renseigner, en particulier :

- `APP_ENV=production`, `APP_DEBUG=false`
- `APP_KEY` (générer avec `php artisan key:generate --show` et coller la valeur)
- `APP_URL` : URL publique Render du service
- `DB_*` : fournis automatiquement par Render si la base Postgres est liée au service
- `REVENUECAT_WEBHOOK_SECRET` : secret du webhook RevenueCat (voir [architecture.md](architecture.md))
- `SESSION_DRIVER`, `CACHE_STORE`, `QUEUE_CONNECTION` : `database` en production (pas de Redis pour le moment)

### Rollback

En cas de problème après un déploiement :

1. Dans le dashboard Render, aller sur l'onglet **Events** du service
2. Sélectionner le déploiement précédent stable et cliquer **Rollback to this deploy**
3. Vérifier que les migrations du déploiement rollback ne sont pas destructives (une migration qui a supprimé une colonne ne sera pas annulée par le rollback Render, qui ne fait que redéployer l'ancien code — une migration corrective peut être nécessaire)

### Vérification post-déploiement

```bash
curl https://<service>.onrender.com/api/auth/me -H "Accept: application/json"
# → {"status":"error","message":"Unauthenticated.",...} attendu
```

Vérifier aussi les logs Render (onglet **Logs**) pour confirmer que les migrations se sont exécutées sans erreur.

## Mobile (Play Store / TestFlight)

Distribution classique via les stores officiels (pas de Codemagic/Fastlane pour le moment — voir Points Ouverts dans [CLAUDE.md](../CLAUDE.md)).

### Versioning

Le numéro de version suit le format `MAJOR.MINOR.PATCH+BUILD` défini dans [mobile/pubspec.yaml](../mobile/pubspec.yaml) (`version:`). `BUILD` (après le `+`) doit être incrémenté à chaque soumission, même pour une même version sémantique (requis par les deux stores).

### Android (Google Play Store)

1. Incrémenter `version` dans `mobile/pubspec.yaml`
2. Build de l'App Bundle signé :
   ```bash
   cd mobile
   flutter build appbundle --release
   ```
   Le fichier généré se trouve dans `mobile/build/app/outputs/bundle/release/app-release.aab`
3. Signature : le keystore de release et `key.properties` (non commités, voir `.gitignore`) doivent être présents localement ou en CI sécurisée
4. Upload du `.aab` dans la [Google Play Console](https://play.google.com/console), piste de test (interne/fermée) ou production
5. Renseigner les notes de version, puis soumettre à la revue Google

### iOS (TestFlight / App Store)

1. Incrémenter `version` dans `mobile/pubspec.yaml`
2. Build de l'archive iOS :
   ```bash
   cd mobile
   flutter build ipa --release
   ```
   Le fichier `.ipa` est généré dans `mobile/build/ios/ipa/`
3. Upload via **Xcode Organizer** ou `xcrun altool` / **Transporter** vers App Store Connect
4. Le build apparaît d'abord sur TestFlight pour les tests internes/externes
5. Une fois validé, soumission à la revue App Store depuis App Store Connect

### Checklist avant soumission

- [ ] CI mobile verte (`flutter analyze`, `dart format`, tests — voir [.github/workflows/lint-test-mobile.yml](../.github/workflows/lint-test-mobile.yml))
- [ ] `APP_URL` / endpoint API pointent vers le backend de production Render (pas localhost)
- [ ] Version et build number incrémentés
- [ ] Tokens RevenueCat / clés API tierces configurés pour l'environnement de production
- [ ] Test manuel du golden path (inscription → dashboard → séance) sur un device réel

## Environnements

| Environnement | Backend | Mobile |
|---|---|---|
| Développement local | Docker Compose (voir [setup.md](setup.md)) | `flutter run` sur simulateur/device |
| Staging | Service Render lié à `develop` (si configuré) | Build interne (TestFlight interne / piste fermée Play Store) |
| Production | Service Render lié à `main` | Play Store / App Store publics |

## Ressources

- [Guide de démarrage](setup.md)
- [Architecture](architecture.md)
- [Render Dashboard](https://dashboard.render.com)
