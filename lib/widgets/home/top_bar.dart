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
      .replaceAll('✓', '')
      .trim();

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isDark = state.isDarkMode;

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
                    colors: [AppColors.primary, AppColors.primaryLight],
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
                child: _SecretAdminTitle(
                  title: s.appTitle,
                  style: AppTypography.headline.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(isDark),
                  ),
                  onSecretTap: onToggleAdmin,
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
                    Tooltip(
                      message: s.languageTooltip,
                      child: InkWell(
                        onTap: () => cubit.setLocale(state.localeCode == 'ar' ? 'en' : 'ar'),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              state.localeCode == 'en' ? '🇺🇸' : '🇪🇬',
                              key: ValueKey(state.localeCode),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: 1,
                      height: 15,
                      color: AppColors.border(isDark),
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: cubit.toggleTheme,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            key: ValueKey(isDark),
                            size: 16,
                            color: isDark ? AppColors.amber : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    if (state.isAdminAuthenticated) ...[
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
                                state.isAdminOpen ? Icons.check_rounded : Icons.tune_rounded,
                                size: 14,
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
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm + 2),
          Divider(height: 1, color: AppColors.border(isDark)),
          const SizedBox(height: AppSpacing.sm + 2),

          // Bottom row: Month selector
          Row(
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
            ],
          ),
        ],
      ),
    );
  }
}

class _SecretAdminTitle extends StatefulWidget {
  final String title;
  final TextStyle style;
  final VoidCallback onSecretTap;

  const _SecretAdminTitle({
    required this.title,
    required this.style,
    required this.onSecretTap,
  });

  @override
  State<_SecretAdminTitle> createState() => _SecretAdminTitleState();
}

class _SecretAdminTitleState extends State<_SecretAdminTitle> {
  int _tapCount = 0;
  DateTime? _lastTapAt;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapAt == null || now.difference(_lastTapAt!) > const Duration(seconds: 2)) {
      _tapCount = 0;
    }
    _lastTapAt = now;
    _tapCount++;
    if (_tapCount >= 5) {
      _tapCount = 0;
      _lastTapAt = null;
      widget.onSecretTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: Text(
        widget.title,
        style: widget.style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
