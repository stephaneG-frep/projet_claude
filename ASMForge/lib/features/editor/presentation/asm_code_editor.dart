import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import 'asm_syntax_controller.dart';

/// Éditeur assembleur avec numéros de ligne, coloration syntaxique et
/// points d'arrêt cliquables dans la marge (section 11).
class AsmCodeEditor extends StatefulWidget {
  final AsmSyntaxController controller;
  final bool readOnly;
  final int? highlightedLine;
  final Set<int> breakpoints;
  final ValueChanged<int>? onToggleBreakpoint;

  const AsmCodeEditor({
    super.key,
    required this.controller,
    this.readOnly = false,
    this.highlightedLine,
    this.breakpoints = const {},
    this.onToggleBreakpoint,
  });

  @override
  State<AsmCodeEditor> createState() => _AsmCodeEditorState();
}

class _AsmCodeEditorState extends State<AsmCodeEditor> {
  final ScrollController _scroll = ScrollController();
  final ScrollController _gutterScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _scroll.dispose();
    _gutterScroll.dispose();
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final lineCount = widget.controller.text.split('\n').length;
    const lineHeight = 22.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: NotificationListener<ScrollNotification>(
              onNotification: (n) => true,
              child: SingleChildScrollView(
                controller: _gutterScroll,
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 1; i <= lineCount; i++)
                      GestureDetector(
                        onTap: widget.onToggleBreakpoint == null
                            ? null
                            : () => widget.onToggleBreakpoint!(i),
                        child: Container(
                          height: lineHeight,
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 6),
                          color: i == widget.highlightedLine
                              ? AppColors.executionGreen.withValues(alpha: 0.18)
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (widget.breakpoints.contains(i))
                                const Icon(Icons.circle,
                                    size: 8, color: AppColors.errorRed),
                              const SizedBox(width: 4),
                              Text(
                                '$i',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1, color: Colors.white12),
          Expanded(
            child: Stack(
              children: [
                if (widget.highlightedLine != null)
                  Positioned(
                    top: (widget.highlightedLine! - 1) * lineHeight,
                    left: 0,
                    right: 0,
                    height: lineHeight,
                    child: Container(
                      color: AppColors.executionGreen.withValues(alpha: 0.10),
                    ),
                  ),
                SingleChildScrollView(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  child: TextField(
                    controller: widget.controller,
                    readOnly: widget.readOnly,
                    maxLines: null,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      height: lineHeight / 14,
                      color: AppColors.textPrimary,
                    ),
                    cursorColor: AppColors.cyan,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
