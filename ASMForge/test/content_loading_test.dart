// Vérifie que tout le contenu pédagogique hors ligne (section 40) se
// charge et se désérialise correctement depuis assets/content/.
import 'package:asmforge/core/services/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repository = ContentRepository();

  test('charge au moins 10 modules avec des leçons non vides', () async {
    final modules = await repository.loadModules();
    expect(modules.length, greaterThanOrEqualTo(10));
    for (final module in modules) {
      expect(module.lessons, isNotEmpty, reason: 'Module ${module.id} sans leçon');
      for (final lesson in module.lessons) {
        expect(lesson.blocks, isNotEmpty, reason: 'Leçon ${lesson.id} sans contenu');
      }
    }
  });

  test('charge des exercices rattachés à des leçons existantes', () async {
    final modules = await repository.loadModules();
    final lessonIds = modules.expand((m) => m.lessons.map((l) => l.id)).toSet();
    final exercises = await repository.loadExercises();
    expect(exercises, isNotEmpty);
    for (final exercise in exercises) {
      if (exercise.lessonId != null) {
        expect(
          lessonIds.contains(exercise.lessonId),
          isTrue,
          reason: 'Exercice ${exercise.id} référence une leçon inconnue (${exercise.lessonId})',
        );
      }
    }
  });

  test('charge 8 missions avec au moins une vérification chacune', () async {
    final missions = await repository.loadMissions();
    expect(missions.length, 8);
    for (final mission in missions) {
      expect(mission.checks, isNotEmpty, reason: 'Mission ${mission.id} sans vérification');
    }
  });

  test('charge 8 mini-projets avec solution et vérifications', () async {
    final projects = await repository.loadProjects();
    expect(projects.length, 8);
    for (final project in projects) {
      expect(project.solutionCode, isNotEmpty);
      expect(project.checks, isNotEmpty);
    }
  });

  test('charge la référence des 21 instructions supportées', () async {
    final reference = await repository.loadReference();
    const expected = {
      'MOV', 'ADD', 'SUB', 'INC', 'DEC', 'MUL', 'DIV', 'CMP',
      'JMP', 'JE', 'JNE', 'JG', 'JL', 'JGE', 'JLE',
      'PUSH', 'POP', 'CALL', 'RET', 'NOP', 'HLT',
    };
    expect(reference.map((r) => r.name).toSet(), expected);
  });

  test('charge un glossaire non vide', () async {
    final glossary = await repository.loadGlossary();
    expect(glossary.length, greaterThanOrEqualTo(15));
  });
}
