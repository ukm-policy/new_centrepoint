import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'floating_app_bar.dart';

/// Layar pengganti untuk halaman detail saat datanya belum dimuat
/// ([loading] = true) atau ID-nya tidak ditemukan.
class MissingDataScreen extends StatelessWidget {
  const MissingDataScreen({
    super.key,
    required this.title,
    required this.loading,
    this.message = 'Data tidak ditemukan atau sudah dihapus.',
  });

  final String title;
  final bool loading;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: Column(
          children: [
            FloatingAppBar(
              title: title,
              showBack: true,
              trailing: const SizedBox(width: 40),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.marginPage),
                  child: loading
                      ? const CircularProgressIndicator(
                          color: AppColors.blackCharcoal,
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 48,
                              color: AppColors.tertiary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.tertiary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
