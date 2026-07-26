# Changelog

Toutes les modifications notables de FitnessPro sont documentées dans ce fichier.

> Couvre la compétence **C4.3.2** (éliminatoire) : établir un journal des versions déployées.

Le format suit [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/). Le projet adoptera le [Semantic Versioning](https://semver.org/lang/fr/) à partir de sa première mise en production ; en attendant, les entrées sont regroupées sous `[Unreleased]`.

## [Unreleased]

### Added
- Monitoring & alerting : Sentry (backend Laravel + mobile Flutter), sonde de disponibilité `GET /api/health` — [#8](https://github.com/gardaistheo/fitnesspro/pull/8)
- Process de consignation des anomalies : template GitHub Issue (`bug_report.md`) et deux cas réels documentés — [#8](https://github.com/gardaistheo/fitnesspro/pull/8)
- Cahier de recettes fonctionnel — [#3](https://github.com/gardaistheo/fitnesspro/pull/3)
- Audit et corrections d'accessibilité (WCAG) sur l'app mobile — [#4](https://github.com/gardaistheo/fitnesspro/pull/4)
- Mesure de couverture de code (backend + mobile) en CI — [#5](https://github.com/gardaistheo/fitnesspro/pull/5)

### Fixed
- Pipeline CI/CD mobile : dépendances, lint, versions Flutter — [#1](https://github.com/gardaistheo/fitnesspro/pull/1)
- Débordement du header sur le Dashboard sur petits écrans — [#2](https://github.com/gardaistheo/fitnesspro/pull/2) ([issue #6](https://github.com/gardaistheo/fitnesspro/issues/6))
- Soumission possible avec une valeur invalide sur la saisie manuelle du scanner alimentaire ([issue #7](https://github.com/gardaistheo/fitnesspro/issues/7))

## Process de mise à jour

Ce fichier est mis à jour à chaque merge d'une PR vers `develop` documentant un changement notable (ajout, correction, changement de comportement). Une entrée `[Unreleased]` est promue en version datée (`[X.Y.Z] - AAAA-MM-JJ`) lors d'un déploiement en production, conformément à Semantic Versioning.
