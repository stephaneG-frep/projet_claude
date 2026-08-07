import '../../../core/simulator/program_runner.dart';

/// Vérification exécutée après le code écrit par l'utilisateur pour une
/// mission : compare l'état réel du simulateur à l'état attendu.
class MissionCheck {
  final String? register;
  final int? memoryAddress;
  final int expectedValue;
  final String description;

  const MissionCheck({
    this.register,
    this.memoryAddress,
    required this.expectedValue,
    required this.description,
  });

  factory MissionCheck.fromJson(Map<String, dynamic> json) => MissionCheck(
        register: json['register'] as String?,
        memoryAddress: json['memoryAddress'] as int?,
        expectedValue: json['expectedValue'] as int,
        description: json['description'] as String,
      );

  SimpleCheck toSimpleCheck() => SimpleCheck(
        register: register,
        memoryAddress: memoryAddress,
        expectedValue: expectedValue,
        description: description,
      );
}

class Mission {
  final String id;
  final int number;
  final String title;
  final String narrative;
  final String objective;
  final String starterCode;
  final List<String> hints;
  final List<MissionCheck> checks;

  const Mission({
    required this.id,
    required this.number,
    required this.title,
    required this.narrative,
    required this.objective,
    required this.starterCode,
    required this.hints,
    required this.checks,
  });

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
        id: json['id'] as String,
        number: json['number'] as int,
        title: json['title'] as String,
        narrative: json['narrative'] as String,
        objective: json['objective'] as String,
        starterCode: json['starterCode'] as String? ?? '',
        hints: (json['hints'] as List<dynamic>? ?? []).cast<String>(),
        checks: (json['checks'] as List<dynamic>? ?? [])
            .map((c) => MissionCheck.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}
