import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminInputField(
          label: s.aptsCountField,
          controller: aptsCtrl,
          color: AppColors.primary,
          onFocusKey: 'apts',
          onHighlight: cubit.setHighlight,
          onChanged: onFieldChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppPrimaryButton(
                label: s.saveChangesBtn,
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.black,
                onPressed: cubit.saveAdminChanges,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppSecondaryButton(
                label: s.manageAptsBtn,
                icon: Icons.vpn_key_outlined,
                onPressed: onOpenManageApts,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: AppSecondaryButton(
                label: s.addNextMonthBtn,
                icon: Icons.calendar_month_outlined,
                accentColor: AppColors.emerald,
                onPressed: cubit.addNextMonth,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppSecondaryButton(
                label: s.unpaidReminderBtn,
                icon: Icons.notifications_active_outlined,
                accentColor: AppColors.amber,
                onPressed: () async {
                  final text = cubit.buildUnpaidReminderMessage();
                  await Clipboard.setData(ClipboardData(text: text));
                  cubit.setCopiedPreview(text);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSecondaryButton(
          label: s.pinNoticeBtn,
          icon: Icons.campaign_outlined,
          accentColor: AppColors.primaryLight,
          onPressed: () => _showAnnouncementDialog(context, cubit, state),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppSecondaryButton(
          label: s.adminLogoutBtn,
          icon: Icons.logout_rounded,
          accentColor: AppColors.danger,
          onPressed: cubit.logoutAdmin,
        ),
      ],
    );
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
