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
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
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
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(s.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            confirmLabel ?? s.confirmDeleteBtn,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
  return confirmed == true;
}
