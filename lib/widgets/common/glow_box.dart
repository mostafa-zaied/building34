import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

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

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: active ? Matrix4.translationValues(0.0, -2.0, 0.0) : Matrix4.identity(),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: AppColors.surface(isDark),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: active
                ? widget.glowColor
                : widget.glowColor.withValues(alpha: isDark ? 0.38 : 0.55),
            width: active ? 1.8 : 1.1,
          ),
          boxShadow: AppShadows.accentGlow(widget.glowColor, active: active, isDark: isDark),
        ),
        child: widget.child,
      ),
    );
  }
}
