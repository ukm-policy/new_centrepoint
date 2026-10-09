import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Placeholder untuk daftar kosong: spinner saat [loading], atau pesan
/// "belum ada data" bila memang kosong.
class ListStatus extends StatelessWidget {
  const ListStatus({
    super.key,
    required this.loading,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final bool loading;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: loading
            ? const CircularProgressIndicator(color: AppColors.blackCharcoal)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 48, color: AppColors.tertiary),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                  ),
                ],
              ),
      ),
    );
  }
}
