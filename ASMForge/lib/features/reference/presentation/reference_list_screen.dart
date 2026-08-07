import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/content_providers.dart';
import '../../../theme/app_colors.dart';
import '../../progress/application/progress_controller.dart';
import '../domain/reference_entry.dart';

/// Encyclopédie locale des instructions (section 25) : recherche, filtres
/// par catégorie, favoris.
class ReferenceListScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const ReferenceListScreen({super.key, this.embedded = false});

  @override
  ConsumerState<ReferenceListScreen> createState() => _ReferenceListScreenState();
}

class _ReferenceListScreenState extends ConsumerState<ReferenceListScreen> {
  String _query = '';
  String? _category;
  bool _onlyFavorites = false;

  @override
  Widget build(BuildContext context) {
    final referenceAsync = ref.watch(referenceProvider);
    final progress = ref.watch(progressControllerProvider);

    final body = referenceAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Référence indisponible : $e')),
      data: (entries) {
        final categories = entries.map((e) => e.category).toSet().toList()..sort();
        var filtered = entries.where((e) {
          final matchesQuery = _query.isEmpty ||
              e.name.toLowerCase().contains(_query.toLowerCase()) ||
              e.description.toLowerCase().contains(_query.toLowerCase());
          final matchesCategory = _category == null || e.category == _category;
          final matchesFavorite = !_onlyFavorites || progress.favoriteReferences.contains(e.name);
          return matchesQuery && matchesCategory && matchesFavorite;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Rechercher une instruction…',
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  FilterChip(
                    label: const Text('★ Favoris'),
                    selected: _onlyFavorites,
                    onSelected: (v) => setState(() => _onlyFavorites = v),
                  ),
                  const SizedBox(width: 8),
                  for (final c in categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: _category == c,
                        onSelected: (v) => setState(() => _category = v ? c : null),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('Aucune instruction ne correspond.', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => _ReferenceTile(entry: filtered[i]),
                    ),
            ),
          ],
        );
      },
    );

    if (widget.embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Référence')), body: body);
  }
}

class _ReferenceTile extends ConsumerWidget {
  final ReferenceEntry entry;
  const _ReferenceTile({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(progressControllerProvider).favoriteReferences.contains(entry.name);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(entry.name, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
        subtitle: Text(entry.category),
        trailing: IconButton(
          icon: Icon(isFavorite ? Icons.star : Icons.star_border, color: isFavorite ? AppColors.orange : null),
          onPressed: () => ref.read(progressControllerProvider.notifier).toggleFavoriteReference(entry.name),
        ),
        onTap: () => context.push('/learn/reference/${entry.name}'),
      ),
    );
  }
}
