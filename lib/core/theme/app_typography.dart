import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get displayLg => GoogleFonts.bricolageGrotesque(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 40 / 32,
        letterSpacing: -0.02 * 32,
        color: AppColors.onSurface,
      );

  static TextStyle get displayLgMobile => GoogleFonts.bricolageGrotesque(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 36 / 28,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineMd => GoogleFonts.bricolageGrotesque(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 32 / 24,
        letterSpacing: -0.01 * 24,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineSm => GoogleFonts.bricolageGrotesque(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 28 / 20,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyLg => GoogleFonts.bricolageGrotesque(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMd => GoogleFonts.bricolageGrotesque(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.onSurface,
      );

  static TextStyle get labelBold => GoogleFonts.bricolageGrotesque(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 16 / 12,
        color: AppColors.onSurface,
      );
}
