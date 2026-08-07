/// État de progression de l'utilisateur, entièrement local (section 27,
/// hors ligne). Sérialisé en JSON pour SharedPreferences et pour
/// l'export/import (section 29).
class UserProgress {
  final Set<String> completedLessons;
  final Set<String> completedModules;
  final Set<String> milestones;
  final Set<String> completedExercises;
  final Map<String, int> exerciseScores;
  final Set<String> completedMissions;
  final Set<String> completedProjects;
  final Set<String> unlockedBadges;
  final Set<String> favoriteReferences;
  final int xp;
  final int arithmeticInstructionsRun;
  final int totalLearningSeconds;
  final DateTime? lastActivity;
  final bool onboardingCompleted;
  final String experienceLevel; // beginner | programmer | familiar

  const UserProgress({
    this.completedLessons = const {},
    this.completedModules = const {},
    this.milestones = const {},
    this.completedExercises = const {},
    this.exerciseScores = const {},
    this.completedMissions = const {},
    this.completedProjects = const {},
    this.unlockedBadges = const {},
    this.favoriteReferences = const {},
    this.xp = 0,
    this.arithmeticInstructionsRun = 0,
    this.totalLearningSeconds = 0,
    this.lastActivity,
    this.onboardingCompleted = false,
    this.experienceLevel = 'beginner',
  });

  int get level => 1 + (xp ~/ 200);
  int get xpIntoLevel => xp % 200;
  double get levelProgress => xpIntoLevel / 200;

  UserProgress copyWith({
    Set<String>? completedLessons,
    Set<String>? completedModules,
    Set<String>? milestones,
    Set<String>? completedExercises,
    Map<String, int>? exerciseScores,
    Set<String>? completedMissions,
    Set<String>? completedProjects,
    Set<String>? unlockedBadges,
    Set<String>? favoriteReferences,
    int? xp,
    int? arithmeticInstructionsRun,
    int? totalLearningSeconds,
    DateTime? lastActivity,
    bool? onboardingCompleted,
    String? experienceLevel,
  }) {
    return UserProgress(
      completedLessons: completedLessons ?? this.completedLessons,
      completedModules: completedModules ?? this.completedModules,
      milestones: milestones ?? this.milestones,
      completedExercises: completedExercises ?? this.completedExercises,
      exerciseScores: exerciseScores ?? this.exerciseScores,
      completedMissions: completedMissions ?? this.completedMissions,
      completedProjects: completedProjects ?? this.completedProjects,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      favoriteReferences: favoriteReferences ?? this.favoriteReferences,
      xp: xp ?? this.xp,
      arithmeticInstructionsRun:
          arithmeticInstructionsRun ?? this.arithmeticInstructionsRun,
      totalLearningSeconds: totalLearningSeconds ?? this.totalLearningSeconds,
      lastActivity: lastActivity ?? this.lastActivity,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      experienceLevel: experienceLevel ?? this.experienceLevel,
    );
  }

  Map<String, dynamic> toJson() => {
        'completedLessons': completedLessons.toList(),
        'completedModules': completedModules.toList(),
        'milestones': milestones.toList(),
        'completedExercises': completedExercises.toList(),
        'exerciseScores': exerciseScores,
        'completedMissions': completedMissions.toList(),
        'completedProjects': completedProjects.toList(),
        'unlockedBadges': unlockedBadges.toList(),
        'favoriteReferences': favoriteReferences.toList(),
        'xp': xp,
        'arithmeticInstructionsRun': arithmeticInstructionsRun,
        'totalLearningSeconds': totalLearningSeconds,
        'lastActivity': lastActivity?.toIso8601String(),
        'onboardingCompleted': onboardingCompleted,
        'experienceLevel': experienceLevel,
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
        completedLessons:
            Set<String>.from(json['completedLessons'] as List? ?? []),
        completedModules:
            Set<String>.from(json['completedModules'] as List? ?? []),
        milestones: Set<String>.from(json['milestones'] as List? ?? []),
        completedExercises:
            Set<String>.from(json['completedExercises'] as List? ?? []),
        exerciseScores:
            Map<String, int>.from(json['exerciseScores'] as Map? ?? {}),
        completedMissions:
            Set<String>.from(json['completedMissions'] as List? ?? []),
        completedProjects:
            Set<String>.from(json['completedProjects'] as List? ?? []),
        unlockedBadges:
            Set<String>.from(json['unlockedBadges'] as List? ?? []),
        favoriteReferences:
            Set<String>.from(json['favoriteReferences'] as List? ?? []),
        xp: json['xp'] as int? ?? 0,
        arithmeticInstructionsRun:
            json['arithmeticInstructionsRun'] as int? ?? 0,
        totalLearningSeconds: json['totalLearningSeconds'] as int? ?? 0,
        lastActivity: json['lastActivity'] != null
            ? DateTime.tryParse(json['lastActivity'] as String)
            : null,
        onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
        experienceLevel: json['experienceLevel'] as String? ?? 'beginner',
      );
}
