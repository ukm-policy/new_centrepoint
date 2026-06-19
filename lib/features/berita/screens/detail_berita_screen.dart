import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/my_divider.dart';

class DetailBeritaScreen extends StatelessWidget {
  const DetailBeritaScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: _BackButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.surfaceContainerHigh,
                child: const Center(
                  child: Icon(Icons.newspaper, size: 64, color: AppColors.tertiary),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.marginPage),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.blackCharcoal, width: 2),
                boxShadow: const [AppColors.hardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Badge(label: 'BERITA'),
                      const Spacer(),
                      Text(
                        '24 Okt 2023',
                        style: AppTypography.labelBold
                            .copyWith(color: AppColors.tertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rapat Tinjauan Kebijakan Tahunan Dijadwalkan',
                    style: AppTypography.headlineMd.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const MyDivider(color: AppColors.borderSlate),
                  const SizedBox(height: 16),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                    'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                    'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris '
                    'nisi ut aliquip ex ea commodo consequat.\n\n'
                    'Duis aute irure dolor in reprehenderit in voluptate velit esse '
                    'cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat '
                    'cupidatat non proident, sunt in culpa qui officia deserunt mollit '
                    'anim id est laborum.\n\n'
                    'Sed ut perspiciatis unde omnis iste natus error sit voluptatem '
                    'accusantium doloremque laudantium, totam rem aperiam, eaque ipsa '
                    'quae ab illo inventore veritatis et quasi architecto beatae vitae '
                    'dicta sunt explicabo.',
                    style: AppTypography.bodyLg.copyWith(
                      color: AppColors.onSurface,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const MyDivider(color: AppColors.borderSlate),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _ActionChip(
                        icon: Icons.share,
                        label: 'Bagikan',
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _ActionChip(
                        icon: Icons.bookmark_border,
                        label: 'Simpan',
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: const [AppColors.hardShadowSm],
        ),
        child: const Icon(Icons.arrow_back, color: AppColors.onSurface, size: 20),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.blackCharcoal, width: 1),
      ),
      child: Text(
        label,
        style: AppTypography.labelBold.copyWith(color: AppColors.onPrimaryContainer),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: const [AppColors.hardShadowSm],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.onSurface),
            const SizedBox(width: 6),
            Text(label, style: AppTypography.labelBold),
          ],
        ),
      ),
    );
  }
}
