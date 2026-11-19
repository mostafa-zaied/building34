import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../models/building_models.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/busy_overlay.dart';
import '../widgets/dialogs/extra_charges_dialog.dart';
import '../widgets/home/admin_edit_panel.dart';

class AdminSettingsScreen extends StatelessWidget {
  final VoidCallback onOpenManageApts;

  const AdminSettingsScreen({
    super.key,
    required this.onOpenManageApts,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final s = state.s;
        final isDark = state.isDarkMode;
        final isAr = state.localeCode == 'ar';
        final currentMonth = state.currentMonth;

        if (!state.isAdminAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: Text(s.settingsShortTitle),
            ),
            body: Center(
              child: Text(
                s.adminOnlyPageMsg,
                style: AppTypography.body,
              ),
            ),
          );
        }

        final enabled = state.requireAptPassOnOpen;

        return BusyOverlay(
          busy: state.busy,
          isDark: isDark,
          child: Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
          appBar: AppBar(
            backgroundColor: AppColors.surface(isDark),
            elevation: 0,
            title: Text(
              s.settingsTitle,
              style: AppTypography.headline.copyWith(
                color: AppColors.textPrimary(isDark),
              ),
            ),
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                children: [
                  // 1. Security / Passcode Gate Toggle
                  AppCard(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Icon(
                                Icons.lock_person_outlined,
                                color: AppColors.primaryText(isDark),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.requirePassOnOpenTitle,
                                    style: AppTypography.headline.copyWith(
                                      fontSize: 15,
                                      color: AppColors.textPrimary(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    enabled ? s.statusEnabled : s.statusDisabled,
                                    style: AppTypography.caption.copyWith(
                                      color: enabled
                                          ? AppColors.emeraldText(isDark)
                                          : AppColors.textSecondary(isDark),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: enabled,
                              onChanged: (v) => cubit.setRequireAptPassOnOpen(v),
                              activeTrackColor: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface(isDark),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(color: AppColors.border(isDark)),
                          ),
                          child: Text(
                            enabled ? s.requirePassOnOpenDescOn : s.requirePassOnOpenDescOff,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(isDark),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // 2. Building & Month Management Actions
                  AppCard(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.buildingMonthMgmtTitle,
                                style: AppTypography.headline.copyWith(
                                  fontSize: 15,
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                            ),
                            if (currentMonth != null)
                              Container(
                                padding: const EdgeInsetsDirectional.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  s.selectedMonthBadge(
                                    localizedMonthName(currentMonth.monthNum, isAr),
                                    currentMonth.monthNum,
                                    currentMonth.yearNum,
                                  ),
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primaryText(isDark),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (state.months.length > 1) ...[
                          const SizedBox(height: AppSpacing.sm),
                          SizedBox(
                            height: 32,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.months.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 6),
                              itemBuilder: (context, i) {
                                final m = state.months[i];
                                final selected = i == state.selectedMonthIndex;
                                return ChoiceChip(
                                  label: Text('${m.monthNum}/${m.yearNum}'),
                                  selected: selected,
                                  onSelected: (_) => cubit.selectMonth(i),
                                  visualDensity: VisualDensity.compact,
                                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                                  backgroundColor: AppColors.surface(isDark),
                                  labelStyle: AppTypography.caption.copyWith(
                                    fontSize: 11,
                                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                                    color: selected
                                        ? AppColors.primaryText(isDark)
                                        : AppColors.textSecondary(isDark),
                                  ),
                                  side: BorderSide(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.border(isDark),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: AdminActionTile(
                                label: s.manageAptsBtn,
                                icon: Icons.vpn_key_outlined,
                                isDark: isDark,
                                onTap: onOpenManageApts,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AdminActionTile(
                                label: s.extraChargesBtn,
                                icon: Icons.add_card_rounded,
                                isDark: isDark,
                                onTap: () => showExtraChargesDialog(
                                  context: context,
                                  cubit: cubit,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AdminActionTile(
                          label: s.pinNoticeBtn,
                          icon: Icons.campaign_outlined,
                          isDark: isDark,
                          onTap: () => _showAnnouncementDialog(
                            context,
                            cubit,
                            state,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: AdminActionTile(
                                label: s.addNextMonthBtn,
                                icon: Icons.calendar_month_outlined,
                                isDark: isDark,
                                onTap: () => _confirmAddNextMonth(
                                  context,
                                  cubit,
                                  state,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AdminActionTile(
                                label: currentMonth != null
                                    ? '${s.removeMonthBtn} (${currentMonth.monthNum}/${currentMonth.yearNum})'
                                    : s.removeMonthBtn,
                                icon: Icons.delete_outline_rounded,
                                isDark: isDark,
                                isDestructive: true,
                                onTap: state.months.length <= 1
                                    ? null
                                    : () => _confirmDeleteMonth(
                                          context,
                                          cubit,
                                          state,
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // 4. Manual Push Notification Broadcast Card
                  _PushNotificationCard(cubit: cubit, state: state),
                ],
              ),
            ),
          ),
          ),
        );
      },
    );
  }

  Future<void> _confirmAddNextMonth(
    BuildContext context,
    BuildingCubit cubit,
    BuildingState state,
  ) async {
    final isDark = state.isDarkMode;
    final s = state.s;
    final isAr = state.localeCode == 'ar';
    final now = DateTime.now();
    final last = state.months.isNotEmpty ? state.months.last : null;
    final nextMonth = last == null
        ? now.month
        : (last.monthNum == 12 ? 1 : last.monthNum + 1);
    final nextYear = last == null
        ? now.year
        : (last.monthNum == 12 ? last.yearNum + 1 : last.yearNum);

    final nextName = localizedMonthName(nextMonth, isAr);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card(isDark),
        title: Text(
          s.addNextMonthConfirmTitle,
          style: AppTypography.headline.copyWith(fontSize: 15),
        ),
        content: Text(
          s.addNextMonthConfirmBody(nextName, nextMonth, nextYear),
          style: AppTypography.body.copyWith(color: AppColors.textSecondary(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryActionBg(isDark),
              foregroundColor: AppColors.onPrimaryAction(isDark),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              s.addNextMonthConfirmBtn(nextName, nextMonth, nextYear),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await cubit.addNextMonth();
    }
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

class _PushNotificationCard extends StatefulWidget {
  final BuildingCubit cubit;
  final BuildingState state;

  const _PushNotificationCard({
    required this.cubit,
    required this.state,
  });

  @override
  State<_PushNotificationCard> createState() => _PushNotificationCardState();
}

class _PushNotificationCardState extends State<_PushNotificationCard> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _adminsOnly = true;
  bool _sending = false;
  String? _localErr;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final s = widget.state.s;
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      setState(() => _localErr = s.errPushFieldsRequired);
      return;
    }
    setState(() {
      _sending = true;
      _localErr = null;
    });
    final ok = await widget.cubit.sendManualPushNotification(
      title: title,
      body: body,
      adminsOnly: _adminsOnly,
    );
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (ok) {
        _titleCtrl.clear();
        _bodyCtrl.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state.s;
    final isDark = widget.state.isDarkMode;

    return AppCard(
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  size: 20,
                  color: AppColors.primaryText(isDark),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.pushCardTitle,
                      style: AppTypography.title.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.pushCardSubtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Audience toggle: Admin Only (Test) by default vs All Residents
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface(isDark),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border(isDark)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _sending ? null : () => setState(() => _adminsOnly = true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _adminsOnly
                            ? AppColors.primary.withValues(alpha: 0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        s.pushAudienceAdminOnly,
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w800,
                          color: _adminsOnly
                              ? AppColors.primaryText(isDark)
                              : AppColors.textSecondary(isDark),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: GestureDetector(
                    onTap: _sending ? null : () => setState(() => _adminsOnly = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: !_adminsOnly
                            ? AppColors.emerald.withValues(alpha: 0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        s.pushAudienceAll,
                        textAlign: TextAlign.center,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w800,
                          color: !_adminsOnly
                              ? AppColors.emeraldText(isDark)
                              : AppColors.textSecondary(isDark),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _titleCtrl,
            enabled: !_sending,
            onChanged: (_) {
              if (_localErr != null) setState(() => _localErr = null);
            },
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimary(isDark),
            ),
            decoration: InputDecoration(
              labelText: s.pushTitleLabel,
              hintText: s.pushTitleHint,
              filled: true,
              fillColor: AppColors.surface(isDark),
              prefixIcon: Icon(
                Icons.title_rounded,
                size: 18,
                color: AppColors.textSecondary(isDark),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _bodyCtrl,
            enabled: !_sending,
            maxLines: 3,
            minLines: 2,
            onChanged: (_) {
              if (_localErr != null) setState(() => _localErr = null);
            },
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimary(isDark),
            ),
            decoration: InputDecoration(
              labelText: s.pushBodyLabel,
              hintText: s.pushBodyHint,
              filled: true,
              fillColor: AppColors.surface(isDark),
              alignLabelWithHint: true,
            ),
          ),
          if (_localErr != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _localErr!,
              style: AppTypography.caption.copyWith(
                color: AppColors.dangerText(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              label: _adminsOnly ? s.pushSendAdminTestBtn : s.pushSendAllBtn,
              icon: _adminsOnly ? Icons.shield_outlined : Icons.send_rounded,
              loading: _sending,
              onPressed: _sending ? null : _send,
            ),
          ),
        ],
      ),
    );
  }
}
