import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class AdminInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color color;
  final IconData? icon;
  final String onFocusKey;
  final ValueChanged<String?> onHighlight;
  final VoidCallback onChanged;

  const AdminInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.color,
    this.icon,
    required this.onFocusKey,
    required this.onHighlight,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? color : HSLColor.fromColor(color).withLightness(0.32).toColor();

    return MouseRegion(
      onEnter: (_) => onHighlight(onFocusKey),
      onExit: (_) => onHighlight(null),
      child: Focus(
        onFocusChange: (hasFocus) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onHighlight(hasFocus ? onFocusKey : null);
          });
        },
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: AppSpacing.xxs),
          decoration: BoxDecoration(
            color: AppColors.surface(isDark),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: color.withValues(alpha: isDark ? 0.55 : 0.75)),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: labelColor),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: AppTypography.caption.copyWith(color: labelColor, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.end,
                  onChanged: (_) => onChanged(),
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    isDense: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsetsDirectional.symmetric(vertical: 6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
