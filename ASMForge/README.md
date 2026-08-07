# ASMForge

**Comprendre la machine, instruction après instruction.**

ASMForge est une application Flutter complète et fonctionnelle pour apprendre l'assembleur en partant de zéro : fonctionnement d'un ordinateur, binaire/hexadécimal, CPU, registres, flags, mémoire, pile, fonctions, jusqu'à des notions comparatives sur ARM64 et RISC-V.

L'application est organisée autour de cinq espaces : **Accueil**, **Apprendre**, **Laboratoire**, **Missions** et **Profil**.

## Fonctionnalités

- **Parcours pédagogique complet** : 15 modules (Module 0 à 14), avec des leçons rédigées, des exemples et des mises en garde sur les pièges fréquents.
- **Laboratoire assembleur réel** : éditeur avec coloration syntaxique, numéros de ligne, points d'arrêt, et un véritable interpréteur pédagogique (`CpuSimulator`) — Run, Step, Pause, Reset.
- **Simulateur CPU** : registres 64 bits (RAX, RBX, RCX, RDX, RSI, RDI, RSP, RBP, RIP), flags (ZF, CF, SF, OF), mémoire simulée de 4 Ko, pile LIFO, 21 instructions supportées (MOV, ADD, SUB, INC, DEC, MUL, DIV, CMP, JMP, JE, JNE, JG, JL, JGE, JLE, PUSH, POP, CALL, RET, NOP, HLT).
- **Visualisations** : diagramme Registres → Bus → ALU → Mémoire animé, Memory Viewer (HEX/DEC/BIN), Stack Viewer.
- **Explications automatiques** générées localement (aucune IA externe) après chaque instruction exécutée.
- **Exercices** : QCM, compléter le code, prédire le résultat, trouver l'erreur, réorganiser, écrire le programme (vérifié en exécutant réellement le code dans le simulateur).
- **Missions narratives** (« The Forge » / CORE-01) : 8 missions, chacune vérifiée automatiquement.
- **Mini-projets** : 8 projets guidés avec indices et solution commentée.
- **Encyclopédie de référence** et **glossaire**, avec recherche et favoris.
- **Progression locale complète** : XP, niveaux, badges, statistiques, sans compte ni backend obligatoire. Export/import JSON.
- **Accessibilité** : réduction des animations, contraste renforcé, taille de texte ajustable, niveaux d'assistance Guidé/Standard/Expert.
- **Responsive** : navigation par barre en bas sur mobile, `NavigationRail` sur tablette/desktop/web large.

## Architecture

Voir [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) pour le détail. En résumé, une architecture feature-first :

```
lib/
  app/          # Point d'entrée applicatif, routing (go_router), providers Riverpod
  theme/        # ThemeData centralisé (Material 3)
  core/
    simulator/  # Moteur CPU indépendant de l'UI (parser, registres, flags, mémoire, pile)
    services/   # Chargement du contenu pédagogique (assets/content/)
    storage/    # Persistance locale (SharedPreferences)
    widgets/    # Widgets partagés (shell responsive)
  features/     # Un dossier par fonctionnalité (onboarding, home, lessons, exercises,
                # simulator, editor, cpu_visualizer, memory, stack, missions, projects,
                # reference, glossary, progress, settings)
```

## Prérequis

- Flutter 3.44+ (canal stable), Dart 3.12+.
- Pour un build Linux desktop : `clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`.
- Pour un build Windows : Visual Studio avec le workload « Développement Desktop en C++ » (build à réaliser sur une machine Windows ; le SDK Flutter ne permet pas de compiler un exécutable Windows depuis Linux).

## Installation

```bash
flutter pub get
```

## Lancement

```bash
flutter run                 # sur l'appareil/l'émulateur par défaut
flutter run -d chrome       # Web
flutter run -d linux        # Linux desktop (nécessite les outils ci-dessus)
```

## Tests

```bash
flutter test
```

La suite couvre notamment : le moteur du simulateur (parsing, registres, flags, mémoire, pile, sauts, fonctions, gestion d'erreurs), le chargement de tout le contenu pédagogique, et les solutions de référence des 8 missions, des 8 mini-projets et des exercices « Écrire le programme » — exécutées à travers le même moteur que l'application, afin de garantir qu'elles sont réellement validables.

## Builds

```bash
flutter build apk --debug     # Android (build de référence de ce projet)
flutter build web             # Web
flutter build linux           # Linux desktop (nécessite les outils système listés ci-dessus)
flutter build windows         # à réaliser sur une machine Windows
```

## Structure du projet

```
lib/            Code source Dart/Flutter
assets/content/ Contenu pédagogique hors ligne (JSON) : modules, exercices, missions, projets, référence, glossaire
test/           Tests automatisés
docs/           Documentation détaillée
android/ web/ linux/ windows/   Projets de plateforme générés par Flutter
```

## Limitations connues

- Le simulateur est un **interpréteur pédagogique isolé** : il n'assemble ni n'exécute de code machine natif, n'effectue aucun appel système (`SYSCALL` n'est pas simulé) et n'accède ni au système de fichiers, ni au réseau (voir [docs/SIMULATOR.md](docs/SIMULATOR.md)).
- `MUL`/`DIV` simplifient le comportement réel x86-64 (pas de véritable paire `RDX:RAX` à 128 bits) : voir la Référence dans l'application et `docs/SIMULATOR.md` pour le détail exact.
- Sur le Web, les entiers Dart perdent leur précision native 64 bits au-delà de 2^53 (limite de la plateforme JavaScript, pas du simulateur lui-même).
- Les modules 11 à 14 (NASM/Linux, C et assembleur, ARM64, RISC-V) sont des introductions comparatives, pas des simulateurs complets pour ces architectures.
- L'export/import de données utilise le presse-papiers plutôt qu'un sélecteur de fichiers natif, afin de rester fiable de façon identique sur Android, Web, Linux et Windows sans configuration spécifique par plateforme.
- Le build Linux desktop nécessite des paquets système (`clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`) qui peuvent ne pas être installés par défaut. Le build Windows ne peut être produit que sur une machine Windows.

## Licence

Projet pédagogique. Voir l'écran « À propos » dans l'application pour le détail des dépendances et leurs licences respectives.
