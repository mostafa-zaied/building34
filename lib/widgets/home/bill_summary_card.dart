import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../common/expense_stat_card.dart';
import 'admin_edit_panel.dart';

class BillSummaryCard extends StatelessWidget {
  final BuildingCubit cubit;
  final BuildingState state;
  final MonthBill month;
  final VoidCallback onCopyWhatsApp;
  final TextEditingController waterCtrl;
  final TextEditingController elecCtrl;
  final TextEditingController elevCtrl;
  final TextEditingController cleanCtrl;
  final TextEditingController forEmergCtrl;
  final TextEditingController aptsCtrl;
  final TextEditingController baseEmergCtrl;
  final VoidCallback onFieldChanged;
  final VoidCallback onOpenManageApts;

  const BillSummaryCard({
    super.key,
    required this.cubit,
    required this.state,
    required this.month,
    required this.onCopyWhatsApp,
    required this.waterCtrl,
    required this.elecCtrl,
    required this.elevCtrl,
    required this.cleanCtrl,
    required this.forEmergCtrl,
    required this.aptsCtrl,
    required this.baseEmergCtrl,
    required this.onFieldChanged,
    required this.onOpenManageApts,
  });

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isDark = state.isDarkMode;
    final isAptsHighlighted = state.highlightedKey == 'apts';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Compact Monthly Expense Categories Grid (Top)
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              ExpenseStatCard(
                label: s.waterLabel,
                value: s.currency(month.water.toInt()),
                color: AppColors.water,
                highlighted: state.highlightedKey == 'water',
                isEditable: state.isAdminOpen,
                controller: waterCtrl,
                onChanged: onFieldChanged,
              ),
              ExpenseStatCard(
                label: s.elecLabel,
                value: s.currency(month.elec.toInt()),
                color: AppColors.electricity,
                highlighted: state.highlightedKey == 'elec',
                isEditable: state.isAdminOpen,
                controller: elecCtrl,
                onChanged: onFieldChanged,
              ),
              ExpenseStatCard(
                label: s.elevLabel,
                value: s.currency(month.elev.toInt()),
                color: AppColors.elevator,
                highlighted: state.highlightedKey == 'elev',
                isEditable: state.isAdminOpen,
                controller: elevCtrl,
                onChanged: onFieldChanged,
              ),
              ExpenseStatCard(
                label: s.cleanLabel,
                value: s.currency(month.clean.toInt()),
                color: AppColors.cleaning,
                highlighted: state.highlightedKey == 'clean',
                isEditable: state.isAdminOpen,
                controller: cleanCtrl,
                onChanged: onFieldChanged,
              ),
            ];

            if (constraints.maxWidth < 500) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(child: cards[1]),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(child: cards[2]),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(child: cards[3]),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: cards[1]),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: cards[2]),
                const SizedBox(width: AppSpacing.xs),
                Expanded(child: cards[3]),
              ],
            );
          },
        ),

        const SizedBox(height: AppSpacing.md),

        // 2. Luxury Hero Financial Summary Card (Below Services, without Emergency Strip)
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: isDark
                  ? const [Color(0xFF131C31), Color(0xFF1A1838)]
                  : const [Color(0xFFFFFFFF), Color(0xFFF2F4FF)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isAptsHighlighted
                  ? AppColors.primary
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.primary.withValues(alpha: 0.14)),
              width: isAptsHighlighted ? 1.6 : 1.0,
            ),
            boxShadow: isAptsHighlighted
                ? AppShadows.accentGlow(AppColors.primary, active: true, isDark: isDark)
                : AppShadows.heroCard(isDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      s.billTitle(month.monthNum),
                      style: AppTypography.headline.copyWith(
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.sharePerAptLabel,
                          style: AppTypography.label.copyWith(
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          s.currency(month.sharePerApt),
                          style: AppTypography.heroAmount.copyWith(
                            color: isDark ? Colors.white : AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : AppColors.primary.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      s.totalExpensesLine(month.totalExpenses.toInt(), month.aptsCount),
                      style: AppTypography.label.copyWith(
                        color: AppColors.textPrimary(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // 3. WhatsApp Share Action (directly above the copied message preview)
        _WhatsAppShareButton(
          label: s.copyWhatsAppBtn,
          onTap: onCopyWhatsApp,
          isDark: isDark,
        ),

        // 4. Copied WhatsApp Message Preview Drawer
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: state.copiedPreview == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsetsDirectional.only(top: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.card(isDark),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.emerald.withValues(alpha: 0.45),
                      ),
                      boxShadow: AppShadows.card(isDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              s.copiedTitle,
                              style: AppTypography.label.copyWith(
                                color: AppColors.emeraldText(isDark),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            InkWell(
                              onTap: () => cubit.setCopiedPreview(null),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.all(4),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SelectableText(
                          state.copiedPreview!,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary(isDark),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),

        // 5. Admin Edit Panel (Animated)
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          child: state.isAdminOpen
              ? Container(
                  margin: const EdgeInsetsDirectional.only(top: AppSpacing.md),
                  padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.card(isDark),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(color: AppColors.border(isDark)),
                    boxShadow: AppShadows.card(isDark),
                  ),
                  child: AdminEditPanel(
                    cubit: cubit,
                    state: state,
                    aptsCtrl: aptsCtrl,
                    onFieldChanged: onFieldChanged,
                    onOpenManageApts: onOpenManageApts,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _WhatsAppShareButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _WhatsAppShareButton({
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: AlignmentDirectional.centerStart,
              end: AlignmentDirectional.centerEnd,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.accentGlow(
              AppColors.primary,
              active: false,
              isDark: isDark,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.share_rounded, size: 15, color: Colors.white),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.label.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
