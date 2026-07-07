// FitnessPro — Data constants & mock data
const FP_EXERCISES = [
  { id:1, name:"Squat", category:"Jambes", muscles:["Quadriceps","Fessiers","Ischio-jambiers"], difficulty:"Intermédiaire",
    description:"Le squat est l'exercice roi pour développer les jambes et les fessiers. Maîtrisez ce mouvement fondamental pour bâtir une base solide.",
    instructions:["Pieds à la largeur des épaules, orteils légèrement tournés vers l'extérieur","Descendez en gardant le dos droit et les genoux alignés avec les orteils","Descendez jusqu'à ce que les cuisses soient parallèles au sol","Remontez en poussant sur les talons, expirez"] },
  { id:2, name:"Développé couché", category:"Poitrine", muscles:["Grand pectoral","Triceps","Deltoïde antérieur"], difficulty:"Intermédiaire",
    description:"L'exercice fondamental pour développer la masse pectorale. Indispensable dans tout programme de musculation.",
    instructions:["Allongé sur un banc, pieds à plat sur le sol","Saisir la barre légèrement plus large que les épaules","Descendre la barre jusqu'à effleurer le sternum","Pousser la barre vers le haut jusqu'à l'extension complète"] },
  { id:3, name:"Tractions", category:"Dos", muscles:["Grand dorsal","Biceps","Rhomboïdes"], difficulty:"Intermédiaire",
    description:"L'exercice idéal pour développer un dos large et sculpté. Aucun équipement particulier nécessaire hormis une barre.",
    instructions:["Saisir la barre fixe en pronation, mains plus larges que les épaules","Partir en suspension complète, bras tendus","Tirer le corps vers le haut jusqu'à ce que le menton dépasse la barre","Redescendre lentement en contrôlant le mouvement"] },
  { id:4, name:"Développé militaire", category:"Épaules", muscles:["Deltoïde antérieur","Deltoïde latéral","Triceps"], difficulty:"Intermédiaire",
    description:"L'exercice de base pour des épaules larges et puissantes. Peut se réaliser debout ou assis.",
    instructions:["Saisir la barre à hauteur d'épaule, prise légèrement plus large","Pousser la barre vers le haut jusqu'à l'extension complète","Garder le core contracté tout au long du mouvement","Redescendre la barre lentement jusqu'aux épaules"] },
  { id:5, name:"Curl biceps", category:"Bras", muscles:["Biceps brachial","Brachioradial"], difficulty:"Débutant",
    description:"L'exercice d'isolation par excellence pour des bras volumineux et définis.",
    instructions:["Debout, haltères dans les mains, bras le long du corps","Fléchir les coudes pour amener les haltères vers les épaules","Contracter les biceps en haut du mouvement","Redescendre lentement en contrôlant"] },
  { id:6, name:"Dips", category:"Triceps", muscles:["Triceps","Grand pectoral","Deltoïde antérieur"], difficulty:"Intermédiaire",
    description:"Les dips sont excellents pour développer la masse des triceps et renforcer la ceinture scapulaire.",
    instructions:["Saisir les barres parallèles, bras tendus, corps droit","Fléchir les coudes et descendre jusqu'à ce que les bras fassent 90°","Garder les coudes proches du corps","Remonter en poussant fort jusqu'à l'extension complète"] },
  { id:7, name:"Soulevé de terre", category:"Dos", muscles:["Ischio-jambiers","Fessiers","Érecteurs du rachis","Trapèzes"], difficulty:"Avancé",
    description:"Le soulevé de terre est l'exercice polyarticulaire par excellence, sollicitant l'ensemble du corps.",
    instructions:["Pieds à la largeur des hanches, barre au-dessus des lacets","Fléchir les genoux, saisir la barre en pronation","Dos droit, relever la tête et pousser dans le sol pour monter","Redescendre en contrôlant la barre jusqu'au sol"] },
  { id:8, name:"Pompes", category:"Poitrine", muscles:["Grand pectoral","Triceps","Deltoïde antérieur"], difficulty:"Débutant",
    description:"L'exercice le plus basique et efficace pour la poitrine. Peut se pratiquer partout, sans matériel.",
    instructions:["En appui sur les mains et les orteils, corps aligné","Mains légèrement plus larges que les épaules","Fléchir les coudes et descendre jusqu'à effleurer le sol","Pousser pour revenir à la position de départ"] },
  { id:9, name:"Fentes", category:"Jambes", muscles:["Quadriceps","Fessiers","Ischio-jambiers"], difficulty:"Débutant",
    description:"Les fentes développent la force et l'équilibre des jambes de façon unilatérale.",
    instructions:["Debout, faire un grand pas en avant","Fléchir le genou avant jusqu'à 90°","Le genou arrière doit effleurer le sol","Remonter en poussant sur le pied avant"] },
  { id:10, name:"Gainage", category:"Abdominaux", muscles:["Core","Transverse","Obliques"], difficulty:"Débutant",
    description:"Le gainage renforce profondément le core et protège le bas du dos. Incontournable dans tout programme.",
    instructions:["En appui sur les avant-bras et les orteils, corps aligné","Contracter les abdominaux et les fessiers","Respirer normalement sans relâcher la contraction","Maintenir la position le plus longtemps possible"] },
];

const FP_WORKOUTS = [
  { id:1, name:"Push Day A", muscles:"Poitrine · Épaules · Triceps", duration:45, difficulty:"Intermédiaire",
    exercises:[
      { name:"Développé couché", sets:[{reps:8},{reps:8},{reps:6}] },
      { name:"Développé militaire", sets:[{reps:10},{reps:10},{reps:8}] },
      { name:"Dips", sets:[{reps:12},{reps:12},{reps:10}] },
      { name:"Curl biceps", sets:[{reps:12},{reps:12}] },
    ]},
  { id:2, name:"Pull Day A", muscles:"Dos · Biceps", duration:50, difficulty:"Intermédiaire",
    exercises:[
      { name:"Soulevé de terre", sets:[{reps:5},{reps:5},{reps:5}] },
      { name:"Tractions", sets:[{reps:8},{reps:8},{reps:6}] },
      { name:"Curl biceps", sets:[{reps:12},{reps:12},{reps:10}] },
    ]},
  { id:3, name:"Leg Day A", muscles:"Quadriceps · Fessiers · Ischio", duration:55, difficulty:"Avancé",
    exercises:[
      { name:"Squat", sets:[{reps:8},{reps:8},{reps:6},{reps:5}] },
      { name:"Fentes", sets:[{reps:12},{reps:12},{reps:10}] },
      { name:"Soulevé de terre roumain", sets:[{reps:10},{reps:10},{reps:8}] },
    ]},
  { id:4, name:"Full Body Débutant", muscles:"Corps entier", duration:35, difficulty:"Débutant",
    exercises:[
      { name:"Pompes", sets:[{reps:10},{reps:10},{reps:8}] },
      { name:"Squat", sets:[{reps:15},{reps:15},{reps:12}] },
      { name:"Fentes", sets:[{reps:10},{reps:10}] },
      { name:"Gainage", sets:[{reps:'30s'},{reps:'30s'},{reps:'30s'}] },
    ]},
  { id:5, name:"Upper Body", muscles:"Haut du corps", duration:40, difficulty:"Intermédiaire",
    exercises:[
      { name:"Développé couché", sets:[{reps:10},{reps:10},{reps:8}] },
      { name:"Tractions", sets:[{reps:8},{reps:8},{reps:6}] },
      { name:"Développé militaire", sets:[{reps:10},{reps:10}] },
      { name:"Curl biceps", sets:[{reps:12},{reps:12}] },
      { name:"Dips", sets:[{reps:15},{reps:15}] },
    ]},
];

const FP_INITIAL_PLANNING = [
  { id:1, workoutId:1, workoutName:"Push Day A", date:"2026-04-28", time:"18:00", muscles:"Poitrine · Épaules · Triceps", duration:45 },
  { id:2, workoutId:2, workoutName:"Pull Day A", date:"2026-04-30", time:"18:00", muscles:"Dos · Biceps", duration:50 },
  { id:3, workoutId:3, workoutName:"Leg Day A", date:"2026-05-02", time:"10:00", muscles:"Quadriceps · Fessiers", duration:55 },
];

const FP_INITIAL_CHAT = [
  { role:'assistant', text:"Bonjour ! Je suis CoachAI, ton assistant spécialisé en musculation. Comment puis-je t'aider aujourd'hui ?" },
  { role:'user', text:"Quels exercices pour gagner du dos rapidement ?" },
  { role:'assistant', text:"Pour développer ton dos rapidement, concentre-toi sur ces exercices fondamentaux :\n\n• **Tractions** — l'exercice roi pour le dos, travaille le grand dorsal en profondeur\n• **Soulevé de terre** — polyarticulaire, masse globale\n• **Rowing barre** — épaisseur du dos\n\nVise 3-4 séances/semaine en progression sur les charges. Tu veux que je te construise un programme ?" },
];

Object.assign(window, { FP_EXERCISES, FP_WORKOUTS, FP_INITIAL_PLANNING, FP_INITIAL_CHAT });
