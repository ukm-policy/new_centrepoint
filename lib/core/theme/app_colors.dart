import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFB9172F);
  static const Color primaryContainer = Color(0xFFDC3545);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFFFFFF);

  static const Color secondary = Color(0xFF006D41);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF90F4B7);
  static const Color onSecondaryContainer = Color(0xFF007144);

  static const Color tertiary = Color(0xFF5E5D5D);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF777676);
  static const Color onTertiaryContainer = Color(0xFFFFFFFF);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color background = Color(0xFFF9F9F9);
  static const Color onBackground = Color(0xFF1A1C1C);
  static const Color bgGray = Color(0xFFEFECEC);

  static const Color surface = Color(0xFFF9F9F9);
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color surfaceVariant = Color(0xFFE2E2E2);
  static const Color onSurfaceVariant = Color(0xFF5B4040);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3F4);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E2);

  static const Color outline = Color(0xFF8F6F6F);
  static const Color outlineVariant = Color(0xFFE3BEBD);
  static const Color borderSlate = Color(0xFFE2E8F0);

  static const Color blackCharcoal = Color(0xFF222222);
  static const Color success = Color(0xFF198754);
  static const Color onSuccess = Color(0xFFFFFFFF);

  static const BoxShadow hardShadow = BoxShadow(
    color: blackCharcoal,
    offset: Offset(4, 4),
    blurRadius: 0,
  );

  static const BoxShadow hardShadowSm = BoxShadow(
    color: blackCharcoal,
    offset: Offset(2, 2),
    blurRadius: 0,
  );
}
