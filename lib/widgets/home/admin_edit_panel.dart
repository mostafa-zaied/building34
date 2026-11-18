import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../../screens/admin_settings_screen.dart';
import '../common/app_button.dart';
import 'admin_input_field.dart';

class AdminEditPanel extends StatelessWidget {
  final BuildingCubit cubit;
  final BuildingState state;
  final TextEditingController aptsCtrl;
  final VoidCallback onFieldChanged;
  final VoidCallback onOpenManageApts;

  const AdminEditPanel({
    super.key,
    required this.cubit,
    required this.state,
    required this.aptsCtrl,
    required this.onFieldChanged,
    required this.onOpenManageApts,
  });

  @override
  Widget build(BuildContext context) {
    final s = state.s;
    final isDark = state.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Primary Row: Apartments Count + Save Changes
        Row(
          children: [
            Expanded(
              flex: 5,
              child: AdminInputField(
                label: s.aptsCountField,
                controller: aptsCtrl,
                color: AppColors.primary,
                icon: Icons.home_work_outlined,
                onFocusKey: 'apts',
                onHighlight: cubit.setHighlight,
                onChanged: onFieldChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: 5,
              child: AppPrimaryButton(
                label: s.saveChangesBtn,
                icon: Icons.check_circle_outline_rounded,
                backgroundColor: AppColors.primaryActionBg(isDark),
                foregroundColor: AppColors.onPrimaryAction(isDark),
                loading: state.busy,
                onPressed: state.busy ? null : cubit.saveAdminChanges,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),
        AdminActionTile(
          label: s.settingsBtn,
          icon: Icons.settings_outlined,
          isDark: isDark,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AdminSettingsScreen(
                  onOpenManageApts: onOpenManageApts,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: AppSpacing.md),
        _AdminViewsCard(
          isDark: isDark,
          s: s,
          stats: state.pageViewStats,
          onRefresh: cubit.refreshPageViewStats,
        ),

        const SizedBox(height: AppSpacing.sm),
        Center(
          child: TextButton.icon(
            onPressed: cubit.logoutAdmin,
            icon: Icon(
              Icons.logout_rounded,
              size: 15,
              color: AppColors.textSecondary(isDark),
            ),
            label: Text(
              s.adminLogoutBtn,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AdminActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  final bool isDestructive;
  final VoidCallback? onTap;

  const AdminActionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.isDark,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final iconColor = disabled
        ? AppColors.textSecondary(isDark).withValues(alpha: 0.45)
        : (isDestructive
            ? AppColors.dangerText(isDark)
            : AppColors.primaryText(isDark));
    final textColor = disabled
        ? AppColors.textSecondary(isDark).withValues(alpha: 0.45)
        : (isDestructive
            ? AppColors.dangerText(isDark)
            : AppColors.textPrimary(isDark));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.md,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface(isDark),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border(isDark)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.label.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
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

class _AdminViewsCard extends StatelessWidget {
  final bool isDark;
  final dynamic s;
  final PageViewStats? stats;
  final VoidCallback onRefresh;

  const _AdminViewsCard({
    required this.isDark,
    required this.s,
    required this.stats,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final st = stats;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 16,
                color: AppColors.primaryText(isDark),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  s.adminViewsTitle,
                  style: AppTypography.label.copyWith(
                    color: AppColors.textPrimary(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                tooltip: s.refreshTooltip,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          if (st == null)
            Text(
              s.viewsStatsLoadingHint,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary(isDark),
              ),
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    _statPill(
                      label: s.viewsTotalLabel,
                      value: '${st.totalViews}',
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _statPill(
                      label: s.viewsUniqueLabel,
                      value: '${st.uniqueVisitors}',
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _statPill(
                      label: s.viewsTodayLabel,
                      value: '${st.todayViews}',
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _statPill(
                      label: s.viewsWeekLabel,
                      value: '${st.weekViews}',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    _statPill(
                      label: s.viewsUpcomingOpensLabel,
                      value: '${st.upcomingOpens}',
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _statPill(
                      label: s.viewsUpcomingVotesLabel,
                      value: '${st.upcomingVotes}',
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _statPill({required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.card(isDark),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border(isDark)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.headline.copyWith(
                fontSize: 15,
                color: AppColors.primaryText(isDark),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
