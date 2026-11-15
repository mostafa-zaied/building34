import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../common/app_button.dart';
import '../common/app_card.dart';
import '../common/expense_stat_card.dart';
import '../common/glow_box.dart';
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
    final newEmergTotal = (state.baseEmergency + month.forEmerg).toInt();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              Text(
                s.billTitle(month.monthNum),
                style: AppTypography.headline.copyWith(fontSize: 15),
              ),
              AppPrimaryButton(
                label: s.copyWhatsAppBtn,
                icon: Icons.copy_rounded,
                onPressed: onCopyWhatsApp,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [
                ExpenseStatCard(label: s.waterLabel, value: '${month.water.toInt()}', color: AppColors.water, highlighted: state.highlightedKey == 'water'),
                ExpenseStatCard(label: s.elecLabel, value: '${month.elec.toInt()}', color: AppColors.electricity, highlighted: state.highlightedKey == 'elec'),
                ExpenseStatCard(label: s.elevLabel, value: '${month.elev.toInt()}', color: AppColors.elevator, highlighted: state.highlightedKey == 'elev'),
                ExpenseStatCard(label: s.cleanLabel, value: '${month.clean.toInt()}', color: AppColors.cleaning, highlighted: state.highlightedKey == 'clean'),
                ExpenseStatCard(label: s.forEmergLabel, value: '${month.forEmerg.toInt()}', color: AppColors.reserve, highlighted: state.highlightedKey == 'emerg'),
              ];

              if (constraints.maxWidth < 460) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(child: cards[1]),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(child: cards[2]),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(child: cards[3]),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(child: cards[4]),
                        const SizedBox(width: AppSpacing.xs),
                        const Spacer(),
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
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: cards[4]),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          GlowBox(
            glowColor: AppColors.primary,
            isHighlighted: state.highlightedKey == 'apts',
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.totalExpensesLine(month.totalExpenses.toInt(), month.aptsCount),
                        style: AppTypography.label.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        s.emergencySummaryLine(newEmergTotal, state.baseEmergency.toInt(), month.forEmerg.toInt()),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.emeraldText(isDark),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      s.sharePerAptLabel,
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary(isDark)),
                    ),
                    Text(
                      s.currency(month.sharePerApt),
                      style: AppTypography.heroAmount.copyWith(
                        fontSize: 21,
                        color: AppColors.primaryText(isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                        color: AppColors.surface(isDark),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.65)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                s.copiedTitle,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.emeraldText(isDark),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              InkWell(
                                onTap: () => cubit.setCopiedPreview(null),
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.all(2),
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
                            style: AppTypography.caption.copyWith(height: 1.55),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: state.isAdminOpen
                ? AdminEditPanel(
                    cubit: cubit,
                    state: state,
                    waterCtrl: waterCtrl,
                    elecCtrl: elecCtrl,
                    elevCtrl: elevCtrl,
                    cleanCtrl: cleanCtrl,
                    forEmergCtrl: forEmergCtrl,
                    aptsCtrl: aptsCtrl,
                    baseEmergCtrl: baseEmergCtrl,
                    onFieldChanged: onFieldChanged,
                    onOpenManageApts: onOpenManageApts,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
