import 'package:flutter/material.dart';

class GlowBox extends StatefulWidget {
  final Color glowColor;
  final bool isHighlighted;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const GlowBox({
    super.key,
    required this.glowColor,
    required this.isHighlighted,
    required this.padding,
    required this.child,
  });

  @override
  State<GlowBox> createState() => _GlowBoxState();
}

class _GlowBoxState extends State<GlowBox> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = _hovering || widget.isHighlighted;
    final surfaceColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: active ? Matrix4.translationValues(0.0, -3.0, 0.0) : Matrix4.identity(),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? widget.glowColor : widget.glowColor.withValues(alpha: isDark ? 0.45 : 0.7),
            width: active ? 2 : 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.glowColor.withValues(alpha: active ? 0.5 : (isDark ? 0.18 : 0.22)),
              blurRadius: active ? 16 : 6,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
