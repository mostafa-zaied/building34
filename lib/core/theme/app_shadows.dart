import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Refined elevation and subtle accent glow shadows.
abstract final class AppShadows {
  static List<BoxShadow> card(bool isDark) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.05),
          blurRadius: isDark ? 24 : 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> heroCard(bool isDark) => [
        BoxShadow(
          color: (isDark ? Colors.black : AppColors.primary).withValues(alpha: isDark ? 0.45 : 0.08),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
      ];

  static List<BoxShadow> floatingNav(bool isDark) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.50 : 0.10),
          blurRadius: 28,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> accentGlow(Color color, {required bool active, required bool isDark}) => [
        BoxShadow(
          color: color.withValues(alpha: active ? (isDark ? 0.30 : 0.20) : (isDark ? 0.10 : 0.06)),
          blurRadius: active ? 18 : 10,
          offset: const Offset(0, 4),
        ),
      ];
}
