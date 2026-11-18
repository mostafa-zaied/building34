import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';

Future<bool> showConfirmDeleteDialog({
  required BuildContext context,
  required AppLocalizations s,
  required bool isDark,
  required String message,
  String? title,
  String? confirmLabel,
  Future<void> Function()? onConfirm,
}) async {
  bool deleting = false;
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => PopScope(
        canPop: !deleting,
        child: AlertDialog(
          backgroundColor: AppColors.card(isDark),
          title: Text(
            title ?? s.confirmDeleteTitle,
            style: AppTypography.headline.copyWith(fontSize: 15),
          ),
          content: Text(
            message,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary(isDark)),
          ),
          actions: [
            TextButton(
              onPressed: deleting ? null : () => Navigator.pop(ctx, false),
              child: Text(s.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: deleting
                  ? null
                  : () async {
                      if (onConfirm == null) {
                        Navigator.pop(ctx, true);
                        return;
                      }
                      setModalState(() => deleting = true);
                      try {
                        await onConfirm();
                      } finally {
                        if (ctx.mounted) Navigator.pop(ctx, true);
                      }
                    },
              child: deleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      confirmLabel ?? s.confirmDeleteBtn,
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    ),
  );
  return confirmed == true;
}
