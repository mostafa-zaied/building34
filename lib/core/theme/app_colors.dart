import 'package:flutter/material.dart';

/// Centralized color tokens for Amaraty's Light and Dark themes.
abstract final class AppColors {
  // Brand & Accents
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color accentViolet = Color(0xFF8B5CF6);

  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color emeraldDarkText = Color(0xFF059669);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberDarkText = Color(0xFFB45309);
  static const Color danger = Color(0xFFEF4444);

  // Category Accents
  static const Color water = Color(0xFF38BDF8);
  static const Color electricity = Color(0xFFFACC15);
  static const Color elevator = Color(0xFFA78BFA);
  static const Color cleaning = Color(0xFFF472B6);
  static const Color reserve = Color(0xFF10B981);

  // Dark Theme Surfaces (Deep Midnight Navy)
  static const Color darkBg = Color(0xFF060913);
  static const Color darkSurface = Color(0xFF0C1220);
  static const Color darkCard = Color(0xFF121A2B);
  static const Color darkCardElevated = Color(0xFF172136);
  static const Color darkBorder = Color(0x12FFFFFF); // ~7% white hairline
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Light Theme Surfaces (Crisp Luxury Alabaster)
  static const Color lightBg = Color(0xFFF4F6FB);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardElevated = Color(0xFFF5F7FF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  static Color bg(bool isDark) => isDark ? darkBg : lightBg;
  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color card(bool isDark) => isDark ? darkCard : lightCard;
  static Color cardElevated(bool isDark) => isDark ? darkCardElevated : lightCardElevated;
  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color textPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color textSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color emeraldText(bool isDark) => isDark ? emeraldLight : emeraldDarkText;
  static Color primaryText(bool isDark) => isDark ? primaryLight : primaryDark;
}
