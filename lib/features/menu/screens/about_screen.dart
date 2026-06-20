import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/my_divider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginPage,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                      border: Border.all(color: AppColors.blackCharcoal, width: 2),
                      boxShadow: const [AppColors.hardShadowSm],
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.arrow_back, size: 16, color: AppColors.onSurface),
                      const SizedBox(width: 6),
                      Text('Kembali', style: AppTypography.labelBold),
                    ]),
                  ),
                ),
                Text(
                  'Tentang',
                  style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginPage),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              BrutalistCard(
                padding: const EdgeInsets.all(24),
                backgroundColor: AppColors.surfaceContainerLowest,
                child: Column(
                  children: [
                    // App Logo Placeholder
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(color: AppColors.blackCharcoal, width: 2.5),
                        boxShadow: const [AppColors.hardShadow],
                      ),
                      child: const Icon(
                        Icons.policy_outlined,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'POLICY CENTREPOINT',
                      style: AppTypography.displayLgMobile.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Versi 1.0.0 (Production-Build)',
                      style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                    ),
                    const SizedBox(height: 16),
                    const MyDivider(color: AppColors.borderSlate),
                    const SizedBox(height: 16),
                    Text(
                      'Aplikasi pusat informasi dan administrasi internal Unit Kegiatan Mahasiswa (UKM) POLICY. Membantu koordinasi antar pengurus, anggota, rapat, kegiatan, serta transparansi keuangan kas organisasi.',
                      style: AppTypography.bodyMd,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('INFORMASI DEVELOVER', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, letterSpacing: 0.5)),
              const SizedBox(height: 8),

              BrutalistCard(
                padding: const EdgeInsets.all(16),
                backgroundColor: AppColors.surfaceContainerLowest,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: 'Dikembangkan oleh', value: 'Bidang R&D UKM POLICY'),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Tahun Rilis', value: '2026'),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Lisensi', value: 'MIT License'),
                    const SizedBox(height: 8),
                    _InfoRow(label: 'Repository', value: 'github.com/policy/centrepoint'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.tertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
