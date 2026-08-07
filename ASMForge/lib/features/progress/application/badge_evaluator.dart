import '../domain/badge_def.dart';
import '../domain/user_progress.dart';

/// Calcule quels badges devraient être débloqués au vu de [progress].
/// Pure fonction, testable indépendamment de l'UI.
class BadgeEvaluator {
  BadgeEvaluator._();

  static Set<String> computeUnlocked(UserProgress progress, {
    required int totalMissionsCount,
  }) {
    final unlocked = <String>{};

    if (progress.completedLessons.isNotEmpty) unlocked.add('premier_bit');
    if (progress.completedModules.contains('module_1')) {
      unlocked.add('hex_master');
    }
    if (progress.completedModules.contains('module_3')) {
      unlocked.add('register_rookie');
    }
    if (progress.arithmeticInstructionsRun >= 10) {
      unlocked.add('alu_apprentice');
    }
    if (progress.milestones.contains('loop_executed')) {
      unlocked.add('loop_breaker');
    }
    if (progress.completedMissions.contains('mission_05')) {
      unlocked.add('stack_master');
    }
    if (progress.milestones.contains('memory_write_done')) {
      unlocked.add('memory_explorer');
    }
    if (progress.milestones.contains('zero_flag_triggered')) {
      unlocked.add('zero_flag');
    }
    if (progress.completedProjects.length >= 5) {
      unlocked.add('assembly_smith');
    }
    if (totalMissionsCount > 0 &&
        progress.completedMissions.length >= totalMissionsCount) {
      unlocked.add('master_of_the_forge');
    }

    return unlocked;
  }

  static List<BadgeDef> newlyUnlocked(Set<String> before, Set<String> after) {
    final diff = after.difference(before);
    return kAllBadges.where((b) => diff.contains(b.id)).toList();
  }
}
