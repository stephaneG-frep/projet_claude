class ReferenceEntry {
  final String name;
  final String category;
  final String syntax;
  final String description;
  final List<String> registersInvolved;
  final List<String> flagsAffected;
  final String example;
  final String commonMistakes;
  final String architecture;

  const ReferenceEntry({
    required this.name,
    required this.category,
    required this.syntax,
    required this.description,
    required this.registersInvolved,
    required this.flagsAffected,
    required this.example,
    required this.commonMistakes,
    required this.architecture,
  });

  factory ReferenceEntry.fromJson(Map<String, dynamic> json) => ReferenceEntry(
        name: json['name'] as String,
        category: json['category'] as String,
        syntax: json['syntax'] as String,
        description: json['description'] as String,
        registersInvolved:
            (json['registersInvolved'] as List<dynamic>? ?? []).cast<String>(),
        flagsAffected:
            (json['flagsAffected'] as List<dynamic>? ?? []).cast<String>(),
        example: json['example'] as String,
        commonMistakes: json['commonMistakes'] as String,
        architecture: json['architecture'] as String? ?? 'x86-64',
      );
}
