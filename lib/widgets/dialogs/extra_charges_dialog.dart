import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../common/app_button.dart';
import '../common/app_card.dart';
import '../common/busy_overlay.dart';
import 'confirm_delete_dialog.dart';

Future<void> showExtraChargesDialog({
  required BuildContext context,
  required BuildingCubit cubit,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: ExtraChargesScreen(cubit: cubit),
      ),
    ),
  );
}

class ExtraChargesScreen extends StatefulWidget {
  final BuildingCubit cubit;

  const ExtraChargesScreen({super.key, required this.cubit});

  @override
  State<ExtraChargesScreen> createState() => _ExtraChargesScreenState();
}

class _ExtraChargesScreenState extends State<ExtraChargesScreen> {
  final _amountCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final Set<int> _selectedApts = {};
  bool _submitting = false;
  String? _localError;

  String _normalizeDigits(String input) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    var out = input;
    for (int i = 0; i < 10; i++) {
      out = out.replaceAll(arabic[i], '$i');
    }
    return out;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuildingCubit, BuildingState>(
      builder: (context, state) {
        final s = state.s;
        final isDark = state.isDarkMode;
        final month = state.currentMonth;

        return BusyOverlay(
          busy: state.busy,
          isDark: isDark,
          child: Scaffold(
            backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
            appBar: AppBar(
              backgroundColor: AppColors.surface(isDark),
              elevation: 0,
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      s.extraChargesTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.headline.copyWith(
                        color: AppColors.textPrimary(isDark),
                      ),
                    ),
                  ),
                  if (month != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '${month.monthNum}/${month.yearNum}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primaryText(isDark),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            body: month == null
                ? const SizedBox.shrink()
                : Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: ListView(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                        children: [
                          // 1. Add Extra Charge Card
                          AppCard(
                            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s.selectAptsLabel,
                                        style: AppTypography.label.copyWith(
                                          color: AppColors.textPrimary(isDark),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          if (_selectedApts.length == month.aptsCount) {
                                            _selectedApts.clear();
                                          } else {
                                            for (int i = 1; i <= month.aptsCount; i++) {
                                              _selectedApts.add(i);
                                            }
                                          }
                                          _localError = null;
                                        });
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsetsDirectional.symmetric(
                                          horizontal: 8,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        _selectedApts.length == month.aptsCount
                                            ? s.deselectAllBtn
                                            : s.selectAllBtn,
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.primaryText(isDark),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Wrap(
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xs,
                                  children: List.generate(month.aptsCount, (i) {
                                    final aptNum = i + 1;
                                    final selected = _selectedApts.contains(aptNum);
                                    return FilterChip(
                                      selected: selected,
                                      label: Text(
                                        state.aptLabel(aptNum),
                                        style: AppTypography.caption.copyWith(
                                          color: selected
                                              ? AppColors.onPrimaryAction(isDark)
                                              : AppColors.textPrimary(isDark),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      selectedColor: AppColors.primaryActionBg(isDark),
                                      backgroundColor: AppColors.surface(isDark),
                                      checkmarkColor: AppColors.onPrimaryAction(isDark),
                                      onSelected: (val) {
                                        setState(() {
                                          if (val) {
                                            _selectedApts.add(aptNum);
                                          } else {
                                            _selectedApts.remove(aptNum);
                                          }
                                          _localError = null;
                                        });
                                      },
                                    );
                                  }),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                TextField(
                                  controller: _amountCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.textPrimary(isDark),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: s.extraAmountHint,
                                    filled: true,
                                    fillColor: AppColors.surface(isDark),
                                    prefixIcon: Icon(
                                      Icons.payments_outlined,
                                      size: 18,
                                      color: AppColors.primaryText(isDark),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                TextField(
                                  controller: _reasonCtrl,
                                  maxLines: 2,
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.textPrimary(isDark),
                                  ),
                                  decoration: InputDecoration(
                                    hintText: s.extraReasonHint,
                                    filled: true,
                                    fillColor: AppColors.surface(isDark),
                                    prefixIcon: Icon(
                                      Icons.description_outlined,
                                      size: 18,
                                      color: AppColors.textSecondary(isDark),
                                    ),
                                  ),
                                ),
                                if (_localError != null) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    _localError!,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.md),
                                AppPrimaryButton(
                                  label: s.addExtraChargeBtn,
                                  icon: Icons.add_circle_outline_rounded,
                                  loading: _submitting,
                                  onPressed: _submitting
                                      ? null
                                      : () async {
                                          final amount = double.tryParse(
                                                _normalizeDigits(_amountCtrl.text.trim()),
                                              ) ??
                                              0;
                                          final reason = _reasonCtrl.text.trim();
                                          if (amount <= 0 || reason.isEmpty) {
                                            setState(() => _localError = s.errEmergencyInput);
                                            return;
                                          }
                                          if (_selectedApts.isEmpty) {
                                            setState(
                                              () => _localError = s.errSelectAtLeastOneApt,
                                            );
                                            return;
                                          }
                                          setState(() {
                                            _submitting = true;
                                            _localError = null;
                                          });
                                          final ok = await widget.cubit.addExtraCharges(
                                            aptNums: _selectedApts.toList()..sort(),
                                            amount: amount,
                                            reason: reason,
                                          );
                                          if (!mounted) return;
                                          setState(() {
                                            _submitting = false;
                                            if (ok) {
                                              _amountCtrl.clear();
                                              _reasonCtrl.clear();
                                              _selectedApts.clear();
                                            }
                                          });
                                        },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // 2. Recorded Extra Charges Card
                          AppCard(
                            padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s.extraChargesListTitle,
                                        style: AppTypography.headline.copyWith(
                                          fontSize: 15,
                                          color: AppColors.textPrimary(isDark),
                                        ),
                                      ),
                                    ),
                                    if (month.extraCharges.isNotEmpty)
                                      TextButton.icon(
                                        onPressed: () async {
                                          await showConfirmDeleteDialog(
                                            context: context,
                                            s: s,
                                            isDark: isDark,
                                            message: s.confirmDeleteAllExtraBody,
                                            onConfirm: widget.cubit.deleteAllExtraCharges,
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsetsDirectional.symmetric(
                                            horizontal: 8,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        icon: Icon(
                                          Icons.delete_sweep_outlined,
                                          size: 16,
                                          color: AppColors.dangerText(isDark),
                                        ),
                                        label: Text(
                                          s.deleteAllExtraChargesBtn,
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.dangerText(isDark),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                if (month.extraCharges.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                                    child: Text(
                                      s.noExtraChargesYet,
                                      textAlign: TextAlign.center,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary(isDark),
                                      ),
                                    ),
                                  )
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: month.extraCharges.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: AppSpacing.xs),
                                    itemBuilder: (_, idx) {
                                      final item = month.extraCharges[idx];
                                      return Container(
                                        padding: const EdgeInsetsDirectional.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.sm,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface(isDark),
                                          borderRadius: BorderRadius.circular(AppRadius.md),
                                          border: Border.all(color: AppColors.border(isDark)),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${state.aptLabel(item.aptNum)} • +${s.currency(item.amount.toInt())}',
                                                    style: AppTypography.label.copyWith(
                                                      color: AppColors.primaryText(isDark),
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    item.reason,
                                                    style: AppTypography.caption.copyWith(
                                                      color: AppColors.textSecondary(isDark),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                await showConfirmDeleteDialog(
                                                  context: context,
                                                  s: s,
                                                  isDark: isDark,
                                                  message: s.confirmDeleteExtraBody(
                                                    s.currency(item.amount.toInt()),
                                                  ),
                                                  onConfirm: () =>
                                                      widget.cubit.deleteExtraCharge(item.id),
                                                );
                                              },
                                              icon: Icon(
                                                Icons.delete_outline_rounded,
                                                size: 18,
                                                color: AppColors.dangerText(isDark),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
