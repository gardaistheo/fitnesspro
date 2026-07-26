# Monitoring & alerting

> Couvre la compétence **C4.1.2** (éliminatoire) : conception d'un système de supervision et d'alerte.

## Périmètre de supervision

| Composant | Ce qui est supervisé |
| --- | --- |
| Backend Laravel (API REST) | Exceptions non gérées, erreurs 5xx, performance des requêtes (traces) |
| Mobile Flutter | Crashs natifs, exceptions Dart non gérées |
| Disponibilité API | Sonde `GET /api/health` (vérifie la connexion base de données) |

Hors périmètre (assumé) : supervision infra bas niveau (CPU/RAM du serveur Render, métriques PostgreSQL) — déléguée au dashboard natif de l'hébergeur.

## Indicateurs de suivi

- **Taux d'erreur backend** : nombre d'exceptions capturées par Sentry / nombre de requêtes, par endpoint.
- **Taux de crash mobile** : sessions avec crash / sessions totales (Sentry Flutter).
- **Disponibilité** : réponse `200 {"status":"ok"}` de `/api/health` (sonde interrogée en continu par un service externe, ex. UptimeRobot).
- **Temps de réponse** : traces de performance Sentry (`traces_sample_rate` à 20 % pour limiter le volume).

## Sondes mises en place

- **Sentry (backend)** : package `sentry/sentry-laravel`, câblé dans `bootstrap/app.php` via `Integration::handles($exceptions)`. Capture automatiquement toute exception non gérée par l'API, avec breadcrumbs (requêtes SQL, logs, jobs).
- **Sentry (mobile)** : package `sentry_flutter`, initialisé dans `main.dart`. DSN injecté au build via `--dart-define-from-file=env.json` (fichier local, gitignoré — voir `mobile/env.example.json` pour le modèle), jamais commité en dur. Le SDK reste inactif si le DSN est vide.
- **Sonde de disponibilité** : route `GET /api/health`, teste la connexion PostgreSQL et répond `200` (ok) ou `503` (degraded). Testée en local (bascule `200`/`503` selon l'état de la base) et conçue pour être interrogée périodiquement par un moniteur externe gratuit (UptimeRobot).

> **Limite assumée** : le monitoring d'erreurs (Sentry) est en place et vérifié en conditions réelles (backend + mobile, alertes email reçues). Le monitoring de disponibilité externe (UptimeRobot sur `/api/health`) n'est **pas encore activé**, faute d'hébergement Render en production à ce stade (contrainte budgétaire). La sonde `/api/health` est prête côté code ; l'activation du moniteur externe ne prendra que quelques minutes dès qu'un environnement de production sera disponible.

## Modalités de signalement (alerte)

- **Erreurs applicatives** : règle d'alerte Sentry (email) déclenchée dès qu'une nouvelle erreur apparaît ou qu'un taux d'erreur dépasse un seuil sur une fenêtre glissante.
- **Indisponibilité** : alerte email/SMS envoyée par le moniteur externe si `/api/health` ne répond pas ou répond en erreur pendant N vérifications consécutives.
- **Canal complémentaire (optionnel)** : le canal de log natif `slack` de Laravel (`config/logging.php`) peut être activé en renseignant `LOG_SLACK_WEBHOOK_URL`, pour relayer les erreurs critiques vers un canal Slack sans dépendance supplémentaire.

## Configuration requise (variables d'environnement)

| Variable | Où | Rôle |
| --- | --- | --- |
| `SENTRY_LARAVEL_DSN` | `backend/.env` | DSN du projet Sentry backend |
| `SENTRY_ENVIRONMENT` | `backend/.env` | Environnement rapporté à Sentry (local/staging/production) |
| `SENTRY_TRACES_SAMPLE_RATE` | `backend/.env` | Taux d'échantillonnage des traces de performance (0.2 par défaut) |
| `SENTRY_DSN` (dart-define) | build mobile | DSN du projet Sentry mobile |
| `SENTRY_ENVIRONMENT` (dart-define) | build mobile | Environnement rapporté à Sentry côté mobile |
