# Guide du contenu pédagogique — ASMForge

Tout le contenu pédagogique d'ASMForge est stocké sous forme de données structurées dans `assets/content/`, jamais codé en dur dans les widgets (section 40/41 du cahier des charges). Ce document explique le format de chaque fichier pour permettre d'en ajouter ou d'en modifier sans toucher au code Dart.

## `modules/modules.json`

Liste de modules, chacun avec une liste de leçons :

```json
{
  "id": "module_4",
  "number": 4,
  "title": "Premières instructions",
  "description": "...",
  "lessons": [
    {
      "id": "m4_l1",
      "order": 1,
      "title": "MOV : copier une valeur",
      "blocks": [
        {"type": "paragraph", "text": "..."},
        {"type": "bullet", "text": "..."},
        {"type": "code", "text": "MOV RAX, 5"},
        {"type": "tip", "text": "..."},
        {"type": "warning", "text": "..."}
      ]
    }
  ]
}
```

Types de blocs (`ContentBlockType`) : `paragraph`, `bullet`, `code`, `tip`, `warning`. Les identifiants de leçon (`id`) doivent être uniques dans tout le fichier : ils sont référencés par `exercises.json` (`lessonId`) et par la progression de l'utilisateur (`completedLessons`).

## `exercises/exercises.json`

Chaque exercice a un `type` parmi : `qcm`, `fillBlank`, `predictResult`, `findError`, `reorder`, `writeProgram`. Le champ `lessonId` est optionnel (relie l'exercice à une leçon précise) ; `moduleId` est toujours requis.

Le champ `data` varie selon le type — voir `lib/features/exercises/presentation/exercise_card.dart` pour le détail exact attendu par chaque type, résumé ici :

| Type | Champs de `data` |
|---|---|
| `qcm` | `options` (liste), `correctIndex`, `explanation` |
| `fillBlank` | `template` (avec `___` comme trou), `correctAnswer`, `explanation` |
| `predictResult` | `code`, `question`, `correctAnswer`, `explanation` |
| `findError` | `code`, `options`, `correctIndex`, `explanation` |
| `reorder` | `lines` (ordre correct — mélangées à l'affichage), `explanation` |
| `writeProgram` | `instructions`, `starterCode`, `checks` (liste de `{register\|memoryAddress, expectedValue, description}`), `explanation` |

Pour les exercices `writeProgram`, le code de l'utilisateur est réellement exécuté par le simulateur (`core/simulator/program_runner.dart`), jamais évalué par une simple comparaison de texte.

## `missions/missions.json` et `projects/projects.json`

Structure très proche : `id`, `number`, `title`/`objective`, un `starterCode`, des `hints`, et des `checks` au même format que `writeProgram` ci-dessus. Les projets ajoutent `steps`, `solutionCode` et `solutionExplanation`.

**Important** : toute nouvelle mission ou tout nouveau projet doit avoir sa solution attendue vérifiée par un test (voir `test/simulator/mission_solutions_test.dart` et `test/simulator/project_solutions_test.dart`) — cela garantit que la mission est réellement réalisable avant d'être publiée.

## `reference/reference.json`

Une entrée par instruction supportée par le simulateur (voir `docs/SIMULATOR.md` pour la liste). Champs : `name`, `category`, `syntax`, `description`, `registersInvolved`, `flagsAffected`, `example`, `commonMistakes`, `architecture`.

## `glossary/glossary.json`

Liste simple de `{"term": "...", "definition": "..."}`, triée alphabétiquement à l'affichage (pas besoin de la trier dans le fichier).

## Ajouter du contenu

1. Éditez le fichier JSON concerné (les sous-dossiers de `assets/content/` sont déjà déclarés dans `pubspec.yaml`).
2. Validez la syntaxe JSON (par exemple `python3 -c "import json; json.load(open('chemin/du/fichier.json'))"`).
3. Si vous ajoutez une mission, un projet, ou un exercice `writeProgram`, ajoutez un test qui exécute la solution attendue à travers `runProgramToCompletion` pour vérifier qu'elle satisfait bien les `checks`.
4. Relancez `flutter test test/content_loading_test.dart` pour vérifier que le nouveau contenu se charge et se désérialise correctement.

## Internationalisation future

Tout le contenu est actuellement en français uniquement (section 2 du cahier des charges). Pour préparer une traduction anglaise future sans réécrire l'architecture, la recommandation est de dupliquer chaque fichier avec un suffixe de langue (par exemple `modules.en.json`) et de sélectionner le fichier chargé par `ContentRepository` selon la locale — le modèle de données (`LearningModule`, `Exercise`, etc.) n'a pas besoin de changer.
