import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'glow_box.dart';

class ExpenseStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool highlighted;

  const ExpenseStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? color : HSLColor.fromColor(color).withLightness(0.32).toColor();

    return GlowBox(
      glowColor: color,
      isHighlighted: highlighted,
      padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(color: labelColor, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: AppTypography.title.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
