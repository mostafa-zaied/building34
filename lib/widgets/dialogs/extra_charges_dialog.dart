import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../common/app_button.dart';
import '../common/busy_overlay.dart';
import 'confirm_delete_dialog.dart';

Future<void> showExtraChargesDialog({
  required BuildContext context,
  required BuildingCubit cubit,
}) async {
  final amountCtrl = TextEditingController();
  final reasonCtrl = TextEditingController();
  final selectedApts = <int>{};
  bool submitting = false;
  String? localError;

  String normalizeDigits(String input) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    var out = input;
    for (int i = 0; i < 10; i++) {
      out = out.replaceAll(arabic[i], '$i');
    }
    return out;
  }

  await showDialog<void>(
    context: context,
    builder: (ctx) => BlocProvider.value(
      value: cubit,
      child: BlocBuilder<BuildingCubit, BuildingState>(
        builder: (ctx, state) {
          final s = state.s;
          final isDark = state.isDarkMode;
          final month = state.currentMonth;
          if (month == null) return const SizedBox.shrink();

          return StatefulBuilder(
            builder: (ctx, setModalState) => Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              backgroundColor: AppColors.card(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                side: BorderSide(color: AppColors.border(isDark)),
              ),
              child: BusyOverlay(
                busy: state.busy,
                isDark: isDark,
                child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 480,
                  maxHeight: MediaQuery.sizeOf(ctx).height * 0.86,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.surface(isDark),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              Icons.add_card_rounded,
                              size: 18,
                              color: AppColors.primaryText(isDark),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              s.extraChargesTitle,
                              style: AppTypography.headline.copyWith(
                                fontSize: 16,
                                color: AppColors.textPrimary(isDark),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: AppColors.border(isDark)),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
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
                                    setModalState(() {
                                      if (selectedApts.length == month.aptsCount) {
                                        selectedApts.clear();
                                      } else {
                                        for (int i = 1; i <= month.aptsCount; i++) {
                                          selectedApts.add(i);
                                        }
                                      }
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
                                    selectedApts.length == month.aptsCount
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
                                final selected = selectedApts.contains(aptNum);
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
                                    setModalState(() {
                                      if (val) {
                                        selectedApts.add(aptNum);
                                      } else {
                                        selectedApts.remove(aptNum);
                                      }
                                      localError = null;
                                    });
                                  },
                                );
                              }),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextField(
                              controller: amountCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: s.extraAmountHint,
                                prefixIcon: Icon(
                                  Icons.payments_outlined,
                                  size: 18,
                                  color: AppColors.primaryText(isDark),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextField(
                              controller: reasonCtrl,
                              minLines: 2,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: s.extraReasonHint,
                                prefixIcon: Icon(
                                  Icons.description_outlined,
                                  size: 18,
                                  color: AppColors.textSecondary(isDark),
                                ),
                              ),
                            ),
                            if (localError != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                localError!,
                                textAlign: TextAlign.center,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.dangerText(isDark),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            AppPrimaryButton(
                              label: s.addExtraChargeBtn,
                              icon: Icons.add_circle_outline_rounded,
                              loading: submitting,
                              onPressed: submitting
                                  ? null
                                  : () async {
                                      final amount = double.tryParse(
                                            normalizeDigits(amountCtrl.text.trim()),
                                          ) ??
                                          0;
                                      final reason = reasonCtrl.text.trim();
                                      if (amount <= 0 || reason.isEmpty) {
                                        setModalState(
                                          () => localError = s.errEmergencyInput,
                                        );
                                        return;
                                      }
                                      if (selectedApts.isEmpty) {
                                        setModalState(
                                          () => localError = s.errSelectAtLeastOneApt,
                                        );
                                        return;
                                      }
                                      setModalState(() {
                                        submitting = true;
                                        localError = null;
                                      });
                                      final ok = await cubit.addExtraCharges(
                                        aptNums: selectedApts.toList()..sort(),
                                        amount: amount,
                                        reason: reason,
                                      );
                                      if (!ctx.mounted) return;
                                      setModalState(() {
                                        submitting = false;
                                        if (ok) {
                                          amountCtrl.clear();
                                          reasonCtrl.clear();
                                          selectedApts.clear();
                                        }
                                      });
                                    },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Divider(height: 1, color: AppColors.border(isDark)),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    s.extraChargesListTitle,
                                    style: AppTypography.label.copyWith(
                                      color: AppColors.textPrimary(isDark),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (month.extraCharges.isNotEmpty)
                                  TextButton.icon(
                                    onPressed: () async {
                                      await showConfirmDeleteDialog(
                                        context: ctx,
                                        s: s,
                                        isDark: isDark,
                                        message: s.confirmDeleteAllExtraBody,
                                        onConfirm: cubit.deleteAllExtraCharges,
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
                            const SizedBox(height: AppSpacing.sm),
                            if (month.extraCharges.isEmpty)
                              Text(
                                s.noExtraChargesYet,
                                textAlign: TextAlign.center,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary(isDark),
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
                                              context: ctx,
                                              s: s,
                                              isDark: isDark,
                                              message: s.confirmDeleteExtraBody(
                                                s.currency(item.amount.toInt()),
                                              ),
                                              onConfirm: () => cubit.deleteExtraCharge(item.id),
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
                    ),
                  ],
                ),
              ),
              ),
            ),
          );
        },
      ),
    ),
  );

  Future.delayed(const Duration(milliseconds: 350), () {
    amountCtrl.dispose();
    reasonCtrl.dispose();
  });
}
