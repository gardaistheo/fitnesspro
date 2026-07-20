# Cahier de recette — FitnessPro

## Objectif

Élaborer le cahier de recettes en rédigeant les scénarios de tests et les résultats attendus afin de détecter les anomalies de fonctionnement et les régressions éventuelles, avant mise en production (déploiement Render pour le backend, publication store/TestFlight pour le mobile).

## Périmètre

- **Backend** : API REST Laravel (authentification, exercices, programmes, séances d'entraînement, repas, abonnements/webhook RevenueCat).
- **Mobile** : application Flutter (onboarding, dashboard, programmes, planning, scanner alimentaire, gestion de compte/abonnement).
- **Hors périmètre** : Coach IA (non implémenté — écran placeholder), intégration réelle Passio.ai (actuellement mockée côté mobile).

## Environnements de test

| Environnement | Backend | Mobile |
|---|---|---|
| Local | Laravel (SQLite/PostgreSQL local) | Émulateur/simulateur + build debug |
| Staging | Render (branche `develop`) | Build interne (TestFlight/APK debug) |
| Production | Render (branche `main`) | Store (release) |

## Prérequis avant recette

- Base de données migrée et seedée (utilisateur admin, catalogue d'exercices, programmes de démonstration).
- Compte de test standard + compte de test admin.
- Sandbox RevenueCat configurée (compte de test avec produits sandbox App Store/Play Store).
- Variables d'environnement backend renseignées (`REVENUECAT_WEBHOOK_SECRET`, connexion DB, `APP_URL`).

## Légende des statuts

- ✅ Conforme — 🔴 Anomalie bloquante — 🟠 Anomalie mineure — ⚪ Non testé

---

## 1. Authentification (Backend + Mobile)

### 1.1 Inscription

| ID | Scénario | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| AUTH-01 | Inscription réussie | Écran Signup → saisir nom, email valide, mot de passe (≥8 car.) + confirmation → valider | Compte créé, token Sanctum émis, redirection vers `/paywall` | |
| AUTH-02 | Email déjà utilisé | S'inscrire avec un email existant | Erreur 422 affichée, aucun compte créé en double | |
| AUTH-03 | Mot de passe trop court | Saisir un mot de passe < 8 caractères | Erreur de validation bloquante, formulaire non soumis | |
| AUTH-04 | Mot de passe et confirmation différents | Saisir deux mots de passe différents | Erreur de validation, inscription refusée | |
| AUTH-05 | Champs obligatoires vides | Soumettre le formulaire vide | Bouton de soumission désactivé ou erreurs affichées sur chaque champ requis | |
| AUTH-06 | Email au format invalide | Saisir `test@`, `abc`, etc. | Erreur de validation format email | |

### 1.2 Connexion

| ID | Scénario | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| AUTH-07 | Connexion réussie | Écran Login → identifiants valides | Token émis, redirection directe vers `/dashboard` (sans quiz/paywall) | |
| AUTH-08 | Mot de passe incorrect | Email valide + mauvais mot de passe | Erreur 401, message générique (pas de fuite d'info sur l'existence du compte) | |
| AUTH-09 | Compte inexistant | Email non enregistré | Erreur 401, message générique | |
| AUTH-10 | Session persistée après fermeture app | Se connecter, fermer et rouvrir l'app | Session restaurée automatiquement (`restoreSession`), pas de re-login demandé | |
| AUTH-11 | Redirection selon statut abonnement | Se connecter avec compte non-Pro déconnecté | Redirection vers `/paywall-recheck` | |

### 1.3 Déconnexion / Session

| ID | Scénario | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| AUTH-12 | Déconnexion | Menu compte (dashboard) → Déconnexion | Token révoqué côté serveur, retour à l'écran Landing, token local supprimé | |
| AUTH-13 | Appel API avec token invalide/expiré | Appeler `GET /auth/me` avec un token révoqué | 401 Unauthorized | |
| AUTH-14 | Récupération du profil courant | `GET /auth/me` avec token valide | Retourne les informations de l'utilisateur connecté | |

---

## 2. Onboarding (Quiz + Paywall)

| ID | Scénario | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| ONB-01 | Parcours quiz complet — entraînement à domicile | Nouveau compte → répondre à toutes les étapes en sélectionnant "maison" | 7 étapes affichées (avec matériel disponible), progression jusqu'aux slides d'onboarding | |
| ONB-02 | Parcours quiz complet — hors domicile | Sélectionner un lieu autre que "maison" | 6 étapes affichées (pas d'étape matériel) | |
| ONB-03 | Navigation retour dans le quiz | Avancer de 2-3 étapes puis revenir en arrière | Réponses précédemment saisies conservées | |
| ONB-04 | Slides d'onboarding | Terminer le quiz | 4 slides affichées, navigation possible, accès dashboard en fin de parcours | |
| ONB-05 | Paywall après inscription | Nouveau compte → écran paywall | Offres RevenueCat affichées correctement (sandbox) | |
| ONB-06 | Achat réussi sur paywall | Sélectionner une offre → achat sandbox validé | `isPro` passe à `true`, accès dashboard débloqué | |
| ONB-07 | Achat annulé | Annuler l'achat sur le paywall natif | Retour à l'état précédent, pas de blocage de l'app | |
| ONB-08 | Restauration d'achats | Utilisateur ayant déjà acheté → "Restaurer les achats" | Statut Pro restauré sans nouvel achat | |
| ONB-09 | Re-vérification paywall au lancement | Relancer l'app avec session non-Pro | Écran `/paywall-recheck` affiché, option de passer (skip) disponible | |

---

## 3. Dashboard

| ID | Scénario | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| DASH-01 | Affichage prochaine séance planifiée | Avoir une séance planifiée dans le futur → ouvrir dashboard | La séance la plus proche s'affiche avec date/heure/programme corrects | |
| DASH-02 | Aucune séance planifiée | Aucune séance en base → ouvrir dashboard | Message/état vide cohérent (pas de crash, pas de séance fictive affichée) | |
| DASH-03 | Menu compte accessible | Dashboard → ouvrir le menu compte | Options "Gérer l'abonnement" et "Déconnexion" visibles et fonctionnelles | |
| DASH-04 | Navigation vers les onglets | Depuis le shell principal, naviguer entre Dashboard / Coach IA / Scanner / Exercices / Séances | Chaque onglet charge l'écran correspondant sans erreur | |
| DASH-05 | Cohérence des données affichées (hydratation/calories) | Observer les valeurs affichées | ⚠️ Non testable fonctionnellement en l'état : valeurs actuellement statiques (non liées à une saisie utilisateur réelle) — à vérifier lors de l'implémentation du suivi réel | |

---

## 4. Catalogue d'exercices

| ID | Scénario | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| EXO-01 | Liste des exercices | Onglet Exercices | Liste paginée affichée (50 items max par page côté API) | |
| EXO-02 | Filtre par catégorie | Sélectionner une catégorie (ex : "Jambes") | Seuls les exercices de cette catégorie s'affichent | |
| EXO-03 | Filtre par difficulté | Sélectionner un niveau de difficulté | Résultats filtrés correctement | |
| EXO-04 | Combinaison de filtres | Catégorie + difficulté simultanément | Résultats respectant les deux critères | |
| EXO-05 | Détail d'un exercice | Cliquer sur un exercice | Affiche description, muscles ciblés, instructions, vidéo YouTube intégrée | |
| EXO-06 | Lecture vidéo (format watch) | Ouvrir un exercice avec URL `youtube.com/watch?v=...` | Vidéo se charge correctement | |
| EXO-07 | Lecture vidéo (format court) | Ouvrir un exercice avec URL `youtu.be/...` | Vidéo se charge correctement | |
| EXO-08 | Exercice inexistant (API) | `GET /exercises/{id}` avec id invalide | 404 retourné | |
| EXO-09 | Accès sans authentification | Appeler `/exercises` sans token | 401 Unauthorized | |

---

## 5. Programmes d'entraînement

| ID | Scénario | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| PROG-01 | Liste des programmes | Onglet Séances/Workouts | Liste des programmes affichée | |
| PROG-02 | Filtre par difficulté | Sélectionner un niveau | Programmes filtrés correctement | |
| PROG-03 | Détail d'un programme | Ouvrir un programme | Liste des exercices associés affichée avec séries/répétitions/ordre | |
| PROG-04 | Création d'un programme (admin) | Compte admin → `POST /programs` avec données valides | Programme créé (201) | |
| PROG-05 | Création refusée (non-admin) | Compte standard → `POST /programs` | 403 Forbidden, aucun programme créé | |
| PROG-06 | Modification d'un programme (admin) | `PUT /programs/{id}` | Modifications enregistrées | |
| PROG-07 | Modification refusée (non-admin) | Compte standard → `PUT /programs/{id}` | 403 Forbidden | |
| PROG-08 | Suppression d'un programme (admin) | `DELETE /programs/{id}` | Programme supprimé (204), plus visible en liste | |
| PROG-09 | Suppression refusée (non-admin) | Compte standard → `DELETE /programs/{id}` | 403 Forbidden | |
| PROG-10 | Validation création — champs manquants | `POST /programs` sans `name`/`difficulty` | 422 avec erreurs de validation | |
| PROG-11 | Validation — difficulté hors enum | `difficulty: "extreme"` | 422 rejeté | |

---

## 6. Planning / Séances d'entraînement

| ID | Scénario | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| PLAN-01 | Ajout d'une séance planifiée | Planning → sélectionner programme + date future + heure | Séance créée, visible groupée par date | |
| PLAN-02 | Blocage date passée (UI) | Tenter de sélectionner une date antérieure à aujourd'hui | Sélecteur de date bloque les dates passées | |
| PLAN-03 | Blocage date passée (API) | `POST /workout-sessions` avec `scheduled_date` dans le passé | 422 rejeté | |
| PLAN-04 | Modification du statut d'une séance | `PUT /workout-sessions/{id}` avec `status: completed` | Statut mis à jour, `completed_at` renseigné | |
| PLAN-05 | Modifier une séance passée pour la marquer complétée | Séance planifiée à une date passée → passer en "complétée" | Autorisé (contrairement à la création, la mise à jour n'interdit pas les dates passées) | |
| PLAN-06 | Suppression d'une séance | Planning → supprimer une séance | Séance retirée de la liste et de la base | |
| PLAN-07 | Accès aux séances d'un autre utilisateur | Utilisateur A tente `GET/PUT/DELETE /workout-sessions/{id-de-B}` | 403 Forbidden | |
| PLAN-08 | Filtre par statut | `GET /workout-sessions?status=planned` | Seules les séances planifiées retournées | |
| PLAN-09 | Groupement par date (UI) | Avoir plusieurs séances sur des jours différents | Affichage correctement groupé/trié par date | |

---

## 7. Suivi alimentaire (Repas + Scanner)

| ID | Scénario | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| MEAL-01 | Log manuel d'un repas | Saisie manuelle nom + calories | Repas enregistré, apparaît dans l'historique | |
| MEAL-02 | Macros par défaut | Log sans préciser protéines/glucides/lipides | Valeurs par défaut à 0, pas d'erreur | |
| MEAL-03 | Validation champs requis | Log sans `name` ou `calories` | 422 rejeté | |
| MEAL-04 | Liste des repas filtrée par date | `GET /meals?from=...&to=...` | Seuls les repas dans la plage retournés | |
| MEAL-05 | Scoping utilisateur | Utilisateur A ne voit pas les repas de B | Liste strictement limitée à l'utilisateur connecté | |
| MEAL-06 | Scanner photo (mock) | Onglet Scanner → prendre/choisir une photo | Résultat simulé affiché après délai (fonctionnalité en mode mock, résultat non représentatif d'une vraie reconnaissance) | |
| MEAL-07 | Repli saisie manuelle depuis le scanner | Scanner → basculer en saisie clavier | Clavier numérique fonctionnel, valeurs saisies correctement transmises au log | |

---

## 8. Abonnement / Webhook RevenueCat

| ID | Scénario | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| SUB-01 | Webhook achat initial | Envoyer événement `INITIAL_PURCHASE` avec secret valide | Abonnement activé (`is_active = true`) pour l'utilisateur concerné | |
| SUB-02 | Webhook renouvellement | Événement `RENEWAL` | Abonnement reste/redevient actif | |
| SUB-03 | Webhook annulation d'annulation | Événement `UNCANCELLATION` | Abonnement réactivé | |
| SUB-04 | Webhook changement de produit | Événement `PRODUCT_CHANGE` | Abonnement mis à jour, reste actif | |
| SUB-05 | Webhook expiration | Événement `EXPIRATION` | Abonnement désactivé (`is_active = false`) | |
| SUB-06 | Webhook annulation | Événement `CANCELLATION` | Abonnement désactivé | |
| SUB-07 | Signature/secret invalide | Requête webhook sans le bon secret | 401/403, aucune donnée modifiée | |
| SUB-08 | Événement type inconnu | Type d'événement non reconnu | Requête traitée sans erreur, aucun effet secondaire indésirable | |
| SUB-09 | Utilisateur inconnu | Webhook référence un `app_user_id` inexistant | Pas de crash, requête gérée proprement (ignorée ou log) | |
| SUB-10 | Idempotence | Renvoyer deux fois le même événement | Aucun doublon d'effet (état final identique) | |
| SUB-11 | Restriction fonctionnalité si non-Pro | Compte non-Pro → tenter d'accéder au contenu premium | Redirection vers paywall | |

---

## 9. Thème (Light/Dark)

| ID | Scénario | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| THM-01 | Suivi du thème système | OS en mode sombre → ouvrir l'app | App s'affiche en thème sombre | |
| THM-02 | Bascule manuelle du thème | Changer le thème dans les paramètres | Thème appliqué immédiatement sur tous les écrans | |
| THM-03 | Persistance du thème choisi | Changer le thème, fermer/rouvrir l'app | Préférence conservée | |

---

## 10. Sécurité et robustesse (transverses)

| ID | Scénario | Étapes | Résultat attendu | Statut |
|---|---|---|---|---|
| SEC-01 | Rate limiting login | Multiplier les tentatives de connexion échouées | Blocage temporaire après seuil (throttle) | |
| SEC-02 | Rate limiting register | Multiplier les tentatives d'inscription | Blocage temporaire après seuil | |
| SEC-03 | Injection / entrées malveillantes | Saisir des payloads type script/SQL dans les champs texte (nom, repas, etc.) | Aucune exécution/injection, données échappées ou rejetées | |
| SEC-04 | Stockage sécurisé du token mobile | Inspecter le stockage local du token | Token stocké via FlutterSecureStorage (pas en clair dans les préférences) | |
| SEC-05 | HTTPS en production | Appeler l'API en HTTP simple sur l'environnement de prod | Requête refusée/redirigée en HTTPS | |
| SEC-06 | Pas de logs sensibles | Vérifier les logs mobile en build release | Aucun token/mot de passe/donnée sensible dans les logs | |
| SEC-07 | Perte de connexion réseau | Couper le réseau pendant une action (dashboard, planning) | Message d'erreur clair, pas de crash, données en cache affichées si disponibles (offline-first séances) | |

---

## 11. Non-régression (à rejouer à chaque livraison)

| ID | Scénario | Résultat attendu | Statut |
|---|---|---|---|
| REG-01 | Suite de tests backend Pest (`./vendor/bin/pest --coverage`) | Tous les tests passent, couverture ≥ 70% | |
| REG-02 | Suite de tests Flutter (`flutter test --coverage`) | Tous les tests passent, couverture ≥ 50% | |
| REG-03 | Lint backend (`pint --test`, `phpstan analyse`) | Aucune erreur de style/typage | |
| REG-04 | Lint mobile (`flutter analyze`, `dart format --set-exit-if-changed`) | Aucune erreur | |
| REG-05 | Pipeline CI GitHub Actions (backend + mobile) | Les deux workflows passent au vert sur la PR | |
| REG-06 | Parcours complet bout-en-bout | Inscription → paywall → quiz → dashboard → planifier une séance → logger un repas → déconnexion → reconnexion | Aucune régression sur l'enchaînement complet |

---

## Synthèse de recette

| Module | Nb. scénarios | Bloquants détectés | Mineurs détectés | Statut global |
|---|---|---|---|---|
| Authentification | 14 | | | ⚪ |
| Onboarding | 9 | | | ⚪ |
| Dashboard | 5 | | | ⚪ |
| Exercices | 9 | | | ⚪ |
| Programmes | 11 | | | ⚪ |
| Planning | 9 | | | ⚪ |
| Alimentation | 7 | | | ⚪ |
| Abonnement/Webhook | 11 | | | ⚪ |
| Thème | 3 | | | ⚪ |
| Sécurité | 7 | | | ⚪ |
| Non-régression | 6 | | | ⚪ |

## Notes de recette

- **Coach IA** : fonctionnalité non implémentée (écran placeholder "Bientôt disponible") — hors périmètre de cette recette tant que le scope n'est pas confirmé (cf. points ouverts CLAUDE.md).
- **Scanner alimentaire (Passio.ai)** : intégration actuellement mockée côté mobile. Les scénarios MEAL-06 valident uniquement le comportement du mock, pas une reconnaissance alimentaire réelle. À revalider intégralement lors du branchement du SDK réel.
- **Valeurs dashboard (hydratation/calories)** : actuellement statiques dans le code, non connectées à une source de données réelle — DASH-05 à réévaluer une fois la fonctionnalité de suivi effectivement implémentée.

---

*Document à mettre à jour à chaque nouvelle fonctionnalité livrée. Renseigner la colonne Statut lors de chaque campagne de recette (date + testeur à consigner en en-tête de campagne).*
