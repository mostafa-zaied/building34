import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../cubit/building_cubit.dart';
import '../../cubit/building_state.dart';
import '../../models/building_models.dart';
import '../common/app_button.dart';
import 'confirm_delete_dialog.dart';

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
                      final ok = await showConfirmDeleteDialog(
                        context: ctx,
                        s: s,
                        isDark: isDark,
                        message: s.confirmCancelPaymentBody(state.aptLabel(aptNum)),
                      );
                      if (!ok) return;
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

  final hasSavedPass = state.myAptNum == aptNum &&
      state.savedAptPass != null &&
      state.savedAptPass!.isNotEmpty;
  final passCtrl = TextEditingController(
    text: hasSavedPass ? state.savedAptPass! : '',
  );
  bool useSavedPass = hasSavedPass;
  Uint8List? pickedBytes;
  String? pickedName;
  String? errMsg;
  bool submitting = false;
  const instaPayPhone = '01021950445';

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
                            s.currency(month.dueFor(aptNum)),
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
                if (month.extraChargesFor(aptNum).isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface(isDark),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.amber.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              s.monthShareLine,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary(isDark),
                              ),
                            ),
                            Text(
                              s.currency(month.sharePerApt),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textPrimary(isDark),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        ...month.extraChargesFor(aptNum).map(
                          (e) => Padding(
                            padding: const EdgeInsetsDirectional.only(top: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '+ ${e.reason}',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.warningText(isDark),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '+${s.currency(e.amount.toInt())}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.warningText(isDark),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.symmetric(vertical: 6),
                          child: Divider(height: 1, color: AppColors.border(isDark)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              s.totalDueLabel,
                              style: AppTypography.label.copyWith(
                                color: AppColors.textPrimary(isDark),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              s.currency(month.dueFor(aptNum)),
                              style: AppTypography.title.copyWith(
                                color: AppColors.primaryText(isDark),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Divider(height: 1, color: AppColors.border(isDark)),
                const SizedBox(height: AppSpacing.md),

                // InstaPay Transfer Card
                Container(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface(isDark),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.primaryText(isDark).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 16,
                            color: AppColors.primaryText(isDark),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              s.instapayTitle,
                              style: AppTypography.label.copyWith(
                                color: AppColors.primaryText(isDark),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: SelectableText(
                              instaPayPhone,
                              style: AppTypography.title.copyWith(
                                color: AppColors.textPrimary(isDark),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.instapaySubtitle,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary(isDark),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final instaPayUri = Uri.parse(
                            'https://ipn.eg/S/mostafazaied/instapay/6nvhpw',
                          );
                          try {
                            await launchUrl(
                              instaPayUri,
                              mode: LaunchMode.externalApplication,
                            );
                          } catch (_) {}
                        },
                        icon: const Icon(Icons.open_in_new_rounded, size: 15),
                        label: Text(
                          s.openInstapayBtn,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.onPrimaryAction(isDark),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryActionBg(isDark),
                          foregroundColor: AppColors.onPrimaryAction(isDark),
                          padding: const EdgeInsetsDirectional.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Step 1: Passcode (auto-remembered after first payment)
                if (useSavedPass)
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: isDark ? 0.14 : 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: AppColors.emerald.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 18,
                          color: AppColors.emeraldText(isDark),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            s.savedPassBadge,
                            style: AppTypography.label.copyWith(
                              color: AppColors.emeraldText(isDark),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              useSavedPass = false;
                              passCtrl.clear();
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(s.changePassBtn, style: AppTypography.caption),
                        ),
                      ],
                    ),
                  )
                else ...[
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
                ],
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
