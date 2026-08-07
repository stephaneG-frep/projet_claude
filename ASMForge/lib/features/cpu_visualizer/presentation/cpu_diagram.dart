import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

/// Visualisation du chemin des données (section 17) :
/// Registres → Bus → ALU → Mémoire.
///
/// [pulse] doit changer de valeur (ex : compteur de pas incrémenté) à
/// chaque instruction exécutée pour déclencher l'animation. Si
/// [animationsEnabled] est faux (section 33, réduction des animations),
/// le déplacement est affiché instantanément sans transition.
class CpuDiagram extends StatefulWidget {
  final int pulse;
  final bool animationsEnabled;
  final String stageLabel;

  const CpuDiagram({
    super.key,
    required this.pulse,
    required this.animationsEnabled,
    this.stageLabel = '',
  });

  @override
  State<CpuDiagram> createState() => _CpuDiagramState();
}

class _CpuDiagramState extends State<CpuDiagram> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didUpdateWidget(covariant CpuDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse != oldWidget.pulse) {
      if (widget.animationsEnabled) {
        _controller.forward(from: 0);
      } else {
        _controller.value = 1;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _stages = ['REGISTRES', 'BUS', 'ALU', 'MÉMOIRE'];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chemin des données', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;
                return LayoutBuilder(builder: (context, constraints) {
                  final segmentWidth = constraints.maxWidth / (_stages.length - 1);
                  final activeIndex = (t * (_stages.length - 1)).clamp(0, _stages.length - 1);
                  final dotX = activeIndex * segmentWidth;
                  return SizedBox(
                    height: 70,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 28,
                          left: 0,
                          right: 0,
                          child: Container(height: 2, color: Colors.white12),
                        ),
                        for (var i = 0; i < _stages.length; i++)
                          Positioned(
                            left: i * segmentWidth - 40,
                            top: 0,
                            width: 80,
                            child: Column(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: t >= i / (_stages.length - 1)
                                        ? AppColors.cyan
                                        : Colors.white24,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _stages[i],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        Positioned(
                          left: dotX - 6,
                          top: 22,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.executionGreen,
                              boxShadow: [
                                BoxShadow(color: AppColors.executionGreen, blurRadius: 8),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
              },
            ),
            if (widget.stageLabel.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.stageLabel,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
