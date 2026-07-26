# Gestion des incidents (anomalies)

> Couvre la compétence **C4.2.1** (éliminatoire) : consignation des anomalies détectées.

## Outil et process de collecte

Les anomalies sont consignées via **GitHub Issues** sur le dépôt `gardaistheo/fitnesspro`, avec un template structuré (`.github/ISSUE_TEMPLATE/bug_report.md`) qui impose de renseigner :

- le **contexte** (écran/endpoint, environnement, plateforme) ;
- les **étapes de reproduction** ;
- le **comportement attendu vs observé** ;
- la **sévérité** (bloquante / majeure / mineure) ;
- l'**environnement** (version/commit, étape de détection) ;
- le **correctif** (rempli à la clôture : commit(s)/PR, tests de non-régression ajoutés).

## Cycle de vie d'une anomalie

```
Détectée → Consignée (issue + label `bug`) → Analysée → Corrigée (commit/PR) → Fermée (référence au correctif)
```

Labels utilisés (déjà en place sur le dépôt) : `bug`, complétés au besoin par la sévérité indiquée dans le corps de l'issue.

## Cas réels traités

Deux anomalies réellement détectées et corrigées durant le développement ont été consignées rétroactivement selon ce process, pour disposer d'un exemple concret et vérifiable :

| Issue | Anomalie | Sévérité | Correctif |
| --- | --- | --- | --- |
| [#6](https://github.com/gardaistheo/fitnesspro/issues/6) | Débordement du header Dashboard sur petits écrans | Majeure | Commit `36241b9`, PR [#2](https://github.com/gardaistheo/fitnesspro/pull/2) |
| [#7](https://github.com/gardaistheo/fitnesspro/issues/7) | Bouton "Ajouter" actionnable avec une valeur invalide (scanner alimentaire) | Majeure | Commit `a430748` (+ 4 tests de non-régression) |

## Articulation avec la correction (C4.2.2)

Chaque issue fermée référence son commit/PR de correction, et — quand c'est pertinent — le test ajouté pour éviter la régression (ex. issue #7 : 4 tests ajoutés dans `mobile/test/screens/food_scanner_screen_test.dart`). Le détail du cycle correction → déploiement est traité dans le rendu écrit (Bloc 4, section 2.2), avec la PR #2 comme exemple bout en bout (issue → commit → PR → merge → déploiement).

## Limite assumée

Le process est désormais outillé et illustré par un cas réel, mais n'a pas encore été éprouvé en usage courant en dehors de cette consignation rétroactive (le projet est en développement actif, pas encore en production). Il sera appliqué prospectivement à chaque anomalie détectée à partir de maintenant.
