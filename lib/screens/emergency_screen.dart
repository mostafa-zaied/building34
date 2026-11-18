import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../cubit/building_cubit.dart';
import '../cubit/building_state.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final cubit = context.read<BuildingCubit>();
        final s = state.s;
        final isDark = state.isDarkMode;
        final totalEmerg = state.baseEmergency.toInt();

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
                  child: SingleChildScrollView(
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

                        // 2. Admin Record Transaction Form (Withdraw / Deposit Tabs)
                        if (state.isAdminOpen) ...[
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
                                    if (state.isAdminOpen)
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
