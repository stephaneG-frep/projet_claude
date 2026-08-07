import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/content_providers.dart';
import '../../../theme/app_colors.dart';
import '../../progress/application/progress_controller.dart';

class ReferenceDetailScreen extends ConsumerWidget {
  final String name;
  const ReferenceDetailScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referenceAsync = ref.watch(referenceProvider);
    final isFavorite = ref.watch(progressControllerProvider).favoriteReferences.contains(name);

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_border, color: isFavorite ? AppColors.orange : null),
            onPressed: () => ref.read(progressControllerProvider.notifier).toggleFavoriteReference(name),
          ),
        ],
      ),
      body: referenceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur : $e')),
        data: (entries) {
          final matches = entries.where((e) => e.name == name);
          final entry = matches.isEmpty ? null : matches.first;
          if (entry == null) {
            return const Center(child: Text('Instruction introuvable.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section(title: 'Syntaxe', child: _Code(entry.syntax)),
              _Section(title: 'Description', child: Text(entry.description)),
              _Section(
                title: 'Registres concernés',
                child: Text(entry.registersInvolved.isEmpty ? 'Aucun' : entry.registersInvolved.join(', ')),
              ),
              _Section(
                title: 'Flags affectés',
                child: Text(entry.flagsAffected.isEmpty ? 'Aucun' : entry.flagsAffected.join(', ')),
              ),
              _Section(title: 'Exemple', child: _Code(entry.example)),
              _Section(title: 'Pièges fréquents', child: Text(entry.commonMistakes)),
              _Section(title: 'Architecture', child: Text(entry.architecture)),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.cyan)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _Code extends StatelessWidget {
  final String text;
  const _Code(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.surfaceSecondary, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(fontFamily: 'monospace')),
    );
  }
}
