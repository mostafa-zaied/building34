import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class ApartmentCard extends StatefulWidget {
  final int aptNum;
  final String label;
  final String amountText;
  final String paidLabel;
  final String pendingLabel;
  final bool isPaid;
  final bool hasReceipt;
  final String? extraBadgeText;
  final IconData? lockIcon;
  final Color? lockIconColor;
  final VoidCallback onTap;

  const ApartmentCard({
    super.key,
    required this.aptNum,
    required this.label,
    required this.amountText,
    required this.paidLabel,
    required this.pendingLabel,
    required this.isPaid,
    required this.hasReceipt,
    this.extraBadgeText,
    this.lockIcon,
    this.lockIconColor,
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
    final accentColor = widget.isPaid ? AppColors.emerald : AppColors.primary;

    final borderColor = widget.isPaid
        ? AppColors.emerald.withValues(alpha: _hovering ? 0.75 : 0.36)
        : (_hovering ? AppColors.primary.withValues(alpha: 0.7) : AppColors.border(isDark));

    final bgColor = widget.isPaid
        ? AppColors.emerald.withValues(alpha: isDark ? 0.09 : 0.06)
        : (_hovering ? AppColors.cardElevated(isDark) : AppColors.surface(isDark));

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: _hovering ? Matrix4.translationValues(0.0, -2.0, 0.0) : Matrix4.identity(),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.sm + 2,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: borderColor,
                width: _hovering || widget.isPaid ? 1.3 : 1.0,
              ),
              boxShadow: _hovering
                  ? AppShadows.accentGlow(accentColor, active: true, isDark: isDark)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row: Full apartment label + clean status circle icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          widget.label,
                          style: AppTypography.title.copyWith(
                            color: AppColors.textPrimary(isDark),
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    if (widget.lockIcon != null) ...[
                      Icon(
                        widget.lockIcon,
                        size: 14,
                        color: widget.lockIconColor ?? AppColors.textSecondary(isDark),
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (widget.isPaid)
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: AppColors.emeraldText(isDark),
                        ),
                      )
                    else
                      Tooltip(
                        message: widget.pendingLabel,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.amber.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: AppColors.amber,
                          ),
                        ),
                      ),
                  ],
                ),

                // Bottom row: Amount or Paid state + optional extra badge / receipt indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        widget.isPaid
                            ? widget.paidLabel.replaceAll('✅', '').trim()
                            : widget.amountText,
                        style: (widget.isPaid ? AppTypography.label : AppTypography.statAmount)
                            .copyWith(
                          fontSize: widget.isPaid ? 11.5 : 14,
                          fontWeight: FontWeight.w800,
                          color: widget.isPaid
                              ? AppColors.emeraldText(isDark)
                              : AppColors.textPrimary(isDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.extraBadgeText != null && !widget.isPaid)
                      Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: isDark ? 0.16 : 0.14),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: AppColors.amber.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          widget.extraBadgeText!,
                          style: AppTypography.caption.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warningText(isDark),
                          ),
                        ),
                      ),
                    if (widget.hasReceipt)
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 14,
                        color: AppColors.emeraldText(isDark).withValues(alpha: 0.8),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
