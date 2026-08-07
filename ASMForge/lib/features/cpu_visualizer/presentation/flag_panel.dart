import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';

/// Affiche ZF/CF/SF/OF (section 14) avec une légende accessible : l'état
/// n'est jamais transmis uniquement par la couleur (section 33), un
/// symbole plein/vide et un libellé texte l'accompagnent toujours.
class FlagPanel extends StatelessWidget {
  final Map<String, bool> flags;

  const FlagPanel({super.key, required this.flags});

  static const _legend = {
    'ZF': 'Zero — résultat nul',
    'CF': 'Carry — retenue/emprunt',
    'SF': 'Sign — résultat négatif',
    'OF': 'Overflow — dépassement signé',
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Flags', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 10,
              children: [
                for (final entry in _legend.entries)
                  Tooltip(
                    message: entry.value,
                    child: Semantics(
                      label: '${entry.key} ${flags[entry.key] == true ? "actif" : "inactif"} : ${entry.value}',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            flags[entry.key] == true
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 16,
                            color: flags[entry.key] == true
                                ? SimColors.flagSet
                                : SimColors.flagUnset,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: flags[entry.key] == true
                                  ? AppColors.executionGreen
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
