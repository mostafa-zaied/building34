import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';

class CopyrightFooter extends StatelessWidget {
  final bool isDark;

  const CopyrightFooter({super.key, required this.isDark});

  Future<void> _shareReferral(String message) async {
    try {
      final uri = Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(message)}',
      );
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final s = AppLocalizations.of(context);
    if (s == null) return const SizedBox.shrink();
    final highlightColor = AppColors.primaryText(isDark);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Center(
        child: TextButton.icon(
          onPressed: () => _shareReferral(s.referralShareMessage),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 6,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          icon: Icon(
            Icons.rocket_launch_outlined,
            size: 14,
            color: highlightColor,
          ),
          label: Text(
            s.footerGetAppCta,
            style: AppTypography.caption.copyWith(
              color: highlightColor,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: highlightColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
