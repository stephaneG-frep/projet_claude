import 'dart:convert';

import '../../../core/storage/progress_repository.dart';
import '../../../core/storage/settings_repository.dart';
import '../../progress/domain/user_progress.dart';
import 'app_settings.dart';

/// Export/import JSON de la progression et des paramètres (section 29).
///
/// Choix pragmatique : l'export produit une chaîne JSON que l'utilisateur
/// copie dans le presse-papiers, et l'import la relit depuis un champ de
/// texte collé. Un vrai sélecteur de fichier natif demanderait des
/// permissions et une configuration spécifique par plateforme
/// (Android/Web/Linux/Windows) qui dépasserait le cadre fiable de cette
/// version ; le presse-papiers reste une alternative simple et fiable sur
/// toutes les plateformes ciblées.
class ExportImportService {
  final ProgressRepository progressRepository;
  final SettingsRepository settingsRepository;

  const ExportImportService(this.progressRepository, this.settingsRepository);

  String exportToJson() {
    final payload = {
      'asmforge_export_version': 1,
      'progress': progressRepository.load().toJson(),
      'settings': settingsRepository.load().toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  /// Retourne `null` en cas de succès, ou un message d'erreur pédagogique.
  Future<String?> importFromJson(String raw) async {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return 'Le contenu collé n\'est pas un export ASMForge valide '
            '(un objet JSON était attendu).';
      }
      if (decoded['progress'] is Map<String, dynamic>) {
        final progress = UserProgress.fromJson(
          decoded['progress'] as Map<String, dynamic>,
        );
        await progressRepository.save(progress);
      }
      if (decoded['settings'] is Map<String, dynamic>) {
        final settings = AppSettings.fromJson(
          decoded['settings'] as Map<String, dynamic>,
        );
        await settingsRepository.save(settings);
      }
      return null;
    } catch (e) {
      return 'Impossible de lire cet export : le texte collé n\'est pas '
          'un JSON ASMForge valide.';
    }
  }
}
