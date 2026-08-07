enum ExerciseType { qcm, fillBlank, predictResult, findError, reorder, writeProgram }

/// Un exercice pédagogique. `data` porte les champs spécifiques au type,
/// volontairement en `Map` pour rester une simple structure de données
/// sérialisable en JSON (assets/content/exercises/).
class Exercise {
  final String id;
  final String moduleId;
  final String? lessonId;
  final ExerciseType type;
  final String prompt;
  final String concept;
  final Map<String, dynamic> data;

  const Exercise({
    required this.id,
    required this.moduleId,
    this.lessonId,
    required this.type,
    required this.prompt,
    required this.concept,
    required this.data,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['id'] as String,
        moduleId: json['moduleId'] as String,
        lessonId: json['lessonId'] as String?,
        type: ExerciseType.values.firstWhere((t) => t.name == json['type']),
        prompt: json['prompt'] as String,
        concept: json['concept'] as String? ?? '',
        data: Map<String, dynamic>.from(json['data'] as Map),
      );
}
