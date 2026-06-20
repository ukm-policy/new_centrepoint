import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/my_divider.dart';
import '../berita_data.dart';

class DetailBeritaScreen extends StatefulWidget {
  const DetailBeritaScreen({super.key, required this.id});
  final String id;

  @override
  State<DetailBeritaScreen> createState() => _DetailBeritaScreenState();
}

class _DetailBeritaScreenState extends State<DetailBeritaScreen> {
  bool _isBookmarked = false;

  void _shareBerita(BeritaItem berita) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tautan berita "${berita.title}" telah disalin ke clipboard!',
            style: AppTypography.bodyMd.copyWith(color: Colors.white)),
        backgroundColor: AppColors.blackCharcoal,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked ? 'Berita disimpan ke bookmark!' : 'Berita dihapus dari bookmark.',
          style: AppTypography.bodyMd.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.blackCharcoal,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final berita = kBeritaList.firstWhere(
      (b) => b.id == widget.id,
      orElse: () => kBeritaList.first,
    );

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
                      _Badge(label: berita.category.toUpperCase()),
                      const Spacer(),
                      Text(
                        berita.date,
                        style: AppTypography.labelBold
                            .copyWith(color: AppColors.tertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    berita.title,
                    style: AppTypography.headlineMd.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const MyDivider(color: AppColors.borderSlate),
                  const SizedBox(height: 16),
                  Text(
                    berita.content,
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
                        onTap: () => _shareBerita(berita),
                      ),
                      const SizedBox(width: 12),
                      _ActionChip(
                        icon: _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        label: _isBookmarked ? 'Tersimpan' : 'Simpan',
                        onTap: _toggleBookmark,
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
