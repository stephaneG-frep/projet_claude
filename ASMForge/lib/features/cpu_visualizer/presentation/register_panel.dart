import 'package:flutter/material.dart';

import '../../../core/simulator/register_bank.dart';
import '../../../theme/app_colors.dart';

/// Affiche la banque de registres (section 13), avec mise en évidence de
/// ceux modifiés au dernier pas d'exécution (section 16).
class RegisterPanel extends StatelessWidget {
  final Map<String, int> registers;
  final Set<String> changed;

  const RegisterPanel({super.key, required this.registers, this.changed = const {}});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registres', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final name in RegisterBank.all)
                  _RegisterChip(
                    name: name,
                    value: registers[name] ?? 0,
                    highlighted: changed.contains(name),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterChip extends StatelessWidget {
  final String name;
  final int value;
  final bool highlighted;
  const _RegisterChip({required this.name, required this.value, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.executionGreen.withValues(alpha: 0.15)
            : AppColors.surfaceSecondary,
        border: Border.all(
          color: highlighted ? AppColors.executionGreen : Colors.white12,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            semanticsLabel: 'Registre $name',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            '$value',
            key: ValueKey('register_value_$name'),
            style: TextStyle(
              color: highlighted ? AppColors.executionGreen : AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
