class GlossaryTerm {
  final String term;
  final String definition;
  const GlossaryTerm({required this.term, required this.definition});

  factory GlossaryTerm.fromJson(Map<String, dynamic> json) => GlossaryTerm(
        term: json['term'] as String,
        definition: json['definition'] as String,
      );
}
