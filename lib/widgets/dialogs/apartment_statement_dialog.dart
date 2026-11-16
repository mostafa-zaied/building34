import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_state.dart';

Future<void> showApartmentStatementDialog({
  required BuildContext context,
  required BuildingState state,
  required int aptNum,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      final isDark = state.isDarkMode;
      final s = state.s;
      final months = state.months.reversed.toList();
      final paidCount = months.where((m) => m.payments.containsKey(aptNum)).length;
      final unpaidCount = months.length - paidCount;

      String formatDate(DateTime dt) {
        final d = dt.toLocal();
        return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      }

      return Dialog(
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        backgroundColor: AppColors.card(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: AppColors.border(isDark)),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 460,
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.80,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accentViolet],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(Icons.receipt_long_rounded, size: 18, color: Colors.white),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.statementDialogTitle(state.aptLabel(aptNum)),
                            style: AppTypography.headline.copyWith(
                              fontSize: 15,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.statementSummary(paidCount, unpaidCount),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(Icons.close_rounded, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Divider(height: 1, color: AppColors.border(isDark)),
                const SizedBox(height: AppSpacing.md),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: months.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (_, idx) {
                      final m = months[idx];
                      final payment = m.payments[aptNum];
                      final isPaid = payment != null;

                      return Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm + 2,
                        ),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? AppColors.emerald.withValues(alpha: isDark ? 0.09 : 0.06)
                              : AppColors.surface(isDark),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isPaid
                                ? AppColors.emerald.withValues(alpha: 0.35)
                                : AppColors.border(isDark),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isPaid ? Icons.check_circle_rounded : Icons.schedule_rounded,
                              size: 18,
                              color: isPaid
                                  ? AppColors.emeraldText(isDark)
                                  : AppColors.amber,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.s.monthOption(m.monthNum, m.yearNum),
                                    style: AppTypography.label.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary(isDark),
                                    ),
                                  ),
                                  if (isPaid)
                                    Text(
                                      formatDate(payment.paidAt),
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary(isDark),
                                        fontSize: 10.5,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              state.s.currency(m.sharePerApt),
                              style: AppTypography.statAmount.copyWith(
                                fontSize: 14,
                                color: isPaid
                                    ? AppColors.emeraldText(isDark)
                                    : AppColors.textPrimary(isDark),
                              ),
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
        ),
      );
    },
  );
}
