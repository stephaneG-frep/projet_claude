/// Un bloc de contenu textuel simple pour une leçon : évite de dépendre
/// d'un moteur Markdown externe tout en gardant un minimum de mise en
/// forme (titres, listes, code) pour un contenu agréable à lire.
enum ContentBlockType { paragraph, bullet, code, tip, warning }

class ContentBlock {
  final ContentBlockType type;
  final String text;
  const ContentBlock(this.type, this.text);

  factory ContentBlock.fromJson(Map<String, dynamic> json) => ContentBlock(
        ContentBlockType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => ContentBlockType.paragraph,
        ),
        json['text'] as String,
      );
}

class Lesson {
  final String id;
  final String moduleId;
  final String title;
  final int order;
  final List<ContentBlock> blocks;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.order,
    required this.blocks,
  });

  factory Lesson.fromJson(String moduleId, Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      moduleId: moduleId,
      title: json['title'] as String,
      order: json['order'] as int? ?? 0,
      blocks: (json['blocks'] as List<dynamic>? ?? [])
          .map((b) => ContentBlock.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LearningModule {
  final String id;
  final int number;
  final String title;
  final String description;
  final List<Lesson> lessons;

  const LearningModule({
    required this.id,
    required this.number,
    required this.title,
    required this.description,
    required this.lessons,
  });

  factory LearningModule.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    return LearningModule(
      id: id,
      number: json['number'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      lessons: (json['lessons'] as List<dynamic>? ?? [])
          .map((l) => Lesson.fromJson(id, l as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order)),
    );
  }
}
