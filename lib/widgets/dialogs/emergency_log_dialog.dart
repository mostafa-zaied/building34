import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../common/app_button.dart';

Future<void> showEmergencyLogDialog({
  required BuildContext context,
  required BuildingCubit cubit,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: const _EmergencyLogDialog(),
    ),
  );
}

class _EmergencyLogDialog extends StatefulWidget {
  const _EmergencyLogDialog();

  @override
  State<_EmergencyLogDialog> createState() => _EmergencyLogDialogState();
}

class _EmergencyLogDialogState extends State<_EmergencyLogDialog> {
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
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
    final ok = await cubit.addEmergencyTransaction(amount, reason);
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
        final month = state.currentMonth;
        final totalEmerg = (state.baseEmergency + (month?.forEmerg ?? 0)).toInt();

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          backgroundColor: AppColors.card(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            side: BorderSide(color: AppColors.border(isDark)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 480,
              maxHeight: MediaQuery.sizeOf(context).height * 0.84,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          Icons.shield_rounded,
                          size: 18,
                          color: AppColors.emeraldText(isDark),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.emergencyLogTitle,
                              style: AppTypography.headline.copyWith(
                                fontSize: 15,
                                color: AppColors.textPrimary(isDark),
                              ),
                            ),
                            Text(
                              state.s.currency(totalEmerg),
                              style: AppTypography.label.copyWith(
                                color: AppColors.emeraldText(isDark),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close_rounded, color: AppColors.textSecondary(isDark)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Divider(height: 1, color: AppColors.border(isDark)),
                  const SizedBox(height: AppSpacing.md),

                  if (state.isAdminOpen) ...[
                    Container(
                      padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface(isDark),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.border(isDark)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                              fillColor: AppColors.card(isDark),
                              prefixIcon: Icon(
                                Icons.payments_outlined,
                                size: 18,
                                color: AppColors.amber,
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
                              hintText: s.emergencyReasonHint,
                              filled: true,
                              fillColor: AppColors.card(isDark),
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
                            label: s.recordExpenseBtn,
                            icon: Icons.remove_circle_outline_rounded,
                            backgroundColor: AppColors.amber,
                            foregroundColor: Colors.black,
                            loading: _submitting,
                            onPressed: _submitting ? null : () => _submit(cubit),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Divider(height: 1, color: AppColors.border(isDark)),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  if (state.emergencyTransactions.isEmpty)
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(vertical: 28),
                      child: Text(
                        s.emergencyLogEmpty,
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: state.emergencyTransactions.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
                        itemBuilder: (_, idx) {
                          final tx = state.emergencyTransactions[idx];
                          return Container(
                            padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surface(isDark),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: AppColors.border(isDark)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsetsDirectional.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Text(
                                    '-${state.s.currency(tx.amount.toInt())}',
                                    style: AppTypography.label.copyWith(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
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
                                    onPressed: () => cubit.deleteEmergencyTransaction(tx.id),
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                    color: AppColors.danger,
                                    tooltip: state.s.deleteTooltip,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
