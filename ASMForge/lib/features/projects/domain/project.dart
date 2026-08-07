import '../../missions/domain/mission.dart';

class Project {
  final String id;
  final int number;
  final String title;
  final String objective;
  final String explanation;
  final List<String> steps;
  final List<String> hints;
  final String solutionCode;
  final String solutionExplanation;
  final List<MissionCheck> checks;

  const Project({
    required this.id,
    required this.number,
    required this.title,
    required this.objective,
    required this.explanation,
    required this.steps,
    required this.hints,
    required this.solutionCode,
    required this.solutionExplanation,
    required this.checks,
  });

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'] as String,
        number: json['number'] as int,
        title: json['title'] as String,
        objective: json['objective'] as String,
        explanation: json['explanation'] as String,
        steps: (json['steps'] as List<dynamic>? ?? []).cast<String>(),
        hints: (json['hints'] as List<dynamic>? ?? []).cast<String>(),
        solutionCode: json['solutionCode'] as String,
        solutionExplanation: json['solutionExplanation'] as String,
        checks: (json['checks'] as List<dynamic>? ?? [])
            .map((c) => MissionCheck.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}
