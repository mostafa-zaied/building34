import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class ApartmentCard extends StatefulWidget {
  final int aptNum;
  final String label;
  final String statusText;
  final bool isPaid;
  final VoidCallback onTap;

  const ApartmentCard({
    super.key,
    required this.aptNum,
    required this.label,
    required this.statusText,
    required this.isPaid,
    required this.onTap,
  });

  @override
  State<ApartmentCard> createState() => _ApartmentCardState();
}

class _ApartmentCardState extends State<ApartmentCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = widget.isPaid
        ? AppColors.emerald
        : (_hovering ? AppColors.primary : AppColors.border(isDark));

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: _hovering ? Matrix4.translationValues(0.0, -2.0, 0.0) : Matrix4.identity(),
          padding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: widget.isPaid
                ? AppColors.emerald.withValues(alpha: isDark ? 0.09 : 0.06)
                : AppColors.surface(isDark),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: borderColor,
              width: widget.isPaid || _hovering ? 1.6 : 1.0,
            ),
            boxShadow: _hovering || widget.isPaid
                ? AppShadows.accentGlow(borderColor, active: _hovering, isDark: isDark)
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: AppTypography.label.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  widget.statusText,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    color: widget.isPaid
                        ? AppColors.emeraldText(isDark)
                        : AppColors.textSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
