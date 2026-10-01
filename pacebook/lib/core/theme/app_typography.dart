import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  // === DISPLAY (Space Grotesk) ===
  static final TextStyle display1 = GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  ).copyWith(fontFamilyFallback: const ['Arial', 'sans-serif']);

  // === HEADINGS (Space Grotesk) ===
  static final TextStyle h1 = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  ).copyWith(fontFamilyFallback: const ['Arial', 'sans-serif']);

  static final TextStyle h2 = GoogleFonts.spaceGrotesk(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  ).copyWith(fontFamilyFallback: const ['Arial', 'sans-serif']);

  static final TextStyle h3 = GoogleFonts.spaceGrotesk(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  ).copyWith(fontFamilyFallback: const ['Arial', 'sans-serif']);

  // === BODY (Inter) ===
  static final TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  ).copyWith(fontFamilyFallback: const ['Arial', 'sans-serif']);

  static final TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  ).copyWith(fontFamilyFallback: const ['Arial', 'sans-serif']);

  static final TextStyle bodySm = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
  ).copyWith(fontFamilyFallback: const ['Arial', 'sans-serif']);

  // === UTILITY ===
  static final TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  ).copyWith(fontFamilyFallback: const ['Arial', 'sans-serif']);

  static final TextStyle label = GoogleFonts.spaceGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
  ).copyWith(fontFamilyFallback: const ['Arial', 'sans-serif']);

  // === LABEL VARIANTS ===
  static final TextStyle labelSm = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ).copyWith(fontFamilyFallback: const ['Arial', 'sans-serif']);

  static final TextStyle labelMd = GoogleFonts.spaceGrotesk(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  ).copyWith(fontFamilyFallback: const ['Arial', 'sans-serif']);

  static final TextStyle labelLg = GoogleFonts.spaceGrotesk(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  ).copyWith(fontFamilyFallback: const ['Arial', 'sans-serif']);

  static final TextStyle button = GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  ).copyWith(fontFamilyFallback: const ['Arial', 'sans-serif']);
}