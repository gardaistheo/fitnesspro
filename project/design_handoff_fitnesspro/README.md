# Handoff: FitnessPro — Application mobile de musculation

## Overview
FitnessPro est une application mobile de musculation complète avec IA. Elle comprend un flux d'onboarding personnalisé (quiz), un dashboard de suivi, un coach IA conversationnel (Claude), un scanner alimentaire, une bibliothèque d'exercices et de séances, et un planning hebdomadaire.

## About the Design Files
Le fichier `FitnessPro.html` est un **prototype haute fidélité** créé en HTML/React — il sert de référence visuelle et comportementale. La mission est de **recréer ces écrans dans votre codebase existante** (React Native, Expo, Swift, Kotlin, etc.) en utilisant ses patterns et librairies établis. Ne pas shipper ce fichier HTML directement.

## Fidelity
**Haute fidélité (hifi)** — Les couleurs, typographies, espacements, animations et interactions sont finalisés. Le développeur doit recréer l'UI pixel-perfect en utilisant les patterns du codebase cible.

---

## Design Tokens

### Couleurs
```
bg:       #0C0C14   — fond principal
surface:  #141420   — cartes, panneaux
surface2: #1C1C2A   — inputs, éléments secondaires
border:   #252538   — séparateurs, bordures
accent:   #C1FF4D   — vert lime, couleur principale d'action
orange:   #FF6B35   — calories, alerte douce
text:     #F0F0F8   — texte principal
muted:    #5A5A78   — texte désactivé
muted2:   #8A8AAA   — texte secondaire
red:      #FF4F4F   — erreur, danger
green:    #4ADE80   — succès, validation
blue:     #60A5FA   — hydratation, infos
purple:   #A78BFA   — IA, éléments spéciaux
```

### Typographie
- **Font principale** : Space Grotesk (Google Fonts)
- Weights utilisés : 400, 500, 600, 700, 800, 900
- Titres principaux : 20–36px, weight 900, letter-spacing -0.5 à -1
- Corps de texte : 13–15px, weight 400–600, line-height 1.6
- Labels/caps : 11px, weight 700, letter-spacing 1, text-transform uppercase

### Bordures & Rayons
```
Petits éléments (chips, badges) : border-radius 999px (pill)
Inputs                          : border-radius 12px
Cartes                          : border-radius 16px
Boutons principaux              : border-radius 12px
Modales bottom-sheet            : border-radius 20px 20px 0 0
Sélecteurs quiz                 : border-radius 14px
```

### Ombres
```
Carte principale  : aucune (border seul suffit)
Modale overlay    : background rgba(0,0,0,0.75)
Toast             : background coloré semi-transparent + border colorée
```

### Espacements
- Padding horizontal global : 16–20px
- Gap entre cartes : 12px
- Padding interne carte : 16px
- Section title margin-bottom : 10px

---

## Écrans & Composants

### 1. Landing Screen (`landing`)
**But** : Page de vente, convertir en inscription.

**Layout** :
- Scroll vertical, fond `#0C0C14`
- Header hero centré : étiquette accent uppercase + titre 3 lignes (36px, weight 900) + sous-titre
- Effet glow : radial-gradient cercle 300px, accent à 10% opacité, centré derrière le titre
- Carte pricing : fond `#141420`, border-radius 20, padding 22px, overflow hidden. Contient :
  - Label "ACCÈS ILLIMITÉ" (11px, accent, uppercase, letter-spacing 2)
  - Prix "9,99 €/mois" (font 46px weight 900 + 18px €/mois)
  - 4 lignes de feature avec icône emoji, texte 13px muted2, checkmark SVG accent à droite
- CTA pleine largeur "Commencer mon essai gratuit →" + sous-texte "7 jours gratuits"

---

### 2. Signup Screen (`signup`)
**But** : Création de compte en 2 étapes.

**Étape 1 — Formulaire** :
- 3 inputs : Prénom+nom, email, password
- Style input : background surface2, border border, radius 12, padding 13×14, font 15px, couleur text
- CTA disabled tant que les 3 champs ne sont pas remplis

**Étape 2 — Paiement** :
- Récap pricing (fond surface, radius 14, border)
- Numéro de carte (input pleine largeur)
- Grid 2 colonnes : MM/AA + CVC
- CTA "🔒 Démarrer mon essai gratuit" — loading state "⏳ Traitement..." pendant 1,8s puis navigation

---

### 3. Quiz Screen (`quiz`)
**But** : Personnalisation du programme (7 étapes si Maison, 6 sinon).

**Header** :
- Progress bar (accent, height 6, radius 999, animated)
- Étape N sur M + bouton retour

**Étapes** :
1. **Niveau** : 3 cartes larges cliquables (🌱 Débutant / 💪 Intermédiaire / 🔥 Avancé). Border accent quand sélectionné, bg `${accent}18`
2. **Objectif + poids** : 3 tag-buttons + 2 inputs numériques grid 2 col
3. **Disponibilités** : 7 tag-buttons jours + range slider 0.5→3 (step 0.5), accentColor accent
4. **Lieu** : 3 cartes avec emoji + titre + description (🏠/🏋️/🌳)
5. **Matériel** (si Maison) : Wrap de tag-buttons + option "poids du corps"
6. **Calories entrées** : Affichage grand chiffre accent + slider 1200→4000 + 4 boutons preset
7. **Calories dépensées** : Idem mais couleur orange

**Navigation** : bouton "Continuer →" en bas, disabled si choix requis non fait.

---

### 4. Onboarding Screen (`onboarding`)
**But** : Bienvenue post-quiz, 4 slides.

**Layout** : Centré verticalement. Emoji 68px + titre 24px + body 14px muted2.
**Dots** : Indicateurs de progression — dot actif = width 22px accent, inactif = 8px surface2, transition 300ms.
**Navigation** : "Suivant →" ou "Accéder à mon espace →" sur dernière slide + lien "Passer" sous.

---

### 5. Dashboard (`dashboard`)
**But** : Vue principale, métriques du jour.

**Header** : "Bonjour 👋" muted2 + titre "Mon tableau de bord" + badge streak "🔥 12 jours" (accent bg22, border accent44).

**Carte Streak** :
- Background : `linear-gradient(135deg, accent20 0%, surface 65%)`
- Border : `accent44`
- Chiffre "12" taille 34px + emoji 🔥 48px à droite

**Carte Prochaine séance** : Date/heure (muted2) + nom séance (weight 800, 17px) + muscles (muted2) + badge durée (blue) + bouton "Voir le planning →"

**Carte Hydratation** :
- Progress bar blue (height 8)
- Boutons "+250 ml" / "+500 ml" / "↺"
- Couleur blue (#60A5FA) pour tout l'élément

**Carte Calories** :
- Progress bar orange (height 8)
- Bloc détail calcul (bg surface2, radius 10, padding 10×12) : Apports / Dépenses / Sport / = Restant
- Bouton ghost "📷 Scanner un repas"

---

### 6. Coach IA (`ai`)
**But** : Chat avec Claude en temps réel.

**Header** : Avatar 🧠 (38×38, radius 12, purple22) + "Coach IA" bold + "● En ligne" green (11px) + bouton "Historique"

**Bulles** :
- User : fond accent, couleur `#0C0C14`, radius `16px 16px 4px 16px`, weight 600
- Assistant : fond surface2, couleur text, radius `16px 16px 16px 4px`, avatar 🧠 26px à gauche
- Loading : 3 dots animés (animation `dotPulse 1s ease infinite`, delay 0/0.2/0.4s)

**Barre de suggestions** : 3 chips scrollables horizontalement (bg surface2, radius 999, border, 11px)

**Input** : flex row, input surface2 radius 12 + bouton envoi (fond accent quand texte, surface2 sinon, radius 12, 44×44)

**Connexion API** : `window.claude.complete()` avec rôle system coach musculation FR.

**Historique** : Bottom-sheet overlay (rgba 0.7) avec liste des conversations précédentes.

---

### 7. Scanner alimentaire (`food`)
**But** : Identifier les calories d'un repas.

**Phase `camera`** :
- Viewfinder noir avec grille subtile (repeating-gradient 5% opacity)
- Cadre de scan 210×170 accent avec coins stylisés (4 coins indépendants, 18×18, border 3px)
- Bouton déclencheur rond 64px accent avec icône appareil photo
- Label "Powered by Passio AI"

**Phase `scanning`** : Spinner rotatif (border 4px, borderTopColor accent, animation spin 1s linear infinite) + textes.

**Phase `result`** :
- Bloc résultat : bg `accent18`, border `accent44`, label "✓ REPAS IDENTIFIÉ"
- Nom repas (weight 800, 18px) + calories (30px weight 900 accent)
- Grid 3 colonnes : Protéines (blue) / Glucides (orange) / Lipides (purple)
- 3 boutons : Ajouter / Rescanner / Saisie manuelle

**Phase `manual`** :
- Affichage grand chiffre centré (52px weight 900)
- 3 presets rapides (pill buttons)
- Numpad 3×4 (bg surface2, radius 11, font 17px weight 700) avec touche ⌫

**Phase `logged`** : Icône ✓ dans cercle vert + texte confirmation → retour auto après 2,3s

---

### 8. Bibliothèque Exercices (`exercises`)
**But** : Parcourir et consulter des exercices.

**Liste** :
- Barre de recherche + filtres catégorie (pills scrollables : Tous / Jambes / Poitrine / Dos / Épaules / Bras / Triceps / Abdominaux)
- Chaque item : icône emoji 42×42 (accent18 bg, radius 10) + nom+muscles + DiffChip + chevron
- Tap → ExerciseDetail

**ExerciseDetail** :
- Placeholder vidéo (190px, surface2) avec play button centré (60px, accent22, play SVG accent)
- Chips catégorie (blue) + difficulté
- Description 13px muted2
- Section "Muscles travaillés" : chips purple
- Section "Instructions" : numéros 1-4 dans carré accent22 (24×24, radius 8) + texte muted2

---

### 9. Bibliothèque Séances (`workouts`)
**But** : Parcourir les séances et les ajouter au planning.

**Filtres** : Pills Tous / Débutant / Intermédiaire / Avancé

**Carte séance** :
- Header : nom (weight 800, 15px) + muscles (muted2) + DiffChip
- Footer (border-top border) : liste des 3 premiers exercices séparés par " · " + chevron

**WorkoutDetail** :
- Chips : difficulté + durée (blue) + muscles (purple)
- Pour chaque exercice : carte surface, nom + grid de sets (bg surface2, radius 8, "Série N" + chiffre accent 15px)
- Footer fixe : bouton "📅 Ajouter à mon planning"

**Toast** : aparaît en bas après ajout (bg `#4ADE8022`, border `#4ADE8044`, texte "✓ {nom} ajouté au planning", zIndex 50, disparaît après 2,2s)

---

### 10. Planning (`planning`)
**But** : Visualiser et gérer les séances planifiées.

**Header** : BackHeader + bouton "+ Ajouter" (accent, radius 10, 13px weight 700)

**Groupement par date** :
- Séparateur : date (muted2, uppercase, weight 700) + ligne hr + chip "Aujourd'hui/Demain/Dans Nj/Passé"
- Couleurs chip : Aujourd'hui = accent, Passé = muted, autres = blue

**Item séance** :
- Icône 💪 42×42 (accent18, radius 11) + nom (weight 800) + heure · muscles + durée
- Bouton suppression (bg `#FF4F4F18`, border `#FF4F4F33`, radius 10, icône poubelle SVG red)

**Modal ajout** : Bottom-sheet overlay, liste des séances FP_WORKOUTS cliquables

---

## Interactions & Comportement

### Navigation
- Stack de screens géré par un état `screen` (string)
- Transitions : `fadeSlide` animation 0,22s ease (opacity 0→1, translateY 10px→0) sur chaque changement d'écran
- Bottom nav visible uniquement sur les 5 écrans principaux (`dashboard/ai/food/exercises/workouts`)
- La route `planning` est accessible depuis le Dashboard (tap sur carte "Prochaine séance") et le back-header

### Animations
```css
@keyframes spin { to { transform: rotate(360deg); } }
@keyframes dotPulse { 0%,80%,100% { opacity:.3; transform:scale(.8) } 40% { opacity:1; transform:scale(1) } }
@keyframes fadeSlide { from { opacity:0; transform:translateY(10px) } to { opacity:1; transform:translateY(0) } }
```

### États des boutons
- `disabled` : opacity 0.4, cursor not-allowed
- `onMouseDown` : `transform: scale(0.97)`
- `onMouseUp/Leave` : `transform: scale(1)`

---

## Composants Réutilisables

### `FPBtn`
Props : `children, onClick, variant ('primary'|'secondary'|'ghost'|'danger'), disabled, small`
- primary : bg accent, color `#0C0C14`
- secondary : bg surface2, color text, border
- ghost : transparent, color muted2, border
- small : padding 9×16, font 13px

### `ProgressBar`
Props : `value, max, color, height`
- Fond surface2, radius 999, overflow hidden
- Barre colorée, transition width 0.4s

### `Chip`
Props : `label, color`
- Inline-block, padding 3×10, radius 999, font 11px weight 700
- bg `${color}22`, color `color`

### `DiffChip`
- Débutant → green `#4ADE80`
- Intermédiaire → orange `#FF6B35`
- Avancé → red `#FF4F4F`

### `Card`
- bg surface, radius 16, padding 16, border, marginBottom 12

### `BackHeader`
- Bouton retour 36×36 (surface2, radius 10, chevron SVG) + titre flex + slot rightEl

### `SecTitle` (Section Title)
- 11px, weight 700, muted2, letterSpacing 1, uppercase, marginBottom 10

---

## Données Mock

### Exercices (10)
Squat · Développé couché · Tractions · Développé militaire · Curl biceps · Dips · Soulevé de terre · Pompes · Fentes · Gainage

Chaque exercice : `{ id, name, category, muscles[], difficulty, description, instructions[] }`

### Séances (5)
Push Day A · Pull Day A · Leg Day A · Full Body Débutant · Upper Body

Chaque séance : `{ id, name, muscles, duration, difficulty, exercises[{ name, sets[{ reps }] }] }`

### Planning initial (3 entrées)
`{ id, workoutId, workoutName, date, time, muscles, duration }`

### Chat initial (3 messages)
1 message assistant de bienvenue + 1 échange user/assistant sur le dos

---

## Intégration IA

Le Coach IA utilise `window.claude.complete()` (helper Anthropic interne) :
```js
const reply = await window.claude.complete({
  messages: [{ role: 'user', content: `Tu es CoachAI, expert en musculation et nutrition sportive. Réponds en français, de façon concise et encourageante. Question : ${input}` }]
});
```
En production, remplacer par l'API Anthropic Claude (modèle `claude-haiku-4-5` ou `claude-sonnet-4-5`).

---

## Fichiers inclus
- `FitnessPro.html` — Prototype hifi complet (React/Babel inline, toutes les données mockées, toutes les interactions)

---

## Notes d'implémentation

1. **Framework recommandé** : React Native + Expo (si app native) ou Next.js (si web)
2. **Navigation** : React Navigation (native) ou Next.js App Router (web)
3. **Police Space Grotesk** : disponible sur Google Fonts, à ajouter via `expo-font` ou `next/font`
4. **Icônes** : Les SVG sont tous inline dans le prototype — les exporter en composants React ou utiliser une librairie (Lucide, Phosphor)
5. **Claude API** : `@anthropic-ai/sdk`, modèle `claude-haiku-4-5`, system prompt fixe par feature
6. **Scanner alimentaire** : Intégrer Passio AI SDK (React Native) ou fallback saisie manuelle
7. **Persistance** : AsyncStorage (RN) ou localStorage (web) pour streak, hydratation, planning
8. **Authentification** : Supabase ou Firebase Auth recommandé
