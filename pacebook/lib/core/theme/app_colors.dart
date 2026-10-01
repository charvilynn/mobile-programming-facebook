import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Synced with the active ThemeMode from themeModeProvider
  static bool isDark = true;

  // === BACKGROUND HIERARCHY ===
  static Color get bgDeep    => isDark ? const Color(0xFF0B0B10) : const Color(0xFFF1F5F9);
  static Color get bgSurface => isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFFFFF);
  static Color get bgCard    => isDark ? const Color(0xFF16213E) : const Color(0xFFFFFFFF);
  static Color get bgMuted   => isDark ? const Color(0xFF1E1E3A) : const Color(0xFFF8FAFC);

  // === TEXT HIERARCHY ===
  static Color get textPrimary   => isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  static Color get textSecondary => isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  static Color get textMuted     => isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8);

  // === BRAND ACCENTS ===
  static Color get cyan      => isDark ? const Color(0xFF22D3EE) : const Color(0xFF0284C7);
  static Color get cyanGlow  => isDark ? const Color(0x3322D3EE) : const Color(0x1F0284C7);
  static Color get cyanLight => isDark ? const Color(0xFF67E8F9) : const Color(0xFF38BDF8);

  static const Color magenta      = Color(0xFFE879F9);
  static const Color magentaGlow  = Color(0x33E879F9);
  static const Color electricBlue = Color(0xFF3B82F6);
  static Color get starWhite      => isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

  // === SEMANTIC COLORS ===
  static const Color success = Color(0xFF10B981);
  static const Color error   = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // === BORDERS ===
  static Color get border       => isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
  static Color get borderSubtle  => isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
  static Color get borderFocus   => isDark ? const Color(0xFF22D3EE) : const Color(0xFF0284C7);
}