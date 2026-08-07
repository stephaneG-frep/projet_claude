import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/storage/progress_repository.dart';
import '../domain/badge_def.dart';
import '../domain/user_progress.dart';
import 'badge_evaluator.dart';

class ProgressController extends Notifier<UserProgress> {
  late final ProgressRepository _repository;

  @override
  UserProgress build() {
    _repository = ref.watch(progressRepositoryProvider);
    return _repository.load();
  }

  void _commit(UserProgress next) {
    state = next;
    _repository.save(next);
  }

  UserProgress _touchActivity(UserProgress p) =>
      p.copyWith(lastActivity: DateTime.now());

  /// Réévalue les badges et retourne ceux nouvellement débloqués, pour
  /// que l'UI puisse afficher une notification (section 28).
  List<BadgeDef> _refreshBadges(UserProgress before, UserProgress after, {
    int totalMissionsCount = 0,
  }) {
    final unlocked = BadgeEvaluator.computeUnlocked(
      after,
      totalMissionsCount: totalMissionsCount,
    );
    final newly = BadgeEvaluator.newlyUnlocked(before.unlockedBadges, unlocked);
    _commit(after.copyWith(unlockedBadges: unlocked));
    return newly;
  }

  List<BadgeDef> completeLesson(String lessonId) {
    final before = state;
    final next = _touchActivity(state.copyWith(
      completedLessons: {...state.completedLessons, lessonId},
      xp: state.xp + 20,
    ));
    return _refreshBadges(before, next);
  }

  void markModuleCompleted(String moduleId) {
    _commit(state.copyWith(
      completedModules: {...state.completedModules, moduleId},
    ));
  }

  List<BadgeDef> completeExercise(String exerciseId, {required bool correct}) {
    final before = state;
    final scores = Map<String, int>.from(state.exerciseScores);
    scores[exerciseId] = (scores[exerciseId] ?? 0) + (correct ? 1 : 0);
    final next = _touchActivity(state.copyWith(
      completedExercises: {...state.completedExercises, exerciseId},
      exerciseScores: scores,
      xp: state.xp + (correct ? 15 : 5),
    ));
    return _refreshBadges(before, next);
  }

  List<BadgeDef> completeMission(String missionId, {int totalMissionsCount = 8}) {
    final before = state;
    final next = _touchActivity(state.copyWith(
      completedMissions: {...state.completedMissions, missionId},
      xp: state.xp + 50,
    ));
    return _refreshBadges(before, next, totalMissionsCount: totalMissionsCount);
  }

  List<BadgeDef> completeProject(String projectId) {
    final before = state;
    final next = _touchActivity(state.copyWith(
      completedProjects: {...state.completedProjects, projectId},
      xp: state.xp + 40,
    ));
    return _refreshBadges(before, next);
  }

  List<BadgeDef> recordArithmeticInstructions(int count) {
    final before = state;
    final next = state.copyWith(
      arithmeticInstructionsRun: state.arithmeticInstructionsRun + count,
    );
    return _refreshBadges(before, next);
  }

  List<BadgeDef> recordMilestone(String milestoneKey) {
    if (state.milestones.contains(milestoneKey)) return [];
    final before = state;
    final next = state.copyWith(
      milestones: {...state.milestones, milestoneKey},
    );
    return _refreshBadges(before, next);
  }

  void addLearningSeconds(int seconds) {
    _commit(state.copyWith(
      totalLearningSeconds: state.totalLearningSeconds + seconds,
    ));
  }

  void toggleFavoriteReference(String name) {
    final favorites = Set<String>.from(state.favoriteReferences);
    if (favorites.contains(name)) {
      favorites.remove(name);
    } else {
      favorites.add(name);
    }
    _commit(state.copyWith(favoriteReferences: favorites));
  }

  void completeOnboarding(String experienceLevel) {
    _commit(state.copyWith(
      onboardingCompleted: true,
      experienceLevel: experienceLevel,
    ));
  }

  Future<void> resetProgress() async {
    await _repository.reset();
    state = const UserProgress();
  }

  void reloadFromStorage() => state = _repository.load();
}

final progressControllerProvider =
    NotifierProvider<ProgressController, UserProgress>(
  ProgressController.new,
);
