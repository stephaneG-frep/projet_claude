import 'package:flutter/material.dart';

import '../../../core/simulator/memory_manager.dart';
import '../../../theme/app_colors.dart';

enum MemoryBase { hex, dec, bin }

/// Memory Viewer (section 18) : Adresse | Valeur, avec bascule HEX/DEC/BIN.
/// N'affiche qu'une fenêtre autour d'une adresse d'intérêt pour rester
/// lisible sur mobile (4 Ko complets seraient illisibles à l'écran).
class MemoryViewer extends StatefulWidget {
  final MemoryManager memory;
  final int focusAddress;
  final Set<int> recentlyWritten;

  const MemoryViewer({
    super.key,
    required this.memory,
    this.focusAddress = 0,
    this.recentlyWritten = const {},
  });

  @override
  State<MemoryViewer> createState() => _MemoryViewerState();
}

class _MemoryViewerState extends State<MemoryViewer> {
  MemoryBase _base = MemoryBase.hex;
  late int _windowStart;

  @override
  void initState() {
    super.initState();
    _windowStart = (widget.focusAddress ~/ 16) * 16;
  }

  @override
  void didUpdateWidget(covariant MemoryViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.recentlyWritten.isNotEmpty) {
      _windowStart = (widget.recentlyWritten.first ~/ 16) * 16;
    }
  }

  String _format(int value) {
    switch (_base) {
      case MemoryBase.hex:
        return '0x${value.toRadixString(16).padLeft(2, '0').toUpperCase()}';
      case MemoryBase.dec:
        return value.toString().padLeft(3, ' ');
      case MemoryBase.bin:
        return value.toRadixString(2).padLeft(8, '0');
    }
  }

  void _shiftWindow(int delta) {
    setState(() {
      _windowStart = (_windowStart + delta).clamp(0, MemoryManager.size - 16);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Mémoire', style: Theme.of(context).textTheme.titleMedium),
                ),
                SegmentedButton<MemoryBase>(
                  segments: const [
                    ButtonSegment(value: MemoryBase.hex, label: Text('HEX')),
                    ButtonSegment(value: MemoryBase.dec, label: Text('DEC')),
                    ButtonSegment(value: MemoryBase.bin, label: Text('BIN')),
                  ],
                  selected: {_base},
                  onSelectionChanged: (s) => setState(() => _base = s.first),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  tooltip: 'Adresses précédentes',
                  onPressed: () => _shiftWindow(-16),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '0x${_windowStart.toRadixString(16).padLeft(4, '0')} '
                  '→ 0x${(_windowStart + 15).toRadixString(16).padLeft(4, '0')}',
                  style: const TextStyle(fontFamily: 'monospace', color: AppColors.textSecondary),
                ),
                IconButton(
                  tooltip: 'Adresses suivantes',
                  onPressed: () => _shiftWindow(16),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisExtent: 44,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: 16,
                itemBuilder: (context, i) {
                  final addr = _windowStart + i;
                  final value = widget.memory.readByte(addr);
                  final isRecent = widget.recentlyWritten.contains(addr);
                  return Container(
                    decoration: BoxDecoration(
                      color: isRecent
                          ? AppColors.executionGreen.withValues(alpha: 0.15)
                          : AppColors.surfaceSecondary,
                      border: Border.all(
                        color: isRecent ? AppColors.executionGreen : Colors.white12,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '0x${addr.toRadixString(16).padLeft(4, '0')}',
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontFamily: 'monospace'),
                          maxLines: 1,
                        ),
                        Text(
                          _format(value),
                          style: const TextStyle(fontSize: 13, fontFamily: 'monospace', color: AppColors.textPrimary),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
