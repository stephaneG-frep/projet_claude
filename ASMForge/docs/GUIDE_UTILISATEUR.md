# Guide utilisateur — ASMForge

Ce guide s'adresse à quelqu'un qui ne connaît pas Flutter : il explique comment installer et utiliser ASMForge en tant qu'application.

## Installation

1. Installez Flutter (voir [docs.flutter.dev](https://docs.flutter.dev)).
2. Ouvrez un terminal dans le dossier du projet ASMForge.
3. Exécutez `flutter pub get` pour installer les dépendances.
4. Exécutez `flutter run` pour lancer l'application sur un appareil ou un émulateur connecté (ou `flutter run -d chrome` pour l'ouvrir dans un navigateur).

## Premier lancement

Au premier démarrage, ASMForge affiche :

1. Un écran de démarrage (« splash »).
2. Une courte présentation en 5 écrans de ce que propose l'application.
3. Une question sur votre niveau (« Je débute complètement », « Je connais la programmation », « Je connais déjà un peu l'assembleur »). Ce choix n'adapte que les recommandations de départ : **tous les cours restent accessibles**, quel que soit votre choix.
4. Le tableau de bord (Accueil).

## Navigation

L'application comporte cinq espaces, accessibles en bas de l'écran (mobile) ou sur le côté (tablette/desktop/web large) :

- **Accueil** : votre tableau de bord — niveau, XP, progression, badges, raccourcis vers le cours et la mission en cours.
- **Apprendre** : les modules de cours (onglet « Modules ») et l'encyclopédie des instructions (onglet « Référence »).
- **Laboratoire** : l'éditeur assembleur et le simulateur CPU.
- **Missions** : les missions narratives de restauration de CORE-01 (onglet « Missions ») et les mini-projets (onglet « Projets »).
- **Profil** : vos statistiques, vos badges, et l'accès aux Paramètres, à propos, et au Glossaire.

## Suivre un cours

Dans l'onglet **Apprendre → Modules**, chaque module se déplie pour afficher ses leçons. Une leçon terminée peut être marquée comme telle avec le bouton « Marquer comme terminé », ce qui vous rapporte de l'expérience (XP). Certaines leçons se terminent par un ou plusieurs exercices à réaliser directement sous le contenu.

## Utiliser le Laboratoire

Le Laboratoire est un vrai petit environnement de programmation assembleur :

- **Éditeur** (à gauche, ou en haut sur mobile) : écrivez votre code. Chaque ligne a un numéro ; cliquez sur un numéro de ligne pour poser ou retirer un point d'arrêt (marqué par un point rouge).
- **Run** : exécute le programme en continu, en s'arrêtant automatiquement sur un point d'arrêt ou à la fin du programme.
- **Step** : exécute une seule instruction à la fois — idéal pour bien comprendre chaque étape.
- **Pause** : interrompt une exécution en cours (mode Run).
- **Reset** : réinitialise complètement l'état du processeur (registres, flags, mémoire, pile) sans toucher au code.
- **Console d'exécution** : affiche, après chaque instruction, une explication en français de ce qui vient de se passer.

À droite (ou en dessous sur mobile), vous trouverez :

- Le **diagramme du chemin des données** (Registres → Bus → ALU → Mémoire), animé à chaque instruction.
- Le panneau **Registres**, avec en vert ceux modifiés par la dernière instruction.
- Le panneau **Flags** (ZF, CF, SF, OF), avec un symbole plein/vide et le nom complet de chaque drapeau.
- Le **Stack Viewer**, qui montre la pile de haut en bas, RSP pointant toujours vers le sommet.
- Le **Memory Viewer**, avec un choix d'affichage HEX / DEC / BIN.

## Missions et projets

Chaque mission de l'onglet **Missions** propose un éditeur intégré : écrivez votre solution, puis cliquez sur « Vérifier la mission ». ASMForge exécute votre code et compare automatiquement l'état final (registres, mémoire) à ce qui est attendu. Des indices sont disponibles si vous êtes bloqué. Vous pouvez aussi ouvrir votre code dans le Laboratoire complet pour l'exécuter pas à pas.

Les mini-projets (onglet **Projets**) fonctionnent de la même façon, avec en plus une solution commentée que vous pouvez révéler à tout moment.

## Sauvegarde et restauration de la progression

Toute votre progression (leçons, exercices, missions, projets, XP, badges, paramètres) est enregistrée automatiquement sur votre appareil, sans connexion internet ni compte requis.

Dans **Profil → Paramètres → Données**, vous pouvez :

- **Exporter vos données** : une fenêtre affiche un texte JSON que vous pouvez copier dans le presse-papiers (par exemple pour le sauvegarder dans un fichier texte vous-même, ou le transférer sur un autre appareil).
- **Importer des données** : collez un export JSON précédemment copié pour restaurer une progression.
- **Réinitialiser la progression** : efface définitivement toute votre progression après confirmation.

## Paramètres

Dans **Profil → Paramètres**, vous pouvez ajuster :

- Les animations (les réduire si elles vous distraient ou pour économiser des ressources).
- Le contraste renforcé et la taille du texte, pour améliorer la lisibilité.
- Le son et les vibrations (avec un bouton pour tester chacun).
- Le niveau d'assistance : Guidé (beaucoup d'explications), Standard, ou Expert (interface plus compacte).

## Besoin d'aide sur un terme ou une instruction ?

- L'onglet **Apprendre → Référence** liste toutes les instructions supportées par le simulateur, avec leur syntaxe, leur description, les registres et flags concernés, un exemple, et les pièges fréquents. Vous pouvez les marquer en favori.
- Le **Glossaire** (accessible depuis Profil) définit tous les termes techniques utilisés dans l'application.
