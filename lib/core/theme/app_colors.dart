import 'package:flutter/material.dart';

/// Centralized Royal Blue & Ice color tokens for Amaraty.
abstract final class AppColors {
  // Brand Primary — Royal Blue
  static const Color primary = Color(0xFF2457C5);
  static const Color primaryLight = Color(0xFF477BE8);
  static const Color primaryDark = Color(0xFF1A4199);

  // Compatibility Brand Aliases
  static const Color coral = primary;
  static const Color sage = primaryLight;

  // Semantic Financial & Status Colors
  static const Color success = Color(0xFF21865B);
  static const Color successLight = Color(0xFF3DA879);
  static const Color successDarkText = Color(0xFF1B6E4B);

  static const Color emerald = success;
  static const Color emeraldLight = successLight;
  static const Color emeraldDarkText = successDarkText;

  static const Color amber = Color(0xFFD99525);
  static const Color amberDarkText = Color(0xFFB07414);

  static const Color danger = Color(0xFFD94B55);
  static const Color dangerDarkText = Color(0xFFB8353F);

  static const Color info = primary;
  static const Color disabled = Color(0xFFD6DFEE);

  // Expense Category Accents
  static const Color water = primaryLight;
  static const Color electricity = amber;
  static const Color elevator = Color(0xFF64748B);
  static const Color cleaning = success;
  static const Color reserve = primary;

  // Light Theme Surfaces (Royal Blue & Ice — Default)
  static const Color lightBg = Color(0xFFF5F8FF);
  static const Color lightBgTop = Color(0xFFF5F8FF);
  static const Color lightSurface = Color(0xFFEAF1FF); // Ice Surface
  static const Color lightCard = Color(0xFFFFFFFF); // White Card
  static const Color lightCardElevated = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E9F5);
  static const Color lightTextPrimary = Color(0xFF202D46);
  static const Color lightTextSecondary = Color(0xFF77839A);

  // Dark Theme Companion Surfaces
  static const Color darkBg = Color(0xFF0F1626);
  static const Color darkBgTop = Color(0xFF141D31);
  static const Color darkSurface = Color(0xFF182238);
  static const Color darkCard = Color(0xFF1D2942);
  static const Color darkCardElevated = Color(0xFF243250);
  static const Color darkBorder = Color(0xFF2D3D5E);
  static const Color darkTextPrimary = Color(0xFFF5F8FF);
  static const Color darkTextSecondary = Color(0xFF9BA8C2);

  // Adaptive Surface & Typography Helpers
  static Color bg(bool isDark) => isDark ? darkBg : lightBg;
  static Color bgTop(bool isDark) => isDark ? darkBgTop : lightBgTop;
  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color card(bool isDark) => isDark ? darkCard : lightCard;
  static Color cardElevated(bool isDark) => isDark ? darkCardElevated : lightCardElevated;
  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color textPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;

  // Semantic Financial Status Helpers
  static Color emeraldText(bool isDark) => isDark ? successLight : successDarkText;
  static Color primaryText(bool isDark) => isDark ? primaryLight : primary;
  static Color dangerText(bool isDark) => isDark ? danger : dangerDarkText;
  static Color warningText(bool isDark) => isDark ? amber : amberDarkText;

  static Color onPrimaryAction(bool isDark) => Colors.white;
  static Color primaryActionBg(bool isDark) => isDark ? primaryLight : primary;
}
