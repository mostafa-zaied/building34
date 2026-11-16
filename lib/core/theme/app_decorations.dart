import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_shadows.dart';
import 'app_spacing.dart';

/// Centralized BoxDecorations for Royal Blue & Ice surfaces.
abstract final class AppDecorations {
  static BoxDecoration screenBackground(bool isDark) => BoxDecoration(
        color: AppColors.bg(isDark),
      );

  static BoxDecoration card(bool isDark, {Color? borderColor}) => BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor ?? AppColors.border(isDark)),
        boxShadow: AppShadows.card(isDark),
      );

  static BoxDecoration heroCard(bool isDark, {bool highlighted = false}) => BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: highlighted ? AppColors.primaryText(isDark) : AppColors.border(isDark),
          width: highlighted ? 1.5 : 1.0,
        ),
        boxShadow: AppShadows.heroCard(isDark),
      );

  static BoxDecoration emergencyHeroCard(bool isDark) => BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primaryText(isDark).withValues(alpha: isDark ? 0.35 : 0.22),
        ),
        boxShadow: AppShadows.heroCard(isDark),
      );
}
