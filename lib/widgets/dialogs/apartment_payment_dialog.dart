import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../common/app_button.dart';

Future<void> showApartmentPaymentDialog({
  required BuildContext context,
  required BuildingCubit cubit,
  required BuildingState state,
  required MonthBill month,
  required int aptNum,
  required ImagePicker picker,
}) async {
  final s = state.s;
  final isDark = state.isDarkMode;

  final existing = month.payments[aptNum];
  if (existing != null) {
    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
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
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        Icons.verified_rounded,
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
                            state.aptLabel(aptNum),
                            style: AppTypography.headline.copyWith(
                              fontSize: 16,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                          Text(
                            s.paidBadge,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.emeraldText(isDark),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(Icons.close_rounded, color: AppColors.textSecondary(isDark)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Divider(height: 1, color: AppColors.border(isDark)),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface(isDark),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border(isDark)),
                  ),
                  child: Column(
                    children: [
                      if (existing.localBytes != null) ...[
                        Text(
                          s.fileLabel(existing.fileName),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Image.memory(
                            existing.localBytes!,
                            height: 210,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ] else if (existing.receiptUrl != null && existing.receiptUrl!.isNotEmpty) ...[
                        Text(
                          s.fileLabel(existing.fileName),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Image.network(
                            existing.receiptUrl!,
                            height: 210,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ] else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: AppColors.emeraldText(isDark),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Flexible(
                              child: Text(
                                s.noReceiptAttached,
                                style: AppTypography.label.copyWith(
                                  color: AppColors.emeraldText(isDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (state.isAdminOpen) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppSecondaryButton(
                    label: s.cancelPaymentAdmin,
                    accentColor: AppColors.danger,
                    onPressed: () async {
                      await cubit.cancelPayment(aptNum);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    return;
  }

  final passCtrl = TextEditingController();
  bool confirmed = true;
  Uint8List? pickedBytes;
  String? pickedName;
  String? errMsg;
  bool submitting = false;

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
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
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 440,
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.86,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: Icon + Apt Name + Amount pill + Close
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.payments_rounded,
                        size: 19,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.aptLabel(aptNum),
                            style: AppTypography.headline.copyWith(
                              fontSize: 16,
                              color: AppColors.textPrimary(isDark),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.currency(month.sharePerApt),
                            style: AppTypography.statAmount.copyWith(
                              fontSize: 14,
                              color: AppColors.primaryText(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Divider(height: 1, color: AppColors.border(isDark)),
                const SizedBox(height: AppSpacing.md),

                // Step 1: Passcode
                Text(
                  s.step1Passcode(!AppConfig.isSupabaseConfigured ? ' (${1000 + aptNum})' : ''),
                  style: AppTypography.label.copyWith(
                    color: AppColors.textPrimary(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary(isDark),
                  ),
                  decoration: InputDecoration(
                    hintText: s.enterPassHint,
                    filled: true,
                    fillColor: AppColors.surface(isDark),
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: AppColors.textSecondary(isDark),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Confirmation Checkbox Card
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () {
                    setModalState(() {
                      confirmed = !confirmed;
                      if (confirmed) errMsg = null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: confirmed
                          ? AppColors.emerald.withValues(alpha: isDark ? 0.12 : 0.08)
                          : AppColors.surface(isDark),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: confirmed
                            ? AppColors.emerald.withValues(alpha: 0.45)
                            : AppColors.border(isDark),
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: confirmed,
                          activeColor: AppColors.emerald,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          onChanged: (v) {
                            setModalState(() {
                              confirmed = v ?? false;
                              if (confirmed) errMsg = null;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            s.confirmPaidCheckbox,
                            style: AppTypography.label.copyWith(
                              color: AppColors.textPrimary(isDark),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Step 2: Optional receipt image
                Text(
                  s.step2Image,
                  style: AppTypography.label.copyWith(
                    color: AppColors.textSecondary(isDark),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  onTap: () async {
                    final XFile? file = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (file != null) {
                      final bytes = await file.readAsBytes();
                      setModalState(() {
                        pickedBytes = bytes;
                        pickedName = file.name;
                        errMsg = null;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface(isDark),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: pickedBytes != null
                            ? AppColors.emerald.withValues(alpha: 0.65)
                            : AppColors.border(isDark),
                      ),
                    ),
                    child: pickedBytes == null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 19,
                                color: AppColors.primaryText(isDark),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Flexible(
                                child: Text(
                                  s.pickImagePrompt.replaceAll('📸', '').trim(),
                                  textAlign: TextAlign.center,
                                  style: AppTypography.label.copyWith(
                                    color: AppColors.textSecondary(isDark),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Text(
                                s.chosenFile(pickedName ?? ''),
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.emeraldText(isDark),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                child: Image.memory(
                                  pickedBytes!,
                                  height: 110,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                if (errMsg != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      errMsg!,
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),

                // Action Row: Cancel + Confirm Payment
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: submitting ? null : () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: Text(
                          s.cancel,
                          style: AppTypography.label.copyWith(
                            color: AppColors.textSecondary(isDark),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: AppPrimaryButton(
                        label: submitting
                            ? s.uploadingBtn
                            : s.confirmPaymentBtn.replaceAll('✅', '').trim(),
                        icon: Icons.check_rounded,
                        loading: submitting,
                        onPressed: submitting
                            ? null
                            : () async {
                                if (!confirmed) {
                                  setModalState(() => errMsg = s.errConfirmCheckbox);
                                  return;
                                }
                                setModalState(() => submitting = true);
                                final resErr = await cubit.submitPayment(
                                  aptNum: aptNum,
                                  passcode: passCtrl.text,
                                  imageBytes: pickedBytes,
                                  fileName: pickedName,
                                );
                                if (resErr != null) {
                                  setModalState(() {
                                    submitting = false;
                                    errMsg = resErr;
                                  });
                                  return;
                                }
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  Future.delayed(const Duration(milliseconds: 350), passCtrl.dispose);
}
