import 'package:flutter/material.dart';

import '../../../core/simulator/stack_manager.dart';
import '../../../theme/app_colors.dart';

/// Stack Viewer vertical (section 19) : le sommet (RSP) est en haut,
/// chaque PUSH ajoute une ligne visuellement au sommet.
class StackViewer extends StatelessWidget {
  final List<StackEntry> entries;

  const StackViewer({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pile', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (entries.isEmpty)
              const Text(
                'Pile vide.',
                style: TextStyle(color: AppColors.textSecondary),
              )
            else
              ...List.generate(entries.length, (i) {
                final e = entries[i];
                final isTop = i == 0;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isTop
                        ? AppColors.orange.withValues(alpha: 0.15)
                        : AppColors.surfaceSecondary,
                    border: Border.all(
                      color: isTop ? AppColors.orange : Colors.white12,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0x${e.address.toRadixString(16).padLeft(4, '0')}',
                        style: const TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary),
                      ),
                      Text(
                        '${e.value}',
                        style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                      ),
                      if (isTop)
                        const Text(
                          'RSP →',
                          style: TextStyle(color: AppColors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
