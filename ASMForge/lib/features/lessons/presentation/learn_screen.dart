import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/content_providers.dart';
import '../../../theme/app_colors.dart';
import '../../progress/application/progress_controller.dart';
import '../../reference/presentation/reference_list_screen.dart';

/// Espace « Apprendre » (section 7) : modules structurés + référence.
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apprendre'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Modules'),
            Tab(text: 'Référence'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ModulesTab(),
          ReferenceListScreen(embedded: true),
        ],
      ),
    );
  }
}

class _ModulesTab extends ConsumerWidget {
  const _ModulesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(modulesProvider);
    final progress = ref.watch(progressControllerProvider);

    return modulesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Impossible de charger les modules : $e')),
      data: (modules) {
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: modules.length,
          itemBuilder: (context, i) {
            final module = modules[i];
            final done = module.lessons.where((l) => progress.completedLessons.contains(l.id)).length;
            final total = module.lessons.length;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                title: Text('Module ${module.number} — ${module.title}'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(module.description),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : done / total,
                          minHeight: 5,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    ],
                  ),
                ),
                children: [
                  for (final lesson in module.lessons)
                    ListTile(
                      leading: Icon(
                        progress.completedLessons.contains(lesson.id)
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: progress.completedLessons.contains(lesson.id)
                            ? AppColors.executionGreen
                            : AppColors.textSecondary,
                      ),
                      title: Text(lesson.title),
                      onTap: () => context.push('/learn/lesson/${module.id}/${lesson.id}'),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
