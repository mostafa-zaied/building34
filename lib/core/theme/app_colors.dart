import 'package:flutter/material.dart';

/// Centralized color tokens for Amaraty's Light and Dark themes.
abstract final class AppColors {
  // Brand & Accents
  static const Color primary = Color(0xFF5B5BD6);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4338CA);

  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldDarkText = Color(0xFF059669);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberDarkText = Color(0xFFB45309);
  static const Color danger = Color(0xFFEF4444);

  // Category Accents
  static const Color water = Color(0xFF0EA5E9);
  static const Color electricity = Color(0xFFEAB308);
  static const Color elevator = Color(0xFF8B5CF6);
  static const Color cleaning = Color(0xFFEC4899);
  static const Color reserve = Color(0xFF10B981);

  // Dark Theme Surfaces
  static const Color darkBg = Color(0xFF080C14);
  static const Color darkSurface = Color(0xFF101724);
  static const Color darkCard = Color(0xFF151E2E);
  static const Color darkBorder = Color(0x14FFFFFF); // 8% white
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Light Theme Surfaces
  static const Color lightBg = Color(0xFFF4F6FA);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  static Color bg(bool isDark) => isDark ? darkBg : lightBg;
  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color card(bool isDark) => isDark ? darkCard : lightCard;
  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color textPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color emeraldText(bool isDark) => isDark ? emerald : emeraldDarkText;
  static Color primaryText(bool isDark) => isDark ? primaryLight : primaryDark;
}
