# Bloc 2 — FitnessPro · Choix techniques et fonctionnels (référentiel)

> Fichier de référence : centralise toutes les décisions figées au fil de la rédaction.
> À mettre à jour dès qu'un choix est arrêté pour garantir la cohérence entre les parties.

## Produit & modèle économique

| Sujet | Choix arrêté | Détail / implication |
| --- | --- | --- |
| Cible utilisateur | Grand public / débutants | Persona : « le débutant motivé » |
| Modèle économique | **Abonnement 9,99 €/mois, obligatoire** | Accès aux fonctionnalités conditionné à l'abonnement |
| Gestion de l'abonnement | **RevenueCat** (service externe) | Dépendance technique / **partenaire technologique** ; facturation in-app stores |
| Intégration paiement | Webhooks **custom côté API Laravel** | RevenueCat notifie l'API des changements d'état d'abonnement |

## Stack technique

| Couche | Choix arrêté | Détail / implication |
| --- | --- | --- |
| Mobile | **Flutter / Dart** | Code unique Android + iOS |
| Backend | **PHP — framework Laravel** | API REST maison |
| Base de données | **PostgreSQL** | Données relationnelles (users, programmes, séances, repas, abonnements) |
| Analyse repas (IA) | **SDK Passio.ai** intégré dans l'app Flutter | ⚠️ Le SDK réalise **ses propres appels réseau** (n'passe pas par l'API Laravel) |
| Hébergement | **Render** (type VPS) | Template de déploiement Laravel (compatibilité native) |

## Architecture & développement (Partie 2)

| Sujet | Choix arrêté | Détail / implication |
| --- | --- | --- |
| Architecture mobile | **Provider + ChangeNotifier (MVVM)** | Séparation UI / logique de présentation |
| Architecture backend | **MVC Laravel + couche Service** | Controller → Service → Model (Eloquent) |
| Validation entrées | **Form Requests** | Validation centralisée côté API |
| Authentification | **Laravel Sanctum** (tokens) | Auth API mobile |
| Tests backend | **Pest** | Tests unitaires + feature, couverture en CI |
| Tests mobile | **flutter_test** (+ mocktail) | Tests unitaires et de widgets |
| Accessibilité | **Non traitée à ce jour** | ⚠️ Compétence éliminatoire C2.2.3 → présentée en axe d'amélioration avec plan d'action |

## Recette & correction (Partie 3)

| Sujet | Choix arrêté | Détail / implication |
| --- | --- | --- |
| Recette fonctionnelle | **Manuelle sur staging avant chaque prod** | Cahier de recettes rejoué, blocage si scénario bloquant KO |
| Suivi des bogues | **GitHub Issues** (+ labels sévérité, lien PR) | Cycle Ouvert→En cours→Revue→Corrigé→Fermé |
| Non-régression | **Test automatisé ajouté par bogue corrigé** | Branche `fix/*`, test Pest/flutter, CI bloquante |
| Étude de cas | Exemple webhook RevenueCat (expiration) | À ajuster/remplacer par un cas réel si disponible |

## Fonctionnalités (périmètre)

- Catalogue d'exercices + **vidéos YouTube** intégrées
- **Bibliothèque de programmes** d'entraînement
- **Analyse de repas par photo (IA, Passio.ai)** → calories + macronutriments
- **Suivi / historique** des entraînements et des repas
- **Abonnement payant** (RevenueCat)

## Documentation (Partie 4)

| Sujet | Choix arrêté | Détail / implication |
| --- | --- | --- |
| Support de doc | **README + dossier `/docs`** versionnés | Markdown, suivi Git |
| Doc d'API | **Swagger / OpenAPI** | Endpoints, formats, auth Sanctum, Swagger UI |
| Modèle de données | Entités : User, Subscription, Exercise, Program, WorkoutSession, Meal | Diagramme MLD en annexe (optionnel) |

## Conformité & sécurité (à instruire)

| Sujet | Statut | Action |
| --- | --- | --- |
| Données potentiellement sensibles (alimentation, suivi corporel) | À qualifier | **Évaluer la sensibilité et les mesures avec un juriste spécialisé RGPD** |
| Photos de repas (transitant par le SDK Passio.ai) | À tracer | Identifier le flux de données et la localisation de traitement du SDK |
| Paiement | Délégué | Géré par RevenueCat + stores (pas de données carte stockées côté FitnessPro) |

## Environnements & CI/CD (Partie 1)

| Sujet | Choix arrêté | Détail / implication |
| --- | --- | --- |
| Versionnement | **Git sur GitHub** | Branches `main`, `develop`, `feature/*` |
| CI/CD | **GitHub Actions** | Pipeline lint + tests + couverture à chaque push/PR |
| Environnements | **Local + Staging + Production** | Staging = recette avant prod, données fictives |
| Qualité — analyse statique | **Laravel Pint + PHPStan/Larastan** (back), **flutter analyze** (mobile) | 0 erreur bloquante visée |
| Qualité — couverture | **Mesure du code coverage** en CI | Cible à fixer (Partie 2) |
| Monitoring runtime (Sentry) | **Non en place** | Présenté en perspective / axe d'amélioration |
| Distribution mobile | **Non encore définie** | Cible décrite (test interne stores / Codemagic) à arbitrer |

## Points restant à confirmer

- Authentification : ⟨à confirmer : Laravel Sanctum (probable) / JWT / OAuth2⟩
- Outillage local : ⟨à confirmer : Docker / Laravel Sail / Herd⟩
- Coverage cible : **≥ 70 %** (build cassé sinon) — à affiner en Partie 2
- Distribution mobile : test interne stores vs Codemagic/Fastlane
