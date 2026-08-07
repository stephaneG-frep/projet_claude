import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/content_providers.dart';
import '../../../theme/app_colors.dart';
import '../../progress/application/progress_controller.dart';

/// Espace « Missions » (sections 7, 23, 24) : narration de The Forge /
/// CORE-01, avec un second onglet pour les mini-projets.
class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> with SingleTickerProviderStateMixin {
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
        title: const Text('Missions — CORE-01'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Missions'), Tab(text: 'Projets')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_MissionsTab(), _ProjectsTab()],
      ),
    );
  }
}

class _MissionsTab extends ConsumerWidget {
  const _MissionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionsAsync = ref.watch(missionsProvider);
    final progress = ref.watch(progressControllerProvider);

    return missionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Erreur : $e')),
      data: (missions) => ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: missions.length,
        itemBuilder: (context, i) {
          final mission = missions[i];
          final done = progress.completedMissions.contains(mission.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: done ? AppColors.executionGreen.withValues(alpha: 0.2) : AppColors.surfaceSecondary,
                child: Text('${mission.number}'),
              ),
              title: Text(mission.title),
              subtitle: Text(mission.objective, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: done ? const Icon(Icons.check_circle, color: AppColors.executionGreen) : const Icon(Icons.chevron_right),
              onTap: () => context.push('/missions/detail/${mission.id}'),
            ),
          );
        },
      ),
    );
  }
}

class _ProjectsTab extends ConsumerWidget {
  const _ProjectsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final progress = ref.watch(progressControllerProvider);

    return projectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Erreur : $e')),
      data: (projects) => ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: projects.length,
        itemBuilder: (context, i) {
          final project = projects[i];
          final done = progress.completedProjects.contains(project.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: done ? AppColors.executionGreen.withValues(alpha: 0.2) : AppColors.surfaceSecondary,
                child: Text('${project.number}'),
              ),
              title: Text(project.title),
              subtitle: Text(project.objective, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: done ? const Icon(Icons.check_circle, color: AppColors.executionGreen) : const Icon(Icons.chevron_right),
              onTap: () => context.push('/missions/project/${project.id}'),
            ),
          );
        },
      ),
    );
  }
}
