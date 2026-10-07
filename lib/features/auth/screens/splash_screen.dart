import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Ditampilkan sebentar selama sesi & profil user dimuat.
/// Navigasi keluar dari layar ini ditangani oleh redirect router.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo_ukmpolicy.png', width: 96, height: 96),
            const SizedBox(height: 16),
            Text(
              'CENTREPOINT',
              style: AppTypography.displayLgMobile.copyWith(
                color: AppColors.primary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.blackCharcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
