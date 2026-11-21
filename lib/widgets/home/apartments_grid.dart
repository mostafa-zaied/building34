import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../dialogs/apartment_payment_dialog.dart';
import 'apartment_card.dart';

class ApartmentsGrid extends StatefulWidget {
  final BuildingState state;
  final MonthBill month;
  final ValueChanged<int> onTapApartment;

  const ApartmentsGrid({
    super.key,
    required this.state,
    required this.month,
    required this.onTapApartment,
  });

  @override
  State<ApartmentsGrid> createState() => _ApartmentsGridState();
}

class _ApartmentsGridState extends State<ApartmentsGrid> {
  /// 0 = Active monthly apartments, 1 = Closed/non-monthly apartments
  int _selectedTab = 0;

  List<int> _activeAptNums(BuildingState state, MonthBill month) {
    final closedSet = state.closedAptNums.toSet();
    final maxClosed =
        closedSet.isEmpty ? 0 : closedSet.reduce((a, b) => a > b ? a : b);
    final totalApts = (month.aptsCount + closedSet.length) > maxClosed
        ? (month.aptsCount + closedSet.length)
        : maxClosed;
    return [
      for (int i = 1; i <= totalApts; i++)
        if (!closedSet.contains(i)) i,
    ];
  }

  Future<void> _showSpecialFeeDialog(
    BuildContext context,
    BuildingCubit cubit,
  ) async {
    final state = widget.state;
    final month = widget.month;
    final s = state.s;
    final isDark = state.isDarkMode;
    final nameCtrl = TextEditingController();
    final amtCtrl = TextEditingController(text: '200');
    final activeNums = _activeAptNums(state, month);
    final closedNums = state.closedAptNums;
    final allNums = [...activeNums, ...closedNums]..sort();

    String targetMode = 'all'; // 'all' | 'closed' | 'custom'
    String amountMode = 'per_apt'; // 'per_apt' | 'split'
    final customSelected = <int>{...closedNums};
    String? errMsg;
    bool saving = false;

    List<int> currentTargetNums() {
      if (targetMode == 'all') return allNums;
      if (targetMode == 'closed') return closedNums;
      return customSelected.toList()..sort();
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final targets = currentTargetNums();
          final rawAmt = double.tryParse(amtCtrl.text.trim()) ?? 0;
          final perApt = (amountMode == 'split' && targets.isNotEmpty)
              ? (rawAmt / targets.length).ceil().toDouble()
              : rawAmt;
          final totalPreview = (perApt * targets.length).round();

          return AlertDialog(
            backgroundColor: AppColors.card(isDark),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.amber,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    s.specialFeeDialogTitle,
                    style: AppTypography.headline.copyWith(
                      fontSize: 15,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      enabled: !saving,
                      decoration: InputDecoration(
                        labelText: s.specialFeeNameLabel,
                        hintText: s.specialFeeNameHint,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      s.specialFeeTargetLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: _choicePill(
                            label: s.specialFeeTargetAll(allNums.length),
                            selected: targetMode == 'all',
                            isDark: isDark,
                            onTap: saving
                                ? null
                                : () => setModalState(() => targetMode = 'all'),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: _choicePill(
                            label: s.specialFeeTargetClosed(closedNums.length),
                            selected: targetMode == 'closed',
                            isDark: isDark,
                            onTap: saving
                                ? null
                                : () =>
                                    setModalState(() => targetMode = 'closed'),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: _choicePill(
                            label: s.specialFeeTargetCustom,
                            selected: targetMode == 'custom',
                            isDark: isDark,
                            onTap: saving
                                ? null
                                : () =>
                                    setModalState(() => targetMode = 'custom'),
                          ),
                        ),
                      ],
                    ),
                    if (targetMode == 'custom') ...[
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: allNums.map((aptNum) {
                          final sel = customSelected.contains(aptNum);
                          final isClosedApt = closedNums.contains(aptNum);
                          return FilterChip(
                            label: Text(
                              '${isClosedApt ? '🔒 ' : ''}${state.aptLabel(aptNum)}',
                              style: AppTypography.caption.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: sel
                                    ? AppColors.amber
                                    : AppColors.textSecondary(isDark),
                              ),
                            ),
                            selected: sel,
                            onSelected: saving
                                ? null
                                : (v) => setModalState(() {
                                      if (v) {
                                        customSelected.add(aptNum);
                                      } else {
                                        customSelected.remove(aptNum);
                                      }
                                    }),
                            selectedColor:
                                AppColors.amber.withValues(alpha: 0.16),
                            checkmarkColor: AppColors.amber,
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _choicePill(
                            label: s.specialFeeModePerApt,
                            selected: amountMode == 'per_apt',
                            isDark: isDark,
                            onTap: saving
                                ? null
                                : () =>
                                    setModalState(() => amountMode = 'per_apt'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _choicePill(
                            label: s.specialFeeModeSplit,
                            selected: amountMode == 'split',
                            isDark: isDark,
                            onTap: saving
                                ? null
                                : () =>
                                    setModalState(() => amountMode = 'split'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: amtCtrl,
                      enabled: !saving,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      ],
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        labelText: amountMode == 'split'
                            ? s.specialFeeAmountTotalLabel
                            : s.specialFeeAmountPerAptLabel,
                        hintText: '200',
                      ),
                    ),
                    if (targets.isNotEmpty && perApt > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.emerald.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Text(
                          s.specialFeePreviewLine(
                            perApt.round(),
                            targets.length,
                            totalPreview,
                          ),
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.emeraldText(isDark),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                    if (errMsg != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        errMsg!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(ctx),
                child: Text(s.cancel),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  foregroundColor: const Color(0xFF0F172A),
                ),
                onPressed: saving
                    ? null
                    : () async {
                        final cleanName = nameCtrl.text.trim();
                        if (cleanName.isEmpty ||
                            perApt <= 0 ||
                            targets.isEmpty) {
                          setModalState(() => errMsg = s.errEmergencyInput);
                          return;
                        }
                        setModalState(() {
                          saving = true;
                          errMsg = null;
                        });
                        final ok = await cubit.addSpecialAptFees(
                          aptNums: targets,
                          label: cleanName,
                          amount: perApt,
                        );
                        if (ok && ctx.mounted) {
                          Navigator.pop(ctx);
                        } else if (ctx.mounted) {
                          setModalState(() => saving = false);
                        }
                      },
                child: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        s.specialFeeApplyBtn,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ],
          );
        },
      ),
    );

    Future.delayed(const Duration(milliseconds: 350), () {
      nameCtrl.dispose();
      amtCtrl.dispose();
    });
  }

  Widget _choicePill({
    required String label,
    required bool selected,
    required bool isDark,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.16)
              : AppColors.surface(isDark),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border(isDark),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: selected
                ? AppColors.primaryText(isDark)
                : AppColors.textSecondary(isDark),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final month = widget.month;
    final s = state.s;
    final isDark = state.isDarkMode;
    final activeAptNums = _activeAptNums(state, month);
    final activeCount = activeAptNums.length;
    final allAptNums = [...activeAptNums, ...state.closedAptNums];
    final paidCount =
        activeAptNums.where((n) => month.payments.containsKey(n)).length;
    int passSetCount = 0;
    for (final aptNum in allAptNums) {
      if (state.apartmentHasPasscode[aptNum] == true) passSetCount++;
    }
    final totalPassTarget = allAptNums.length;
    final progress =
        activeCount > 0 ? (paidCount / activeCount).clamp(0.0, 1.0) : 0.0;
    final effectiveTab = state.closedAptNums.isEmpty ? 0 : _selectedTab;

    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border(isDark)),
        boxShadow: AppShadows.card(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Title + Admin Special Fee + Passcode counter + Paid counter
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.primary
                          .withValues(alpha: isDark ? 0.14 : 0.10),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      size: 16,
                      color: AppColors.primaryText(isDark),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    s.tapAptTitle,
                    style: AppTypography.headline.copyWith(
                      fontSize: 15,
                      color: AppColors.textPrimary(isDark),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (state.isAdminAuthenticated)
                    InkWell(
                      onTap: () => _showSpecialFeeDialog(
                        context,
                        context.read<BuildingCubit>(),
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: Container(
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.amber
                              .withValues(alpha: isDark ? 0.18 : 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: AppColors.amber.withValues(alpha: 0.40),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              size: 14,
                              color: AppColors.amber,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              s.specialFeeBtn,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.amber,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (state.isAdminAuthenticated && state.requireAptPassOnOpen)
                    Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: (passSetCount == totalPassTarget
                                ? AppColors.emerald
                                : AppColors.amber)
                            .withValues(alpha: isDark ? 0.14 : 0.10),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: (passSetCount == totalPassTarget
                                  ? AppColors.emerald
                                  : AppColors.amber)
                              .withValues(alpha: 0.32),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            passSetCount == totalPassTarget
                                ? Icons.lock_rounded
                                : Icons.vpn_key_outlined,
                            size: 13,
                            color: passSetCount == totalPassTarget
                                ? AppColors.emeraldText(isDark)
                                : AppColors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            s.adminPasscodeSetCounter(
                              passSetCount,
                              totalPassTarget,
                            ),
                            style: AppTypography.caption.copyWith(
                              color: passSetCount == totalPassTarget
                                  ? AppColors.emeraldText(isDark)
                                  : AppColors.amber,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emerald
                          .withValues(alpha: isDark ? 0.14 : 0.10),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: AppColors.emerald.withValues(alpha: 0.30),
                      ),
                    ),
                    child: Text(
                      s.paidCounter(paidCount, month.aptsCount),
                      style: AppTypography.label.copyWith(
                        color: AppColors.emeraldText(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 2-Tab Switcher: Active (13) vs Closed (5)
          if (state.closedAptNums.isNotEmpty) ...[
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
                    child: _tabBtn(
                      label: s.aptsTabActive,
                      count: activeCount,
                      selected: effectiveTab == 0,
                      isAmber: false,
                      isDark: isDark,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _tabBtn(
                      label: s.aptsTabClosed,
                      count: state.closedAptNums.length,
                      selected: effectiveTab == 1,
                      isAmber: true,
                      isDark: isDark,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          if (effectiveTab == 0) ...[
            // Sleek Collection Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.surface(isDark),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? AppColors.emerald : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Active Apartments Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 600
                    ? 4
                    : (constraints.maxWidth >= 420 ? 3 : 2);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeAptNums.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisExtent: 74,
                  ),
                  itemBuilder: (context, idx) {
                    final aptNum = activeAptNums[idx];
                    final payment = month.payments[aptNum];
                    final isPaid = payment != null;

                    final extraTotal = month.extraTotalFor(aptNum);
                    final specialDue = state.specialAptFees
                        .where((f) => f.aptNum == aptNum && !f.isPaid)
                        .fold<double>(0, (sum, f) => sum + f.amount)
                        .round();
                    final combinedExtra = extraTotal + specialDue;

                    IconData? lockIcon;
                    Color? lockIconColor;
                    if (state.requireAptPassOnOpen) {
                      final unlockedHere = state.myAptNum == aptNum &&
                          state.savedAptPass != null &&
                          state.savedAptPass!.isNotEmpty;
                      final hasPass =
                          state.apartmentHasPasscode[aptNum] ?? false;
                      if (unlockedHere && hasPass) {
                        lockIcon = Icons.lock_open_rounded;
                        lockIconColor = AppColors.emeraldText(isDark);
                      } else if (hasPass) {
                        lockIcon = Icons.lock_rounded;
                        lockIconColor = state.isAdminAuthenticated
                            ? AppColors.emeraldText(isDark)
                            : AppColors.textSecondary(isDark);
                      } else {
                        lockIcon = Icons.vpn_key_outlined;
                        lockIconColor = AppColors.amber;
                      }
                    }
                    return ApartmentCard(
                      aptNum: aptNum,
                      label: state.aptLabel(aptNum),
                      amountText: s.currency(month.dueFor(aptNum) + specialDue),
                      paidLabel: s.paidBadge,
                      pendingLabel: s.pendingPaymentBadge,
                      overdueLabel: s.overdueBadge,
                      isPaid: isPaid,
                      isOverdue: !isPaid && month.isPastDue,
                      hasReceipt: payment?.receiptUrl != null,
                      extraBadgeText: combinedExtra > 0
                          ? s.extraBadge(combinedExtra)
                          : null,
                      lockIcon: lockIcon,
                      lockIconColor: lockIconColor,
                      onTap: () => widget.onTapApartment(aptNum),
                    );
                  },
                );
              },
            ),
          ] else ...[
            // Closed Apartments Tab (14..18)
            Container(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.amber.withValues(alpha: 0.30),
                ),
              ),
              child: Text(
                s.closedAptsInfoBanner,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary(isDark),
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final aptNum in state.closedAptNums) ...[
              _buildClosedAptCard(
                context: context,
                aptNum: aptNum,
                state: state,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildClosedAptCard({
    required BuildContext context,
    required int aptNum,
    required BuildingState state,
    required bool isDark,
  }) {
    final s = state.s;
    final cubit = context.read<BuildingCubit>();
    final fees = state.specialAptFees.where((f) => f.aptNum == aptNum).toList();
    final pendingSum = fees
        .where((f) => !f.isPaid)
        .fold<double>(0, (sum, f) => sum + f.amount)
        .round();
    final hasDue = pendingSum > 0;
    final accent = hasDue ? AppColors.amber : AppColors.emeraldText(isDark);

    IconData? lockIcon;
    Color? lockIconColor;
    if (state.requireAptPassOnOpen) {
      final unlockedHere = state.myAptNum == aptNum &&
          state.savedAptPass != null &&
          state.savedAptPass!.isNotEmpty;
      final hasPass = state.apartmentHasPasscode[aptNum] ?? false;
      if (unlockedHere && hasPass) {
        lockIcon = Icons.lock_open_rounded;
        lockIconColor = AppColors.emeraldText(isDark);
      } else if (hasPass) {
        lockIcon = Icons.lock_rounded;
        lockIconColor = state.isAdminAuthenticated
            ? AppColors.emeraldText(isDark)
            : AppColors.textSecondary(isDark);
      } else {
        lockIcon = Icons.vpn_key_outlined;
        lockIconColor = AppColors.amber;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: state.requireAptPassOnOpen
            ? () => showClosedApartmentPasscodeDialog(
                  context: context,
                  cubit: cubit,
                  state: state,
                  aptNum: aptNum,
                )
            : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsetsDirectional.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: (hasDue ? AppColors.amber : AppColors.emerald)
                .withValues(alpha: isDark ? 0.07 : 0.05),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: (hasDue ? AppColors.amber : AppColors.emerald)
                  .withValues(alpha: 0.32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                state.aptLabel(aptNum),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.title.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary(isDark),
                                ),
                              ),
                            ),
                            if (lockIcon != null) ...[
                              const SizedBox(width: 6),
                              Icon(
                                lockIcon,
                                size: 15,
                                color: lockIconColor,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hasDue
                              ? s.closedAptDueLabel(s.currency(pendingSum))
                              : s.closedAptClearLabel,
                          style: AppTypography.caption.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
              if (state.isAdminAuthenticated) ...[
                InkWell(
                  onTap: state.busy
                      ? null
                      : () => cubit.setApartmentClosed(aptNum, false),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emerald
                          .withValues(alpha: isDark ? 0.16 : 0.10),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: AppColors.emerald.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 13,
                          color: AppColors.emeraldText(isDark),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          s.convertToActiveBtn,
                          style: AppTypography.caption.copyWith(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.emeraldText(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Tooltip(
                message: s.aptStatusClosed,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: isDark ? 0.14 : 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: AppColors.amber.withValues(alpha: 0.32),
                    ),
                  ),
                  child: const Icon(
                    Icons.no_meeting_room_outlined,
                    size: 16,
                    color: AppColors.amber,
                  ),
                ),
              ),
            ],
          ),
          if (fees.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            for (final fee in fees) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 5),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface(isDark),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '• ${fee.label} (${s.currency(fee.amount.round())})',
                        style: AppTypography.caption.copyWith(
                          color: fee.isPaid
                              ? AppColors.textSecondary(isDark)
                              : AppColors.textPrimary(isDark),
                          fontWeight: FontWeight.w700,
                          decoration: fee.isPaid
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (fee.isPaid) ...[
                      Text(
                        s.specialFeePaidTag,
                        style: AppTypography.caption.copyWith(
                          fontSize: 10.5,
                          color: AppColors.emeraldText(isDark),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (state.isAdminAuthenticated) ...[
                        const SizedBox(width: 6),
                        Tooltip(
                          message: s.deleteTooltip,
                          child: InkWell(
                            onTap: state.busy
                                ? null
                                : () => cubit.deleteSpecialAptFee(fee.id),
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: AppColors.dangerText(isDark),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ] else if (state.isAdminAuthenticated) ...[
                      InkWell(
                        onTap: state.busy
                            ? null
                            : () => cubit.collectSpecialAptFee(fee.id),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emerald,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            s.specialFeeCollectBtn,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: state.busy
                            ? null
                            : () => cubit.deleteSpecialAptFee(fee.id),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.dangerText(isDark),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
        ),
      ),
    );
  }

  Widget _tabBtn({
    required String label,
    required int count,
    required bool selected,
    required bool isAmber,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final bg = !selected
        ? Colors.transparent
        : (isAmber ? AppColors.amber : AppColors.primaryActionBg(isDark));
    final fg = !selected
        ? AppColors.textSecondary(isDark)
        : (isAmber ? const Color(0xFF0F172A) : AppColors.onPrimaryAction(isDark));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? fg.withValues(alpha: 0.16)
                      : AppColors.card(isDark),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '$count',
                  style: AppTypography.caption.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: fg,
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
