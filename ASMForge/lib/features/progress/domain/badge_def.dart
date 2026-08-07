/// Définition statique d'un badge (section 28). Le déblocage est calculé
/// dynamiquement par [BadgeEvaluator] à partir de [UserProgress].
class BadgeDef {
  final String id;
  final String name;
  final String description;
  final String emoji;

  const BadgeDef({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
  });
}

const List<BadgeDef> kAllBadges = [
  BadgeDef(
    id: 'premier_bit',
    name: 'Premier Bit',
    description: 'Terminer sa toute première leçon.',
    emoji: '🔹',
  ),
  BadgeDef(
    id: 'hex_master',
    name: 'Hex Master',
    description: 'Terminer le module Binaire et hexadécimal.',
    emoji: '🔢',
  ),
  BadgeDef(
    id: 'register_rookie',
    name: 'Register Rookie',
    description: 'Terminer le module Registres.',
    emoji: '🧩',
  ),
  BadgeDef(
    id: 'alu_apprentice',
    name: 'ALU Apprentice',
    description: 'Exécuter avec succès 10 instructions arithmétiques.',
    emoji: '⚙️',
  ),
  BadgeDef(
    id: 'loop_breaker',
    name: 'Loop Breaker',
    description: 'Écrire et exécuter une boucle qui se termine correctement.',
    emoji: '🔁',
  ),
  BadgeDef(
    id: 'stack_master',
    name: 'Stack Master',
    description: 'Réussir la mission de reconstruction de la pile.',
    emoji: '📚',
  ),
  BadgeDef(
    id: 'memory_explorer',
    name: 'Memory Explorer',
    description: 'Lire et écrire dans la mémoire simulée depuis le laboratoire.',
    emoji: '🗺️',
  ),
  BadgeDef(
    id: 'zero_flag',
    name: 'Zero Flag',
    description: 'Provoquer volontairement l\'activation du flag ZF.',
    emoji: '🚩',
  ),
  BadgeDef(
    id: 'assembly_smith',
    name: 'Assembly Smith',
    description: 'Terminer 5 mini-projets.',
    emoji: '🛠️',
  ),
  BadgeDef(
    id: 'master_of_the_forge',
    name: 'Master of the Forge',
    description: 'Terminer toutes les missions de CORE-01.',
    emoji: '🔥',
  ),
];
