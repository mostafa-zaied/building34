import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/web_url.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../models/building_models.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/busy_overlay.dart';
import '../widgets/dialogs/extra_charges_dialog.dart';
import '../widgets/home/admin_edit_panel.dart';
import 'monthly_report_screen.dart';

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
                  // 0. Per-Building Identity, Code & Share Link Card
                  _BuildingProfileCard(cubit: cubit, state: state),

                  const SizedBox(height: AppSpacing.lg),

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
                        Row(
                          children: [
                            Expanded(
                              child: AdminActionTile(
                                label: s.pinNoticeBtn,
                                icon: Icons.campaign_outlined,
                                isDark: isDark,
                                onTap: () => _showAnnouncementDialog(
                                  context,
                                  cubit,
                                  state,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AdminActionTile(
                                label: s.monthlyReportBtn,
                                icon: Icons.summarize_outlined,
                                isDark: isDark,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const MonthlyReportScreen(),
                                  ),
                                ),
                              ),
                            ),
                          ],
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

                  const SizedBox(height: AppSpacing.md),

                  // 5. Change Admin Password Card
                  _ChangeAdminPasswordCard(cubit: cubit, state: state),
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
  // 'admins' | 'all' | 'apartments' | 'unpaid'
  String _mode = 'admins';
  final Set<int> _selectedApts = {};
  Set<int> _registeredApts = const {};
  bool _sending = false;
  String? _localErr;

  @override
  void initState() {
    super.initState();
    _loadRegisteredApts();
  }

  Future<void> _loadRegisteredApts() async {
    final apts = await widget.cubit.fetchPushRegisteredApts();
    if (mounted) {
      setState(() => _registeredApts = apts);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  List<int> _unpaidApts() {
    final m = widget.state.currentMonth;
    if (m == null) return const [];
    final list = <int>[];
    for (int i = 1; i <= m.aptsCount; i++) {
      if (!m.payments.containsKey(i)) list.add(i);
    }
    return list;
  }

  void _selectMode(String mode) {
    if (_sending) return;
    setState(() {
      _mode = mode;
      _localErr = null;
      if (mode == 'unpaid') {
        final m = widget.state.currentMonth;
        if (m != null) {
          final s = widget.state.s;
          if (_titleCtrl.text.trim().isEmpty) {
            _titleCtrl.text = s.pushDefaultUnpaidTitle(m.monthNum);
          }
          if (_bodyCtrl.text.trim().isEmpty) {
            _bodyCtrl.text = s.pushDefaultUnpaidBody(m.monthNum);
          }
        }
      }
    });
  }

  Future<void> _send() async {
    final s = widget.state.s;
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      setState(() => _localErr = s.errPushFieldsRequired);
      return;
    }

    String audience = _mode;
    List<int>? targets;
    if (_mode == 'apartments') {
      if (_selectedApts.isEmpty) {
        setState(() => _localErr = s.pushErrSelectApt);
        return;
      }
      targets = _selectedApts.toList()..sort();
    } else if (_mode == 'unpaid') {
      final unpaid = _unpaidApts();
      if (unpaid.isEmpty) {
        setState(() => _localErr = s.pushAllPaidHint);
        return;
      }
      audience = 'apartments';
      targets = unpaid;
    }

    setState(() {
      _sending = true;
      _localErr = null;
    });
    final ok = await widget.cubit.sendManualPushNotification(
      title: title,
      body: body,
      audience: audience,
      targetAptNums: targets,
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

  Widget _modePill({
    required String value,
    required String label,
    required Color activeColor,
    required Color activeTextColor,
    required bool isDark,
  }) {
    final selected = _mode == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectMode(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? activeColor.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: selected ? activeTextColor : AppColors.textSecondary(isDark),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state.s;
    final isDark = widget.state.isDarkMode;
    final month = widget.state.currentMonth;
    final aptsCount = month?.aptsCount ?? 13;
    final unpaidApts = _unpaidApts();

    final sendLabel = switch (_mode) {
      'admins' => s.pushSendAdminTestBtn,
      'apartments' => s.pushSendSelectedBtn(_selectedApts.length),
      'unpaid' => s.pushSendUnpaidBtn(unpaidApts.length),
      _ => s.pushSendAllBtn,
    };
    final sendIcon = switch (_mode) {
      'admins' => Icons.shield_outlined,
      'unpaid' => Icons.warning_amber_rounded,
      _ => Icons.send_rounded,
    };

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
          // 4-Mode Audience Selector (2x2 clean pill grid)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface(isDark),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border(isDark)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _modePill(
                      value: 'admins',
                      label: s.pushAudienceAdminOnly,
                      activeColor: AppColors.primary,
                      activeTextColor: AppColors.primaryText(isDark),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 4),
                    _modePill(
                      value: 'all',
                      label: s.pushAudienceAll,
                      activeColor: AppColors.emerald,
                      activeTextColor: AppColors.emeraldText(isDark),
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _modePill(
                      value: 'apartments',
                      label: s.pushAudienceSpecificApt,
                      activeColor: const Color(0xFF8B5CF6),
                      activeTextColor: isDark
                          ? const Color(0xFFC4B5FD)
                          : const Color(0xFF6D28D9),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 4),
                    _modePill(
                      value: 'unpaid',
                      label: s.pushAudienceUnpaid,
                      activeColor: AppColors.danger,
                      activeTextColor: AppColors.dangerText(isDark),
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Specific Apartment Multi-Select Chips
          if (_mode == 'apartments') ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              s.pushSelectAptsHint,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(aptsCount, (idx) {
                final aptNum = idx + 1;
                final isSelected = _selectedApts.contains(aptNum);
                final hasPush = _registeredApts.contains(aptNum);
                return FilterChip(
                  selected: isSelected,
                  showCheckmark: false,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.state.aptLabel(aptNum),
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary(isDark),
                        ),
                      ),
                      if (hasPush) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.notifications_active_rounded,
                          size: 13,
                          color: isSelected
                              ? Colors.white
                              : AppColors.emeraldText(isDark),
                        ),
                      ],
                    ],
                  ),
                  selectedColor: const Color(0xFF7C3AED),
                  backgroundColor: AppColors.surface(isDark),
                  side: BorderSide(
                    color: isSelected
                        ? const Color(0xFF7C3AED)
                        : AppColors.border(isDark),
                  ),
                  onSelected: _sending
                      ? null
                      : (v) {
                          setState(() {
                            if (v) {
                              _selectedApts.add(aptNum);
                            } else {
                              _selectedApts.remove(aptNum);
                            }
                            _localErr = null;
                          });
                        },
                );
              }),
            ),
          ],

          // Unpaid Apartments Summary Banner
          if (_mode == 'unpaid' && month != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: (unpaidApts.isEmpty ? AppColors.emerald : AppColors.danger)
                    .withValues(alpha: isDark ? 0.14 : 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: (unpaidApts.isEmpty ? AppColors.emerald : AppColors.danger)
                      .withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                unpaidApts.isEmpty
                    ? s.pushAllPaidHint
                    : s.pushUnpaidSummary(unpaidApts.length, month.monthNum),
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: unpaidApts.isEmpty
                      ? AppColors.emeraldText(isDark)
                      : AppColors.dangerText(isDark),
                ),
              ),
            ),
          ],

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
              label: sendLabel,
              icon: sendIcon,
              loading: _sending,
              onPressed: _sending ? null : _send,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangeAdminPasswordCard extends StatefulWidget {
  final BuildingCubit cubit;
  final BuildingState state;

  const _ChangeAdminPasswordCard({
    required this.cubit,
    required this.state,
  });

  @override
  State<_ChangeAdminPasswordCard> createState() =>
      _ChangeAdminPasswordCardState();
}

class _ChangeAdminPasswordCardState extends State<_ChangeAdminPasswordCard> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _hideCurrent = true;
  bool _hideNew = true;
  bool _hideConfirm = true;
  bool _saving = false;
  String? _localErr;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final s = widget.state.s;
    final cur = _currentCtrl.text.trim();
    final next = _newCtrl.text.trim();
    final conf = _confirmCtrl.text.trim();

    if (cur.isEmpty || next.isEmpty || conf.isEmpty) {
      setState(() => _localErr = s.changeAdminPassFieldsRequired);
      return;
    }
    if (next.length < 4) {
      setState(() => _localErr = s.errPassTooShort);
      return;
    }
    if (next != conf) {
      setState(() => _localErr = s.errPassMismatch);
      return;
    }

    setState(() {
      _saving = true;
      _localErr = null;
    });

    final err = await widget.cubit.changeAdminPassword(
      currentPass: cur,
      newPass: next,
    );
    if (!mounted) return;
    if (err != null) {
      setState(() {
        _saving = false;
        _localErr = err;
      });
      return;
    }

    setState(() {
      _saving = false;
      _localErr = null;
      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state.s;
    final isDark = widget.state.isDarkMode;
    final newLen = _newCtrl.text.trim().length;

    double strengthFactor = 0;
    Color strengthColor = AppColors.border(isDark);
    String strengthLabel = '';
    if (newLen > 0 && newLen < 4) {
      strengthFactor = 0.30;
      strengthColor = AppColors.danger;
      strengthLabel = s.passStrengthWeak;
    } else if (newLen >= 4 && newLen < 7) {
      strengthFactor = 0.65;
      strengthColor = AppColors.amber;
      strengthLabel = s.passStrengthMedium;
    } else if (newLen >= 7) {
      strengthFactor = 1.0;
      strengthColor = AppColors.emerald;
      strengthLabel = s.passStrengthStrong;
    }

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
                  color: AppColors.amber.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.vpn_key_rounded,
                  size: 20,
                  color: isDark ? AppColors.amber : AppColors.amberDarkText,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.changeAdminPassTitle,
                      style: AppTypography.title.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.changeAdminPassSubtitle,
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
          TextField(
            controller: _currentCtrl,
            enabled: !_saving,
            obscureText: _hideCurrent,
            onChanged: (_) {
              if (_localErr != null) setState(() => _localErr = null);
            },
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimary(isDark),
            ),
            decoration: InputDecoration(
              labelText: s.currentAdminPassLabel,
              filled: true,
              fillColor: AppColors.surface(isDark),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: AppColors.textSecondary(isDark),
              ),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _hideCurrent = !_hideCurrent),
                icon: Icon(
                  _hideCurrent
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _newCtrl,
            enabled: !_saving,
            obscureText: _hideNew,
            onChanged: (_) => setState(() => _localErr = null),
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimary(isDark),
            ),
            decoration: InputDecoration(
              labelText: s.newAdminPassLabel,
              filled: true,
              fillColor: AppColors.surface(isDark),
              prefixIcon: Icon(
                Icons.key_rounded,
                size: 18,
                color: AppColors.textSecondary(isDark),
              ),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _hideNew = !_hideNew),
                icon: Icon(
                  _hideNew
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ),
          ),
          if (newLen > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: strengthFactor,
                      minHeight: 5,
                      backgroundColor: AppColors.surface(isDark),
                      valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  strengthLabel,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    color: strengthColor,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _confirmCtrl,
            enabled: !_saving,
            obscureText: _hideConfirm,
            onSubmitted: (_) => _submit(),
            onChanged: (_) {
              if (_localErr != null) setState(() => _localErr = null);
            },
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimary(isDark),
            ),
            decoration: InputDecoration(
              labelText: s.confirmNewAdminPassLabel,
              filled: true,
              fillColor: AppColors.surface(isDark),
              prefixIcon: Icon(
                Icons.verified_user_outlined,
                size: 18,
                color: AppColors.textSecondary(isDark),
              ),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                icon: Icon(
                  _hideConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                  color: AppColors.textSecondary(isDark),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.07),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: AppColors.primaryText(isDark),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    s.changeAdminPassSecurityNote,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(isDark),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
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
              label: s.changeAdminPassBtn,
              icon: Icons.lock_reset_rounded,
              loading: _saving,
              onPressed: _saving ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildingProfileCard extends StatefulWidget {
  final BuildingCubit cubit;
  final BuildingState state;

  const _BuildingProfileCard({
    required this.cubit,
    required this.state,
  });

  @override
  State<_BuildingProfileCard> createState() => _BuildingProfileCardState();
}

class _BuildingProfileCardState extends State<_BuildingProfileCard> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _instaPhoneCtrl;
  late final TextEditingController _instaUrlCtrl;
  late final TextEditingController _waCtrl;
  int _syncedBuildingId = -1;
  bool _saving = false;
  String? _localErr;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _cityCtrl = TextEditingController();
    _instaPhoneCtrl = TextEditingController();
    _instaUrlCtrl = TextEditingController();
    _waCtrl = TextEditingController();
    _syncFromState();
  }

  void _syncFromState() {
    final b = widget.state.building;
    if (_syncedBuildingId != b.id) {
      _syncedBuildingId = b.id;
      _nameCtrl.text = b.name;
      _cityCtrl.text = b.city;
      _instaPhoneCtrl.text = b.instapayPhone;
      _instaUrlCtrl.text = b.instapayUrl;
      _waCtrl.text = b.managerWhatsapp;
    }
  }

  @override
  void didUpdateWidget(covariant _BuildingProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.building.id != widget.state.building.id) {
      _syncFromState();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _instaPhoneCtrl.dispose();
    _instaUrlCtrl.dispose();
    _waCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = widget.state.s;
    final cleanName = _nameCtrl.text.trim();
    if (cleanName.isEmpty) {
      setState(() => _localErr = s.registerNameRequiredErr);
      return;
    }
    setState(() {
      _saving = true;
      _localErr = null;
    });
    final err = await widget.cubit.updateBuildingProfile(
      name: cleanName,
      city: _cityCtrl.text.trim(),
      instapayPhone: _instaPhoneCtrl.text.trim(),
      instapayUrl: _instaUrlCtrl.text.trim(),
      managerWhatsapp: _waCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _localErr = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state.s;
    final isDark = widget.state.isDarkMode;
    final b = widget.state.building;
    final shareUrl = buildBuildingShareUrl(
      b.code,
      isDefaultBuilding: b.isDefaultBuilding,
    );

    final isTrial = b.isTrial;
    final statusColor = isTrial ? AppColors.amber : AppColors.emerald;
    final statusText = isTrial
        ? '${s.subStatusTrial} • ${s.subDaysRemainingBadge(b.daysRemaining)}'
        : s.subStatusActive;

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
                  color: AppColors.emerald.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.domain_rounded,
                  size: 20,
                  color: AppColors.emeraldText(isDark),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.buildingProfileTitle,
                      style: AppTypography.title.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.buildingProfileSubtitle,
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
          Container(
            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        s.buildingCodeBadge(b.code),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primaryText(isDark),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        statusText,
                        style: AppTypography.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  s.shareLinkLabel,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: SelectableText(
                    shareUrl,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: shareUrl));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(s.buildingCodeCopiedToast),
                              backgroundColor: AppColors.emerald,
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 15),
                        label: Text(s.copyLinkBtn),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final msg = s.buildingShareWhatsappMsg(
                            b.name,
                            shareUrl,
                            b.code,
                          );
                          final uri = Uri.parse(
                            'https://wa.me/?text=${Uri.encodeComponent(msg)}',
                          );
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 15),
                        label: Text(s.shareWhatsappBtn),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _nameCtrl,
            enabled: !_saving,
            onChanged: (_) {
              if (_localErr != null) setState(() => _localErr = null);
            },
            decoration: InputDecoration(
              labelText: s.buildingNameLabel,
              filled: true,
              fillColor: AppColors.surface(isDark),
              prefixIcon: const Icon(Icons.apartment_rounded, size: 18),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _cityCtrl,
            enabled: !_saving,
            decoration: InputDecoration(
              labelText: s.buildingCityLabel,
              filled: true,
              fillColor: AppColors.surface(isDark),
              prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _instaPhoneCtrl,
            enabled: !_saving,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            decoration: InputDecoration(
              labelText: s.instapayPhoneLabel,
              filled: true,
              fillColor: AppColors.surface(isDark),
              prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _instaUrlCtrl,
            enabled: !_saving,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              labelText: s.instapayUrlLabel,
              filled: true,
              fillColor: AppColors.surface(isDark),
              prefixIcon: const Icon(Icons.link_rounded, size: 18),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _waCtrl,
            enabled: !_saving,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ],
            decoration: InputDecoration(
              labelText: s.managerWhatsappLabel,
              filled: true,
              fillColor: AppColors.surface(isDark),
              prefixIcon: const Icon(Icons.chat_outlined, size: 18),
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
              label: s.saveBuildingProfileBtn,
              icon: Icons.save_rounded,
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ),
        ],
      ),
    );
  }
}
