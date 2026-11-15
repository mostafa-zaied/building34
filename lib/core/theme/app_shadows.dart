import 'package:flutter/material.dart';

/// Refined elevation and subtle accent glow shadows.
abstract final class AppShadows {
  static List<BoxShadow> card(bool isDark) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.04),
          blurRadius: isDark ? 18 : 14,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> accentGlow(Color color, {required bool active, required bool isDark}) => [
        BoxShadow(
          color: color.withValues(alpha: active ? (isDark ? 0.35 : 0.24) : (isDark ? 0.12 : 0.08)),
          blurRadius: active ? 16 : 8,
          offset: const Offset(0, 3),
        ),
      ];
}
