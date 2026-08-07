# Contribuer à ASMForge

## Principes

- **Fonctionnement réel avant tout** : n'importe quel bouton principal doit faire ce qu'il annonce. Pas de faux bouton, pas de « Coming soon ».
- **Le moteur du simulateur reste indépendant de Flutter.** Toute nouvelle instruction ou tout nouveau comportement doit être ajouté dans `lib/core/simulator/` et couvert par un test avant d'être exposé dans l'UI.
- **Le contenu pédagogique est une donnée**, pas du code Dart (voir `docs/CONTENT_GUIDE.md`).
- **Aucune couleur codée en dur** dans les widgets : passez par `lib/theme/app_colors.dart` et `lib/theme/app_theme.dart`.

## Mettre en place l'environnement

```bash
flutter pub get
flutter analyze
flutter test
```

## Ajouter une instruction au simulateur

1. Ajoutez le mnémonique dans `lib/core/simulator/opcode.dart` (`Opcode` enum, `arity`, `category`).
2. Implémentez son exécution dans `CpuSimulator._execute` (`lib/core/simulator/cpu_simulator.dart`).
3. Ajoutez sa validation d'opérandes dans `AssemblyParser._validateOperandTypes`.
4. Ajoutez son explication dans `ExplanationGenerator.explain`.
5. Écrivez des tests dans `test/simulator/cpu_simulator_test.dart` couvrant le cas nominal **et** au moins un cas d'erreur.
6. Ajoutez une entrée dans `assets/content/reference/reference.json`.
7. Ne l'exposez dans le Laboratoire qu'une fois ces étapes terminées (section 15 du cahier des charges : « Ajouter les instructions seulement lorsque leur comportement est correctement testé »).

## Ajouter une leçon, un exercice, une mission ou un projet

Voir `docs/CONTENT_GUIDE.md`. Pour une mission ou un projet, ajoutez systématiquement un test qui exécute la solution de référence à travers `runProgramToCompletion` (`lib/core/simulator/program_runner.dart`) et vérifie ses `checks`.

## Style de code

- Architecture feature-first (voir `docs/ARCHITECTURE.md`) : un nouvel écran ou une nouvelle logique doit vivre dans `lib/features/<nom>/{domain,application,presentation}`.
- State management via Riverpod (`Notifier`/`NotifierProvider`), jamais de logique métier directement dans un widget.
- Routing via `go_router` (`lib/app/router.dart`).
- Pas de dépendance ajoutée sans vérifier sa compatibilité avec Android, Web, Linux et Windows (contrainte du cahier des charges, section 29).

## Avant de proposer un changement

```bash
flutter analyze   # aucune erreur bloquante
flutter test      # tous les tests passent
```

Si vous ajoutez une dépendance à `pubspec.yaml`, exécutez `flutter pub get` et vérifiez qu'elle ne casse pas les builds Android/Web (au minimum).
