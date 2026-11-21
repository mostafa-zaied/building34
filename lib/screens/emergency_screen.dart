import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
import '../models/building_models.dart';
import '../widgets/common/app_button.dart';
import '../widgets/dialogs/confirm_delete_dialog.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  bool _isDeposit = false;
  bool _submitting = false;
  String? _localError;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  String _normalizeDigits(String input) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    var out = input;
    for (int i = 0; i < 10; i++) {
      out = out.replaceAll(arabic[i], '$i');
    }
    return out;
  }

  Future<void> _submit(BuildingCubit cubit) async {
    final s = cubit.state.s;
    final normalized = _normalizeDigits(_amountCtrl.text.trim());
    final amount = double.tryParse(normalized) ?? 0;
    final reason = _reasonCtrl.text.trim();
    if (amount <= 0 || reason.isEmpty) {
      setState(() => _localError = s.errEmergencyInput);
      return;
    }

    setState(() {
      _submitting = true;
      _localError = null;
    });
    final signedAmount = _isDeposit ? -amount : amount;
    final ok = await cubit.addEmergencyTransaction(signedAmount, reason);
    if (!mounted) return;
    if (ok) {
      _amountCtrl.clear();
      _reasonCtrl.clear();
      setState(() => _submitting = false);
    } else {
      setState(() {
        _submitting = false;
        _localError = cubit.state.feedbackMessage ?? s.errEmergencySave;
      });
    }
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _showAddArrearDialog(
    BuildContext context,
    BuildingCubit cubit,
    BuildingState state, {
    EmergencyArrear? existing,
  }) async {
    final isEdit = existing != null;
    final s = state.s;
    final isDark = state.isDarkMode;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final amountCtrl = TextEditingController(
      text: existing != null ? existing.amount.round().toString() : '',
    );
    final detailsCtrl = TextEditingController(text: existing?.details ?? '');
    String? errMsg;
    bool saving = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          backgroundColor: AppColors.card(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          title: Row(
            children: [
              Icon(
                isEdit ? Icons.edit_rounded : Icons.pending_actions_rounded,
                color: isEdit ? AppColors.primaryText(isDark) : AppColors.amber,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  isEdit
                      ? s.emergencyArrearsEditTitle
                      : s.emergencyArrearsDialogTitle,
                  style: AppTypography.headline.copyWith(
                    fontSize: 15,
                    color: AppColors.textPrimary(isDark),
                  ),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: titleCtrl,
                    enabled: !saving,
                    decoration: InputDecoration(
                      labelText: s.emergencyArrearsAptLabel,
                      hintText: s.emergencyArrearsAptHint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: amountCtrl,
                    enabled: !saving,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    decoration: InputDecoration(
                      labelText: s.emergencyArrearsAmountLabel,
                      hintText: '700',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: detailsCtrl,
                    enabled: !saving,
                    maxLines: 3,
                    minLines: 2,
                    decoration: InputDecoration(
                      labelText: s.emergencyArrearsDetailsLabel,
                      hintText: s.emergencyArrearsDetailsHint,
                    ),
                  ),
                  if (errMsg != null) ...[
                    const SizedBox(height: AppSpacing.sm),
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
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
              ),
              onPressed: saving
                  ? null
                  : () async {
                      final title = titleCtrl.text.trim();
                      final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                      if (title.isEmpty || amount <= 0) {
                        setModalState(() => errMsg = s.errEmergencyInput);
                        return;
                      }
                      setModalState(() {
                        saving = true;
                        errMsg = null;
                      });
                      final ok = isEdit
                          ? await cubit.updateEmergencyArrear(
                              id: existing.id,
                              title: title,
                              amount: amount,
                              details: detailsCtrl.text.trim(),
                            )
                          : await cubit.addEmergencyArrear(
                              title: title,
                              amount: amount,
                              details: detailsCtrl.text.trim(),
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(s.saveAll),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 350), () {
      titleCtrl.dispose();
      amountCtrl.dispose();
      detailsCtrl.dispose();
    });
  }

  Widget _buildArrearCard({
    required BuildContext context,
    required EmergencyArrear arrear,
    required BuildingState state,
    required BuildingCubit cubit,
    required bool isDark,
  }) {
    final s = state.s;
    final accent = arrear.isCollected
        ? AppColors.emeraldText(isDark)
        : AppColors.amber;

    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (arrear.isCollected ? AppColors.emerald : AppColors.amber)
            .withValues(alpha: isDark ? 0.08 : 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: (arrear.isCollected ? AppColors.emerald : AppColors.amber)
              .withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      arrear.title,
                      style: AppTypography.title.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        arrear.isCollected
                            ? s.emergencyArrearsCollectedBadge
                            : s.emergencyArrearsPendingBadge,
                        style: AppTypography.caption.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                s.currency(arrear.amount.round()),
                style: AppTypography.headline.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
              ),
            ],
          ),
          if (arrear.details.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface(isDark),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: Text(
                arrear.details,
                style: AppTypography.caption.copyWith(
                  fontSize: 12,
                  color: AppColors.textPrimary(isDark),
                  height: 1.5,
                ),
              ),
            ),
          ],
          if (!arrear.isCollected) ...[
            const SizedBox(height: 6),
            Text(
              s.emergencyArrearsAutoNote,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText(isDark),
              ),
            ),
          ],
          if (state.isAdminAuthenticated) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (!arrear.isCollected) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: state.busy
                          ? null
                          : () => cubit.collectEmergencyArrear(arrear.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                      label: Text(
                        s.emergencyArrearsCollectBtn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    tooltip: s.emergencyArrearsEditTitle,
                    onPressed: state.busy
                        ? null
                        : () => _showAddArrearDialog(
                              context,
                              cubit,
                              state,
                              existing: arrear,
                            ),
                    style: IconButton.styleFrom(
                      foregroundColor: AppColors.primaryText(isDark),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 17),
                  ),
                  const SizedBox(width: 4),
                ],
                OutlinedButton.icon(
                  onPressed: state.busy
                      ? null
                      : () => showConfirmDeleteDialog(
                            context: context,
                            s: s,
                            isDark: isDark,
                            message: s.confirmDeleteArrearBody(arrear.title),
                            onConfirm: () =>
                                cubit.deleteEmergencyArrear(arrear.id),
                          ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dangerText(isDark),
                    side: BorderSide(
                      color: AppColors.danger.withValues(alpha: 0.4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: Text(
                    s.confirmDeleteBtn,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.dangerText(isDark),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final s = state.s;
        final isDark = state.isDarkMode;
        final totalEmerg = state.baseEmergency.toInt();
        final pendingArrears = state.pendingEmergencyArrearsTotal.toInt();
        final expectedTotal = totalEmerg + pendingArrears;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideNav = constraints.maxWidth >= 720;

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? const [Color(0xFF0A1124), AppColors.darkBg]
                      : const [Color(0xFFEEF2FF), AppColors.lightBg],
                  stops: const [0.0, 0.35],
                ),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: RefreshIndicator(
                    onRefresh: cubit.refreshData,
                    color: AppColors.emerald,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        isWideNav ? AppSpacing.xxl : 104,
                      ),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Hero Emergency Balance Card
                        Container(
                          padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: AlignmentDirectional.topStart,
                              end: AlignmentDirectional.bottomEnd,
                              colors: isDark
                                  ? const [Color(0xFF0E2322), Color(0xFF10192D)]
                                  : const [Color(0xFFECFDF5), Color(0xFFFFFFFF)],
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                              color: AppColors.emerald.withValues(alpha: 0.35),
                            ),
                            boxShadow: AppShadows.heroCard(isDark),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: AppColors.emerald.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                    child: Icon(
                                      Icons.shield_rounded,
                                      size: 20,
                                      color: AppColors.emeraldText(isDark),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      s.emergencyLogTitle,
                                      style: AppTypography.headline.copyWith(
                                        color: AppColors.textPrimary(isDark),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                s.currency(totalEmerg),
                                style: AppTypography.heroAmount.copyWith(
                                  color: AppColors.emeraldText(isDark),
                                ),
                              ),
                              if (pendingArrears > 0) ...[
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsetsDirectional.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: 9,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.amber
                                              .withValues(alpha: isDark ? 0.12 : 0.08),
                                          borderRadius:
                                              BorderRadius.circular(AppRadius.md),
                                          border: Border.all(
                                            color: AppColors.amber
                                                .withValues(alpha: 0.35),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              s.emergencyArrearsPendingKpi,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTypography.caption.copyWith(
                                                fontSize: 10.5,
                                                color: AppColors.textSecondary(isDark),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '+${s.currency(pendingArrears)}',
                                              style: AppTypography.title.copyWith(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.amber,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsetsDirectional.symmetric(
                                          horizontal: AppSpacing.sm,
                                          vertical: 9,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface(isDark)
                                              .withValues(alpha: 0.72),
                                          borderRadius:
                                              BorderRadius.circular(AppRadius.md),
                                          border: Border.all(
                                            color: AppColors.border(isDark),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              s.emergencyArrearsExpectedKpi,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTypography.caption.copyWith(
                                                fontSize: 10.5,
                                                color: AppColors.textSecondary(isDark),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              s.currency(expectedTotal),
                                              style: AppTypography.title.copyWith(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.emeraldText(isDark),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (state.emergencyTransactions.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.md),
                                Builder(
                                  builder: (_) {
                                    final totalDeposits = state.emergencyTransactions
                                        .where((t) => t.amount < 0)
                                        .fold<double>(0, (sum, t) => sum + t.amount.abs())
                                        .toInt();
                                    final totalWithdrawals = state.emergencyTransactions
                                        .where((t) => t.amount > 0)
                                        .fold<double>(0, (sum, t) => sum + t.amount)
                                        .toInt();
                                    return Wrap(
                                      spacing: AppSpacing.sm,
                                      runSpacing: AppSpacing.xs,
                                      children: [
                                        if (totalDeposits > 0)
                                          _SummaryPill(
                                            icon: Icons.arrow_downward_rounded,
                                            label: '+${s.currency(totalDeposits)}',
                                            color: AppColors.emeraldText(isDark),
                                          ),
                                        if (totalWithdrawals > 0)
                                          _SummaryPill(
                                            icon: Icons.arrow_upward_rounded,
                                            label: '-${s.currency(totalWithdrawals)}',
                                            color: AppColors.danger,
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // 1.5. Pending Dues & Arrears for Emergency Fund
                        if (state.emergencyArrears.isNotEmpty ||
                            state.isAdminAuthenticated) ...[
                          Container(
                            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.card(isDark),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              border: Border.all(
                                color: AppColors.amber.withValues(alpha: 0.30),
                              ),
                              boxShadow: AppShadows.card(isDark),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.pending_actions_rounded,
                                      size: 19,
                                      color: AppColors.amber,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Expanded(
                                      child: Text(
                                        s.emergencyArrearsTitle,
                                        style: AppTypography.title.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary(isDark),
                                        ),
                                      ),
                                    ),
                                    if (state.isAdminAuthenticated)
                                      TextButton.icon(
                                        onPressed: () => _showAddArrearDialog(
                                          context,
                                          cubit,
                                          state,
                                        ),
                                        style: TextButton.styleFrom(
                                          backgroundColor: AppColors.amber
                                              .withValues(alpha: 0.14),
                                          foregroundColor: AppColors.amber,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.md,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(Icons.add_rounded, size: 16),
                                        label: Text(
                                          s.emergencyArrearsAddBtn,
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.amber,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                if (state.emergencyArrears.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.sm,
                                    ),
                                    child: Text(
                                      s.emergencyArrearsEmpty,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary(isDark),
                                      ),
                                    ),
                                  )
                                else
                                  for (int i = 0;
                                      i < state.emergencyArrears.length;
                                      i++) ...[
                                    if (i > 0) const SizedBox(height: AppSpacing.sm),
                                    _buildArrearCard(
                                      context: context,
                                      arrear: state.emergencyArrears[i],
                                      state: state,
                                      cubit: cubit,
                                      isDark: isDark,
                                    ),
                                  ],
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],

                        // 2. Admin Record Transaction Form (Withdraw / Deposit Tabs)
                        if (state.isAdminAuthenticated) ...[
                          Container(
                            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.card(isDark),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              border: Border.all(
                                color: (_isDeposit ? AppColors.emerald : AppColors.amber)
                                    .withValues(alpha: 0.35),
                              ),
                              boxShadow: AppShadows.card(isDark),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Segmented Tab Switcher
                                Container(
                                  padding: const EdgeInsetsDirectional.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface(isDark),
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                    border: Border.all(color: AppColors.border(isDark)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _ModeTab(
                                          label: s.emergencyTabWithdraw,
                                          icon: Icons.remove_circle_outline_rounded,
                                          active: !_isDeposit,
                                          activeColor: AppColors.amber,
                                          isDark: isDark,
                                          onTap: () => setState(() {
                                            _isDeposit = false;
                                            _localError = null;
                                          }),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: _ModeTab(
                                          label: s.emergencyTabDeposit,
                                          icon: Icons.add_circle_outline_rounded,
                                          active: _isDeposit,
                                          activeColor: AppColors.emerald,
                                          isDark: isDark,
                                          onTap: () => setState(() {
                                            _isDeposit = true;
                                            _localError = null;
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                TextField(
                                  controller: _amountCtrl,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                  ],
                                  style: AppTypography.statAmount.copyWith(
                                    fontSize: 16,
                                    color: AppColors.textPrimary(isDark),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: s.emergencyAmountHint,
                                    filled: true,
                                    fillColor: AppColors.surface(isDark),
                                    prefixIcon: Icon(
                                      Icons.payments_outlined,
                                      size: 18,
                                      color: _isDeposit
                                          ? AppColors.emeraldText(isDark)
                                          : AppColors.amber,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                TextField(
                                  controller: _reasonCtrl,
                                  minLines: 2,
                                  maxLines: 4,
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.textPrimary(isDark),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: _isDeposit
                                        ? s.emergencyDepositReasonHint
                                        : s.emergencyReasonHint,
                                    filled: true,
                                    fillColor: AppColors.surface(isDark),
                                    alignLabelWithHint: true,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsetsDirectional.only(bottom: 22),
                                      child: Icon(
                                        Icons.description_outlined,
                                        size: 18,
                                        color: AppColors.textSecondary(isDark),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                if (_localError != null) ...[
                                  Container(
                                    padding: const EdgeInsetsDirectional.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.sm,
                                    ),
                                    margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: AppColors.danger.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                      border: Border.all(
                                        color: AppColors.danger.withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: Text(
                                      _localError!,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.danger,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                                AppPrimaryButton(
                                  label: _isDeposit
                                      ? s.recordDepositBtn
                                      : s.recordExpenseBtn,
                                  icon: _isDeposit
                                      ? Icons.add_circle_outline_rounded
                                      : Icons.remove_circle_outline_rounded,
                                  backgroundColor:
                                      _isDeposit ? AppColors.emerald : AppColors.amber,
                                  foregroundColor: Colors.black,
                                  loading: _submitting,
                                  onPressed: _submitting ? null : () => _submit(cubit),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],

                        // 3. Emergency Transactions Log List
                        if (state.emergencyTransactions.isEmpty)
                          Container(
                            padding: const EdgeInsetsDirectional.all(AppSpacing.xxl),
                            decoration: BoxDecoration(
                              color: AppColors.card(isDark),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              border: Border.all(color: AppColors.border(isDark)),
                            ),
                            child: Text(
                              s.emergencyLogEmpty,
                              textAlign: TextAlign.center,
                              style: AppTypography.body.copyWith(
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.emergencyTransactions.length,
                            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (_, idx) {
                              final tx = state.emergencyTransactions[idx];
                              final isDeposit = tx.amount < 0;
                              final badgeColor = isDeposit
                                  ? AppColors.emeraldText(isDark)
                                  : AppColors.danger;
                              final badgeBg = isDeposit
                                  ? AppColors.emerald.withValues(alpha: 0.14)
                                  : AppColors.danger.withValues(alpha: 0.14);
                              final sign = isDeposit ? '+' : '-';

                              return Container(
                                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.card(isDark),
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(color: AppColors.border(isDark)),
                                  boxShadow: AppShadows.card(isDark),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsetsDirectional.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: badgeBg,
                                        borderRadius: BorderRadius.circular(AppRadius.sm),
                                      ),
                                      child: Text(
                                        '$sign${s.currency(tx.amount.abs().toInt())}',
                                        style: AppTypography.label.copyWith(
                                          color: badgeColor,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx.reason,
                                            style: AppTypography.body.copyWith(
                                              color: AppColors.textPrimary(isDark),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _formatDate(tx.createdAt),
                                            style: AppTypography.caption.copyWith(
                                              color: AppColors.textSecondary(isDark),
                                              fontSize: 10.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (state.isAdminAuthenticated)
                                      IconButton(
                                        onPressed: () async {
                                          await showConfirmDeleteDialog(
                                            context: context,
                                            s: s,
                                            isDark: isDark,
                                            message: s.confirmDeleteTxBody(
                                              s.currency(tx.amount.abs().toInt()),
                                            ),
                                            onConfirm: () => cubit.deleteEmergencyTransaction(tx.id),
                                          );
                                        },
                                        icon: const Icon(Icons.delete_outline_rounded, size: 19),
                                        color: AppColors.danger,
                                        tooltip: s.deleteTooltip,
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final bool isDark;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsetsDirectional.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: active ? activeColor.withValues(alpha: isDark ? 0.22 : 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: active ? activeColor.withValues(alpha: 0.65) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? activeColor : AppColors.textSecondary(isDark),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.label.copyWith(
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active
                    ? (isDark ? activeColor : AppColors.textPrimary(isDark))
                    : AppColors.textSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
