import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';

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

  static String _cleanLabel(String text) => text
      .replaceAll('🛡️', '')
      .replaceAll('⚙️', '')
      .replaceAll('✖️', '')
      .replaceAll('✕', '')
      .trim();

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isDark = state.isDarkMode;
    final newEmergTotal = (state.baseEmergency + month.forEmerg).toInt();
    final isEmergHighlighted =
        state.highlightedKey == 'top-emerg' || state.highlightedKey == 'emerg';

    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: isDark
              ? [AppColors.darkCardElevated, AppColors.darkCard]
              : [Colors.white, AppColors.lightCardElevated],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.lightBorder,
        ),
        boxShadow: AppShadows.card(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row: Brand identity + Quick controls
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accentViolet],
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                  boxShadow: AppShadows.accentGlow(
                    AppColors.primary,
                    active: false,
                    isDark: isDark,
                  ),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  s.appTitle,
                  style: AppTypography.headline.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(isDark),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),

              // Compact utility capsule
              Container(
                padding: const EdgeInsetsDirectional.all(3),
                decoration: BoxDecoration(
                  color: AppColors.surface(isDark),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton<String>(
                      tooltip: s.languageTooltip,
                      onSelected: cubit.setLocale,
                      color: AppColors.cardElevated(isDark),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'ar',
                          child: Center(child: Text('🇪🇬', style: TextStyle(fontSize: 18))),
                        ),
                        PopupMenuItem(
                          value: 'en',
                          child: Center(child: Text('🇺🇸', style: TextStyle(fontSize: 18))),
                        ),
                        PopupMenuItem(
                          value: 'de',
                          child: Center(child: Text('🇩🇪', style: TextStyle(fontSize: 18))),
                        ),
                      ],
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 7,
                          vertical: 4,
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
                    Container(
                      width: 1,
                      height: 15,
                      color: AppColors.border(isDark),
                    ),
                    InkWell(
                      onTap: cubit.toggleTheme,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            key: ValueKey(isDark),
                            size: 15,
                            color: isDark ? AppColors.amber : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 15,
                      color: AppColors.border(isDark),
                    ),
                    InkWell(
                      onTap: onToggleAdmin,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: state.isAdminOpen
                              ? AppColors.primary.withValues(alpha: 0.20)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              state.isAdminOpen ? Icons.close_rounded : Icons.tune_rounded,
                              size: 13,
                              color: state.isAdminOpen
                                  ? AppColors.primaryText(isDark)
                                  : AppColors.textSecondary(isDark),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _cleanLabel(state.isAdminOpen ? s.closeBtn : s.editBtn),
                              style: AppTypography.caption.copyWith(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: state.isAdminOpen
                                    ? AppColors.primaryText(isDark)
                                    : AppColors.textPrimary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm + 2),
          Divider(height: 1, color: AppColors.border(isDark)),
          const SizedBox(height: AppSpacing.sm + 2),

          // Bottom row: Month selector + Emergency fund balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Month & Year selector
              Container(
                padding: const EdgeInsetsDirectional.only(
                  start: AppSpacing.sm + 2,
                  end: AppSpacing.xs,
                  top: 4,
                  bottom: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface(isDark),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 14,
                      color: AppColors.primaryText(isDark),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: state.selectedMonthIndex,
                        isDense: true,
                        dropdownColor: AppColors.cardElevated(isDark),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 17,
                          color: AppColors.textSecondary(isDark),
                        ),
                        style: AppTypography.label.copyWith(
                          color: AppColors.textPrimary(isDark),
                          fontWeight: FontWeight.w700,
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
              ),

              const SizedBox(width: AppSpacing.xs),

              // Emergency Fund Balance Pill
              Flexible(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(
                      alpha: isEmergHighlighted ? 0.22 : (isDark ? 0.12 : 0.09),
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: AppColors.emerald.withValues(
                        alpha: isEmergHighlighted ? 0.85 : 0.30,
                      ),
                    ),
                    boxShadow: isEmergHighlighted
                        ? AppShadows.accentGlow(AppColors.emerald, active: true, isDark: isDark)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_rounded,
                        size: 14,
                        color: AppColors.emeraldText(isDark),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          _cleanLabel(s.emergencyBadge(newEmergTotal)),
                          style: AppTypography.label.copyWith(
                            color: AppColors.emeraldText(isDark),
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
