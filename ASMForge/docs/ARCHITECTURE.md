# Architecture — ASMForge

## Principe général

ASMForge suit une architecture **feature-first** : chaque fonctionnalité possède son propre dossier sous `lib/features/`, avec ses propres sous-dossiers `domain/` (modèles), `data/` (accès aux données, si nécessaire), `application/` (logique et état, contrôleurs Riverpod) et `presentation/` (widgets/écrans). Les couches transverses vivent dans `lib/core/`.

```
lib/
  app/
    app.dart                # MaterialApp.router, branchement du thème dynamique
    router.dart              # Toutes les routes (go_router)
    providers.dart           # Providers de bas niveau (stockage, dépôts)
    content_providers.dart   # FutureProvider par type de contenu pédagogique

  theme/
    app_colors.dart           # Palette centralisée (The Forge)
    app_theme.dart            # ThemeData unique, Material 3

  core/
    simulator/                # Moteur CPU — voir docs/SIMULATOR.md
    services/content_repository.dart   # Chargement des JSON de assets/content/
    storage/                  # SharedPreferences + dépôts (progression, paramètres)
    widgets/responsive_shell.dart      # NavigationBar / NavigationRail responsive

  features/
    onboarding/   home/   lessons/   exercises/
    simulator/    editor/  cpu_visualizer/  memory/  stack/
    missions/     projects/  reference/  glossary/
    progress/     settings/
```

## Pourquoi cette organisation

- **Le moteur (`core/simulator/`) ne dépend de rien dans Flutter.** Il est testable en isolation (voir `test/simulator/`, `test/parser/`) et pourrait être réutilisé tel quel dans un autre contexte (CLI, autre framework).
- **Les écrans ne contiennent jamais la logique du simulateur.** Le Laboratoire (`features/simulator/presentation/lab_screen.dart`) délègue tout à `LabController` (`features/simulator/application/lab_controller.dart`), qui lui-même pilote un `CpuSimulator`. L'UI ne fait que lire un `LabState` immuable et appeler des méthodes (`run`, `step`, `pause`, `reset`).
- **Le contenu pédagogique est une donnée, pas du code.** Modules, leçons, exercices, missions, projets, référence et glossaire sont des fichiers JSON dans `assets/content/`, chargés par `ContentRepository` puis désérialisés vers des modèles Dart immuables (`lib/features/*/domain/`).

## État et state management

L'application utilise **Riverpod** (`flutter_riverpod`), avec des `Notifier` explicites plutôt que des `StateNotifier` legacy :

- `SettingsController` — paramètres utilisateur (section 42), persistés via `SettingsRepository`.
- `ProgressController` — progression complète (leçons, exercices, missions, projets, XP, badges), persistée via `ProgressRepository`. Réévalue les badges (`BadgeEvaluator`) après chaque mutation.
- `LabController` — état du Laboratoire (source, registres/flags/pile affichés, console, points d'arrêt), pilotant un `CpuSimulator` interne.

Le contenu pédagogique est exposé via des `FutureProvider` (`app/content_providers.dart`), mis en cache par `ContentRepository` après le premier chargement.

## Routage

**go_router** est utilisé avec un `StatefulShellRoute.indexedStack` pour la navigation principale (Accueil / Apprendre / Laboratoire / Missions / Profil), ce qui préserve l'état de chaque onglet lors des changements de navigation. Les écrans de détail (leçon, mission, projet, référence, paramètres, à propos, glossaire) sont des routes imbriquées, poussées avec `context.push(...)`.

## Stockage local

`shared_preferences` a été choisi car maintenu activement et compatible nativement avec Android, Web, Linux et Windows sans configuration native supplémentaire — contrainte du cahier des charges (section 29). La progression et les paramètres sont sérialisés en JSON dans deux clés distinctes. L'export/import (section 29) réutilise ce même format JSON.

## Accessibilité et thème

Un unique `ThemeData` (`AppTheme.dark`) centralise toutes les couleurs (`AppColors`) : aucun widget ne code une couleur en dur. Le contraste renforcé et l'échelle de texte définis dans les Paramètres influencent directement la construction de ce `ThemeData` et du `MediaQuery` englobant (voir `app/app.dart`).

## Limites assumées de cette architecture

- Pas de couche `data/` séparée pour les fonctionnalités qui ne font que lire du contenu statique (référence, glossaire, missions, projets) : le `ContentRepository` unique suffit et évite une sur-ingénierie pour un contenu qui ne change jamais à l'exécution.
- Les vérifications de missions/projets/exercices « Écrire le programme » partagent une même brique (`core/simulator/program_runner.dart`) plutôt que d'être dupliquées trois fois.
