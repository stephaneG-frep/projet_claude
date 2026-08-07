import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/content_providers.dart';
import '../../../theme/app_colors.dart';

/// Glossaire (section 26) : liste alphabétique avec recherche.
class GlossaryScreen extends ConsumerStatefulWidget {
  const GlossaryScreen({super.key});

  @override
  ConsumerState<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends ConsumerState<GlossaryScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final glossaryAsync = ref.watch(glossaryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Glossaire')),
      body: glossaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur : $e')),
        data: (terms) {
          final filtered = terms
              .where((t) => _query.isEmpty || t.term.toLowerCase().contains(_query.toLowerCase()))
              .toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Rechercher un terme…'),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final term = filtered[i];
                    return ListTile(
                      title: Text(term.term, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.cyan)),
                      subtitle: Text(term.definition),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
