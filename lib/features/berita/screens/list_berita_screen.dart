import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/repositories/berita_repository.dart';

class ListBeritaScreen extends StatefulWidget {
  const ListBeritaScreen({super.key});

  @override
  State<ListBeritaScreen> createState() => _ListBeritaScreenState();
}

class _ListBeritaScreenState extends State<ListBeritaScreen> {
  String _filter = 'Semua';
  String _search = '';

  String _fmtDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final allBerita = context.watch<BeritaRepository>().publishedBerita;
    final filtered = allBerita.where((b) {
      final matchCat = _filter == 'Semua' || b.kategori == _filter;
      final matchSearch = _search.isEmpty ||
          b.judul.toLowerCase().contains(_search.toLowerCase());
      return matchCat && matchSearch;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FloatingAppBar(title: 'Berita & Pengumuman', showBack: true),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginPage,
            AppSpacing.stackGap,
            AppSpacing.marginPage,
            AppSpacing.stackGap,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.blackCharcoal, width: 2),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: AppTypography.bodyMd,
                  decoration: const InputDecoration(
                    hintText: 'Cari berita...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Semua', 'Berita', 'Pengumuman'].map((f) {
                    final active = _filter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primaryContainer
                              : AppColors.surfaceContainerLowest,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusNav),
                          border: Border.all(
                              color: AppColors.blackCharcoal, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blackCharcoal,
                              offset: active
                                  ? const Offset(2, 2)
                                  : const Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          f,
                          style: AppTypography.labelBold.copyWith(
                            color: active
                                ? AppColors.onPrimaryContainer
                                : AppColors.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // List
              ...filtered.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
                    child: BrutalistCard(
                      onTap: () => context.push('/berita/${b.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 100,
                            color: AppColors.surfaceContainerHigh,
                            child: const Center(
                              child: Icon(Icons.newspaper,
                                  size: 40, color: AppColors.tertiary),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _CategoryBadge(label: b.kategori),
                                    const Spacer(),
                                    Text(
                                      _fmtDate(b.tanggalPublish),
                                      style: AppTypography.labelBold.copyWith(
                                          color: AppColors.tertiary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(b.judul, style: AppTypography.headlineSm),
                                const SizedBox(height: 8),
                                const MyDivider(color: AppColors.borderSlate, height: 12),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Baca Selengkapnya',
                                      style: AppTypography.labelBold
                                          .copyWith(color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward,
                                        size: 14,
                                        color: AppColors.primary),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ]),
          ),
        ),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.blackCharcoal, width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.labelBold
            .copyWith(color: AppColors.onPrimaryContainer),
      ),
    );
  }
}
