import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Écran À propos (section 43).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.memory, size: 56, color: AppColors.cyan),
          const SizedBox(height: 12),
          Text('ASMForge', style: Theme.of(context).textTheme.headlineMedium),
          const Text(
            'Comprendre la machine, instruction après instruction.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          const _InfoTile(label: 'Version', value: '1.0.0'),
          const _InfoTile(
            label: 'Technologies utilisées',
            value: 'Flutter, Dart, Riverpod, go_router, shared_preferences',
          ),
          const SizedBox(height: 20),
          Text('Licences', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'ASMForge est un logiciel pédagogique. Il utilise des paquets '
            'open source sous licence BSD/MIT (Flutter, Riverpod, go_router, '
            'shared_preferences). Consultez la licence de chaque dépendance '
            'via la commande « flutter pub deps » ou pub.dev.',
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Licences open source'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'ASMForge',
              applicationVersion: '1.0.0',
            ),
          ),
          const SizedBox(height: 20),
          Text('Crédits', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            'Conçu et développé comme projet pédagogique complet pour '
            'l\'apprentissage de l\'assembleur x86-64, avec des notions '
            'introductives ARM64 et RISC-V.',
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Text(value),
        ],
      ),
    );
  }
}
