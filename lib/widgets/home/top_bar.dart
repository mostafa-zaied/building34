import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../common/app_card.dart';
import '../common/glow_box.dart';

class TopBar extends StatelessWidget {
  final BuildingCubit cubit;
  final BuildingState state;
  final MonthBill month;
  final VoidCallback onToggleAdmin;

  const TopBar({
    super.key,
    required this.cubit,
    required this.state,
    required this.month,
    required this.onToggleAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isDark = state.isDarkMode;
    final chipBg = AppColors.surface(isDark);
    final borderCol = AppColors.border(isDark);
    final newEmergTotal = (state.baseEmergency + month.forEmerg).toInt();

    return AppCard(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsetsDirectional.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.apartment_rounded, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: state.selectedMonthIndex,
                  dropdownColor: AppColors.card(isDark),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                  items: List.generate(state.months.length, (i) {
                    final item = state.months[i];
                    return DropdownMenuItem(
                      value: i,
                      child: Text(s.monthOption(item.monthNum, item.yearNum)),
                    );
                  }),
                  onChanged: (idx) {
                    if (idx != null) cubit.selectMonth(idx);
                  },
                ),
              ),
            ],
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              GlowBox(
                glowColor: AppColors.emerald,
                isHighlighted: state.highlightedKey == 'top-emerg' || state.highlightedKey == 'emerg',
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  s.emergencyBadge(newEmergTotal),
                  style: AppTypography.label.copyWith(
                    color: AppColors.emeraldText(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: s.languageTooltip,
                onSelected: cubit.setLocale,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'ar', child: Center(child: Text('🇪🇬', style: TextStyle(fontSize: 18)))),
                  PopupMenuItem(value: 'en', child: Center(child: Text('🇺🇸', style: TextStyle(fontSize: 18)))),
                  PopupMenuItem(value: 'de', child: Center(child: Text('🇩🇪', style: TextStyle(fontSize: 18)))),
                ],
                child: Container(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: borderCol),
                  ),
                  child: Text(
                    switch (state.localeCode) {
                      'en' => '🇺🇸',
                      'de' => '🇩🇪',
                      _ => '🇪🇬',
                    },
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              InkWell(
                onTap: cubit.toggleTheme,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Container(
                  padding: const EdgeInsetsDirectional.all(7),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: borderCol),
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    size: 16,
                    color: isDark ? AppColors.amber : AppColors.primary,
                  ),
                ),
              ),
              InkWell(
                onTap: onToggleAdmin,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: state.isAdminOpen ? AppColors.primary.withValues(alpha: 0.16) : chipBg,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: state.isAdminOpen ? AppColors.primary : borderCol,
                    ),
                  ),
                  child: Text(
                    state.isAdminOpen ? s.closeBtn : s.editBtn,
                    style: AppTypography.label.copyWith(
                      fontWeight: FontWeight.w700,
                      color: state.isAdminOpen ? AppColors.primaryText(isDark) : AppColors.textPrimary(isDark),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
