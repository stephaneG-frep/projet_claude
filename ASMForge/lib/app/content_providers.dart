import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/exercises/domain/exercise.dart';
import '../features/glossary/domain/glossary_term.dart';
import '../features/lessons/domain/module.dart';
import '../features/missions/domain/mission.dart';
import '../features/projects/domain/project.dart';
import '../features/reference/domain/reference_entry.dart';
import 'providers.dart';

final modulesProvider = FutureProvider<List<LearningModule>>((ref) {
  return ref.watch(contentRepositoryProvider).loadModules();
});

final exercisesProvider = FutureProvider<List<Exercise>>((ref) {
  return ref.watch(contentRepositoryProvider).loadExercises();
});

final missionsProvider = FutureProvider<List<Mission>>((ref) {
  return ref.watch(contentRepositoryProvider).loadMissions();
});

final projectsProvider = FutureProvider<List<Project>>((ref) {
  return ref.watch(contentRepositoryProvider).loadProjects();
});

final referenceProvider = FutureProvider<List<ReferenceEntry>>((ref) {
  return ref.watch(contentRepositoryProvider).loadReference();
});

final glossaryProvider = FutureProvider<List<GlossaryTerm>>((ref) {
  return ref.watch(contentRepositoryProvider).loadGlossary();
});
