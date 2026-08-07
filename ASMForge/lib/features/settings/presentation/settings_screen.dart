import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../theme/app_colors.dart';
import '../../progress/application/progress_controller.dart';
import '../application/app_settings.dart';
import '../application/settings_controller.dart';

/// Paramètres (section 42) : animations, son, vibrations, taille du
/// texte, contraste, niveau d'assistance, réinitialisation, export/import.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final notifier = ref.read(settingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          const _SectionHeader('Affichage'),
          SwitchListTile(
            title: const Text('Animations'),
            subtitle: const Text('Réduire les animations du simulateur et du CPU'),
            value: settings.animationsEnabled,
            onChanged: notifier.setAnimationsEnabled,
          ),
          SwitchListTile(
            title: const Text('Contraste renforcé'),
            value: settings.highContrast,
            onChanged: notifier.setHighContrast,
          ),
          ListTile(
            title: const Text('Taille du texte'),
            subtitle: Slider(
              value: settings.textScale,
              min: 0.85,
              max: 1.4,
              divisions: 11,
              label: '${(settings.textScale * 100).round()}%',
              onChanged: notifier.setTextScale,
            ),
          ),
          const _SectionHeader('Retour sensoriel'),
          SwitchListTile(
            title: const Text('Son'),
            value: settings.soundEnabled,
            onChanged: notifier.setSoundEnabled,
            secondary: IconButton(
              icon: const Icon(Icons.volume_up_outlined),
              tooltip: 'Tester le son',
              onPressed: settings.soundEnabled ? () => SystemSound.play(SystemSoundType.click) : null,
            ),
          ),
          SwitchListTile(
            title: const Text('Vibrations'),
            value: settings.vibrationEnabled,
            onChanged: notifier.setVibrationEnabled,
            secondary: IconButton(
              icon: const Icon(Icons.vibration),
              tooltip: 'Tester la vibration',
              onPressed: settings.vibrationEnabled ? () => HapticFeedback.mediumImpact() : null,
            ),
          ),
          const _SectionHeader('Niveau d\'assistance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<AssistanceLevel>(
              segments: const [
                ButtonSegment(value: AssistanceLevel.guided, label: Text('Guidé')),
                ButtonSegment(value: AssistanceLevel.standard, label: Text('Standard')),
                ButtonSegment(value: AssistanceLevel.expert, label: Text('Expert')),
              ],
              selected: {settings.assistanceLevel},
              onSelectionChanged: (s) => notifier.setAssistanceLevel(s.first),
            ),
          ),
          const _SectionHeader('Données'),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Exporter mes données'),
            subtitle: const Text('Copie un export JSON dans le presse-papiers'),
            onTap: () => _exportData(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Importer des données'),
            subtitle: const Text('Colle un export JSON ASMForge'),
            onTap: () => _importData(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt, color: AppColors.errorRed),
            title: const Text('Réinitialiser la progression', style: TextStyle(color: AppColors.errorRed)),
            onTap: () => _confirmReset(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final json = ref.read(exportImportServiceProvider).exportToJson();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export ASMForge'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: SelectableText(json, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: json));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copié dans le presse-papiers.')),
              );
            },
            child: const Text('Copier'),
          ),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fermer')),
        ],
      ),
    );
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importer des données'),
        content: SizedBox(
          width: 480,
          child: TextField(
            controller: controller,
            maxLines: 10,
            decoration: const InputDecoration(hintText: 'Collez ici votre export JSON ASMForge…'),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Importer')),
        ],
      ),
    );
    if (result == null || result.trim().isEmpty) return;
    final error = await ref.read(exportImportServiceProvider).importFromJson(result);
    ref.read(progressControllerProvider.notifier).reloadFromStorage();
    ref.read(settingsControllerProvider.notifier).reloadFromStorage();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Import réussi.')),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser la progression ?'),
        content: const Text(
          'Toute votre progression (leçons, exercices, missions, projets, XP, badges) sera définitivement effacée.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(progressControllerProvider.notifier).resetProgress();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: AppColors.cyan, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }
}
