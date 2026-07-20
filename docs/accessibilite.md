# Accessibilité — FitnessPro (mobile Flutter)

Ce document résume le travail d'accessibilité mené sur l'application mobile FitnessPro,
dans le cadre de la certification RNCP niveau 7 (compétence éliminatoire). Il couvre
l'état initial, les corrections apportées, les tests ajoutés et les points restants,
en s'appuyant sur les standards **WCAG 2.1 niveau AA** et les guidelines **Material
Design**.

## 1. État initial

Avant ce travail, l'application n'avait fait l'objet d'aucun traitement d'accessibilité.
Un audit du code (`mobile/lib/`, 5 widgets réutilisables et 13 écrans) a mis en évidence
les problèmes suivants :

| Catégorie | Problèmes constatés |
|---|---|
| **Contraste des couleurs** | `FPColors.muted` (2,94:1) et `lightMuted` (2,25–2,45:1) très en dessous du seuil AA de 4,5:1, utilisés dans plusieurs écrans (quiz, onboarding, paywall) |
| **Éléments sans sémantique** | Bouton principal du scanner photo (`GestureDetector` muet), boutons icône sans `tooltip` (retour, suppression, fermeture, reset hydratation) |
| **Cibles tactiles trop petites** | Bouton retour (`back_header.dart`, 36×36 dp), chips de filtre (`tag_chip.dart`), pavé numérique du scanner, bouton "Voir le planning" (padding nul) |
| **Alternative textuelle manquante** | Lecteur vidéo YouTube des exercices sans titre/description associés, placeholder vidéo muet |
| **Formulaires** | Champs `TextField` utilisant `hintText` (disparaît à la saisie) au lieu de `labelText` (persistant) |
| **Information portée par la seule couleur** | Indicateurs de pagination de l'onboarding (dots) sans équivalent texte de l'étape courante |
| **Texte non redimensionnable** | Absence totale de support du réglage système "grande taille de police" ; tailles de police systématiquement en dur |
| **Émojis décoratifs** | Lus littéralement par les lecteurs d'écran, redondants avec le texte adjacent |

## 2. Corrections apportées

### 2.1 Contraste des couleurs (WCAG 1.4.3 — Contrast Minimum)

Les tokens `FPColors.muted` et `FPColors.lightMuted` ont été ajustés (même teinte,
luminosité modifiée) pour atteindre ≥ 4,5:1 sur tous les fonds où ils sont utilisés :

| Token | Avant | Ratio avant | Après | Ratio après |
|---|---|---|---|---|
| `muted` (thème sombre, sur `bg`) | `#5A5A78` | 2,94:1 ❌ | `#7C7C9D` | 4,85:1 ✅ |
| `muted` (thème sombre, sur `surface`) | `#5A5A78` | 2,75:1 ❌ | `#7C7C9D` | 4,55:1 ✅ |
| `lightMuted` (thème clair, sur `lightBg`) | `#A0A0B8` | 2,45:1 ❌ | `#69698C` | 5,04:1 ✅ |
| `lightMuted` (thème clair, sur `lightSurface2`) | `#A0A0B8` | 2,25:1 ❌ | `#69698C` | 4,62:1 ✅ |

Un second cas a été détecté par les tests automatisés (voir §3) : le libellé "Streak"
du tableau de bord utilisait `colors.muted2` sur un fond dégradé teinté d'accent
(non uniforme), tombant à 2,84:1. Corrigé en utilisant `colors.text` (9,29:1 au pire
endroit du dégradé).

### 2.2 Sémantique des éléments interactifs (WCAG 4.1.2 — Name, Role, Value)

- **Scanner photo** (`food_scanner_screen.dart`) : le déclencheur (`GestureDetector`,
  qui ne fournit aucune sémantique native) reçoit `Semantics(button: true, label:
  "Prendre une photo du repas")`.
- **Boutons icône** sans nom accessible : ajout de `tooltip` sur les boutons retour et
  supprimer (`planning_screen.dart`), fermer (`food_scanner_screen.dart`).
- **Bouton reset hydratation** (`dashboard_screen.dart`, symbole "↺" seul) : ajout de
  `Semantics(button: true, label: "Réinitialiser l'hydratation", excludeSemantics:
  true)` pour que le lecteur d'écran annonce le nom de l'action plutôt que le
  caractère brut.
- **Chips de sélection** (`tag_chip.dart`, `select_card.dart`) : ajout de
  `Semantics(button: true, selected: active, label: ...)` pour annoncer l'état
  actif/inactif des filtres et des choix (utilisés dans le quiz d'onboarding).
- **Barre de progression** (`progress_bar_pill.dart`) : ajout de `Semantics(value:
  "X%")` pour annoncer la progression.
- **Emojis décoratifs** (🎯 landing, 💪/🔥/💧 dashboard et planning) : exclus de l'arbre
  sémantique via `Semantics(excludeSemantics: true)` pour éviter une lecture littérale
  redondante avec le texte adjacent (WCAG 1.1.1).

### 2.3 Cibles tactiles ≥ 48×48 dp (WCAG 2.5.5 / 2.5.8, Material Design)

- **Bouton retour** (`back_header.dart`) : zone cliquable portée de 36×36 à 48×48 dp
  (l'icône visuelle reste 36×36, centrée dans une zone tactile plus grande).
- **Chips de filtre** (`tag_chip.dart`) : hauteur minimale garantie à 48 dp via
  `ConstrainedBox`.
- **Pavé numérique du scanner** (`food_scanner_screen.dart`) : chaque touche contrainte
  à `minHeight/minWidth: 48` pour ne pas dépendre de la largeur d'écran.
- **Bouton "Voir le planning"** (`dashboard_screen.dart`) : le `padding: EdgeInsets.zero`
  supprimait toute zone cliquable au-delà du texte ; remplacé par un `minimumSize`
  explicite de 48×48 dp.

### 2.4 Alternative textuelle aux vidéos d'exercice (WCAG 1.1.1 / 1.2.1)

Dans `exercise_detail_screen.dart`, le lecteur YouTube et son placeholder (absence de
vidéo) sont enveloppés dans `Semantics(label: ...)` combinant le nom de l'exercice et
sa description, fournissant une alternative textuelle exploitable par un lecteur
d'écran là où l'information n'était auparavant disponible qu'à l'image.

### 2.5 Formulaires (WCAG 1.3.1 / 4.1.2)

Les champs `TextField` de connexion et d'inscription (`login_screen.dart`,
`signup_screen.dart`) utilisent désormais `labelText` (qui reste visible et associé au
champ) au lieu de `hintText` (qui disparaît dès la saisie et n'est jamais un vrai label
sémantique).

### 2.6 Information non portée par la seule couleur (WCAG 1.4.1)

Les indicateurs de pagination de l'onboarding (`onboarding_slides_screen.dart`), dont
l'état actif n'était porté que par la taille et la couleur des points, sont regroupés
sous un `Semantics(label: "Étape X sur Y")` explicite.

### 2.7 Redimensionnement du texte (WCAG 1.4.4 — Resize Text)

Le réglage système "grande taille de police" est désormais honoré : un `MediaQuery`
clampant le `textScaler` à un maximum de **1,3x** a été ajouté au niveau de
`MaterialApp.builder` (`main.dart`). Ce choix est un compromis assumé : un clamp plus
large (jusqu'à 2x, seuil couramment retenu pour l'AA) aurait nécessité de retravailler
plusieurs mises en page à taille fixe identifiées lors de l'audit (résultats du scanner
alimentaire, lignes de statistiques du dashboard). Les zones les plus à risque de
chevauchement ont en complément été sécurisées avec `Expanded`/`overflow: ellipsis`
(macros du scanner alimentaire, lignes de préréglages caloriques du quiz).

## 3. Tests d'accessibilité ajoutés

Un nouveau fichier `mobile/test/accessibility/accessibility_test.dart` vérifie, via les
guidelines standard de `flutter_test` :

- `textContrastGuideline` — contraste texte conforme WCAG ;
- `androidTapTargetGuideline` / `iOSTapTargetGuideline` — cibles tactiles ≥ 48×48 dp
  (Android) / 44×44 pt (iOS) ;
- `labeledTapTargetGuideline` — toute cible tactile expose un nom accessible ;

sur `LandingScreen`, `LoginScreen`, `SignupScreen` et `DashboardScreen`, plus des
vérifications ciblées :

- persistance du label des champs de connexion (`labelText` vs `hintText`) ;
- présence du label sémantique du bouton de reset hydratation ("↺") ;
- présence du label sémantique du déclencheur photo du scanner alimentaire.

Ces tests ont révélé un défaut réel non détecté par l'audit manuel initial : le
libellé "Streak" du tableau de bord, dont le contraste chutait à 2,84:1 sur le fond
dégradé de sa carte (fond non uniforme, donc non capturé par le calcul théorique fait
sur les couleurs de fond standard). Corrigé avant intégration.

**Résultats** : `flutter analyze` → 0 problème. `flutter test` → 128/128 tests passent
(121 tests existants + 7 nouveaux tests d'accessibilité), sans régression sur la suite
existante.

### Génération d'une capture Accessibility Scanner (Android)

Pour joindre une preuve visuelle au dossier de certification :

1. Installer **Accessibility Scanner** depuis le Google Play Store sur un appareil ou
   émulateur Android.
2. L'activer : *Paramètres → Accessibilité → Accessibility Scanner → Activer*.
3. Lancer l'app FitnessPro (`flutter run`) et naviguer jusqu'à l'écran à auditer
   (ex. Dashboard, Scanner photo).
4. Ouvrir le bouton flottant bleu d'Accessibility Scanner puis appuyer sur le bouton
   d'analyse (icône loupe) : l'outil surligne les éléments avec un problème détecté
   (contraste, taille de cible, libellé manquant) et propose une suggestion pour
   chacun.
5. Utiliser la fonction de capture d'écran intégrée à l'outil (icône appareil photo
   dans le rapport de résultats) pour exporter l'analyse annotée en image, à inclure
   telle quelle dans le dossier écrit.

## 4. Ce qu'il reste à améliorer

- **Redimensionnement du texte au-delà de 1,3x** : le clamp actuel est un compromis ;
  un support complet jusqu'à 200 % (seuil de référence AA) demanderait de retravailler
  les mises en page à taille fixe restantes (ex. `Row` de statistiques sans `Expanded`
  dans certaines cartes du dashboard).
- **Navigation clavier / focus visible** : aucun indicateur de focus dédié distinct de
  la couleur d'accent n'a été introduit ; le comportement avec un clavier externe ou un
  switch d'accessibilité n'a pas été testé (non observable en test automatisé).
- **Coverage des tests d'accessibilité** : les écrans de flux secondaires (planning,
  scanner alimentaire en détail, écrans de quiz/onboarding complets) ne sont pas
  encore couverts par `meetsGuideline` — seuls les écrans jugés les plus critiques
  (landing, auth, dashboard) le sont à ce stade.
- **RGPD / classification des données** et **plan d'accessibilité au-delà du code**
  (documentation utilisateur, formation) restent des points ouverts identifiés dans
  `CLAUDE.md`, hors du périmètre strictement technique de ce travail.
