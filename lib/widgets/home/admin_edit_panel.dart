import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../common/app_button.dart';
import '../dialogs/extra_charges_dialog.dart';
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
                onPressed: cubit.saveAdminChanges,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),
        Divider(height: 1, color: AppColors.border(isDark)),
        const SizedBox(height: AppSpacing.md),

        // 2. Calm, Unified 2-Column Action Grid
        Row(
          children: [
            Expanded(
              child: _AdminActionTile(
                label: s.manageAptsBtn,
                icon: Icons.vpn_key_outlined,
                isDark: isDark,
                onTap: onOpenManageApts,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _AdminActionTile(
                label: s.extraChargesBtn,
                icon: Icons.add_card_rounded,
                isDark: isDark,
                onTap: () => showExtraChargesDialog(context: context, cubit: cubit),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _AdminActionTile(
                label: s.unpaidReminderBtn,
                icon: Icons.notifications_active_outlined,
                isDark: isDark,
                onTap: () async {
                  final text = cubit.buildUnpaidReminderMessage();
                  cubit.setCopiedPreview(text);
                  try {
                    await Clipboard.setData(ClipboardData(text: text));
                  } catch (_) {}
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _AdminActionTile(
                label: s.pinNoticeBtn,
                icon: Icons.campaign_outlined,
                isDark: isDark,
                onTap: () => _showAnnouncementDialog(context, cubit, state),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _AdminActionTile(
                label: s.addNextMonthBtn,
                icon: Icons.calendar_month_outlined,
                isDark: isDark,
                onTap: cubit.addNextMonth,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _AdminActionTile(
                label: s.removeMonthBtn,
                icon: Icons.delete_outline_rounded,
                isDark: isDark,
                isDestructive: true,
                onTap: state.months.length <= 1
                    ? null
                    : () => _confirmDeleteMonth(context, cubit, state),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),
        _AdminViewsCard(
          isDark: isDark,
          isAr: state.localeCode == 'ar',
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

  Future<void> _confirmDeleteMonth(
    BuildContext context,
    BuildingCubit cubit,
    BuildingState state,
  ) async {
    final m = state.currentMonth;
    if (m == null) return;
    final isDark = state.isDarkMode;
    final s = state.s;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card(isDark),
        title: Text(
          s.deleteMonthConfirmTitle,
          style: AppTypography.headline.copyWith(fontSize: 15),
        ),
        content: Text(
          s.deleteMonthConfirmBody(m.monthNum, m.yearNum),
          style: AppTypography.body.copyWith(color: AppColors.textSecondary(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.removeMonthBtn, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await cubit.deleteCurrentMonth();
    }
  }

  Future<void> _showAnnouncementDialog(
    BuildContext context,
    BuildingCubit cubit,
    BuildingState state,
  ) async {
    final ctrl = TextEditingController(text: state.announcement);
    final isDark = state.isDarkMode;
    final s = state.s;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card(isDark),
        title: Text(s.noticeDialogTitle, style: AppTypography.headline.copyWith(fontSize: 15)),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: InputDecoration(hintText: s.noticeDialogHint),
        ),
        actions: [
          if (state.announcement.trim().isNotEmpty)
            TextButton(
              onPressed: () async {
                await cubit.saveAnnouncement('');
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(s.hideNoticeBtn, style: const TextStyle(color: AppColors.danger)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              await cubit.saveAnnouncement(ctrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(s.saveAll),
          ),
        ],
      ),
    );
    Future.delayed(const Duration(milliseconds: 350), ctrl.dispose);
  }
}

class _AdminActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _AdminActionTile({
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
  final bool isAr;
  final PageViewStats? stats;
  final VoidCallback onRefresh;

  const _AdminViewsCard({
    required this.isDark,
    required this.isAr,
    required this.stats,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final s = stats;
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
                  isAr ? 'إحصائيات الزيارات (للمدير فقط)' : 'Link Views (Admin Only)',
                  style: AppTypography.label.copyWith(
                    color: AppColors.textPrimary(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                tooltip: isAr ? 'تحديث' : 'Refresh',
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
          if (s == null)
            Text(
              isAr
                  ? 'اضغط تحديث لعرض الإحصائيات (تأكد من تشغيل SQL في Supabase)'
                  : 'Tap refresh to load stats (ensure Supabase SQL is applied)',
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
                      label: isAr ? 'إجمالي الفتح' : 'Total',
                      value: '${s.totalViews}',
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _statPill(
                      label: isAr ? 'زوار فريدون' : 'Unique',
                      value: '${s.uniqueVisitors}',
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _statPill(
                      label: isAr ? 'اليوم' : 'Today',
                      value: '${s.todayViews}',
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _statPill(
                      label: isAr ? '7 أيام' : '7 Days',
                      value: '${s.weekViews}',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    _statPill(
                      label: isAr ? 'فتحوا تبويب "قريباً"' : 'Opened Soon',
                      value: '${s.upcomingOpens}',
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _statPill(
                      label: isAr ? 'مهتمون بخدمات المنطقة 👍' : 'Interested 👍',
                      value: '${s.upcomingVotes}',
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
