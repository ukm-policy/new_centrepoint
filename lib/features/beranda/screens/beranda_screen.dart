import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/floating_app_bar.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final _pageCtrl = PageController();
  int _bannerIndex = 0;

  final _banners = const [
    _BannerData(
      tag: 'PENGUMUMAN',
      title: 'Panduan Kebijakan Baru Dirilis untuk Q3',
    ),
    _BannerData(
      tag: 'KEGIATAN',
      title: 'Rapat Tinjauan Kebijakan Tahunan Dijadwalkan',
    ),
  ];

  final _quickMenu = const [
    _QuickMenuData(icon: Icons.groups, label: 'All Members', route: '/anggota', isPush: true),
    _QuickMenuData(icon: Icons.event_note, label: 'Kegiatan', route: '/kegiatan'),
    _QuickMenuData(icon: Icons.account_balance_wallet, label: 'Uang Khas', route: '/uang-khas', isPush: true),
    _QuickMenuData(icon: Icons.qr_code_scanner, label: 'Absensi', route: '/absensi', isPush: true),
    _QuickMenuData(icon: Icons.newspaper, label: 'Berita', route: '/berita'),
    _QuickMenuData(icon: Icons.workspace_premium, label: 'Poin', route: '/poin', isPush: true),
  ];

  final _newsList = const [
    _NewsData(
      date: '24 Okt 2023',
      title: 'Rapat Tinjauan Kebijakan Tahunan Dijadwalkan',
      id: '1',
    ),
    _NewsData(
      date: '20 Okt 2023',
      title: 'Alokasi Anggaran untuk Tahun Fiskal Berikutnya',
      id: '2',
    ),
    _NewsData(
      date: '15 Okt 2023',
      title: 'Update Peraturan Keanggotaan 2023',
      id: '3',
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FloatingAppBar(
          ),
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
              // Banner carousel
              _BannerCarousel(
                banners: _banners,
                controller: _pageCtrl,
                currentIndex: _bannerIndex,
                onPageChanged: (i) => setState(() => _bannerIndex = i),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // User card
              const _UserCard(),
              const SizedBox(height: AppSpacing.stackGap),

              // Quick access
              _QuickAccessGrid(items: _quickMenu),
              const SizedBox(height: AppSpacing.stackGap),

              // Berita terbaru
              _SectionHeader(
                title: 'Berita Terbaru',
                onViewAll: () => context.go('/berita'),
              ),
              const SizedBox(height: 12),
              _HorizontalNewsList(news: _newsList),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Banner Carousel ──────────────────────────────────────────────────────────

class _BannerData {
  const _BannerData({required this.tag, required this.title});
  final String tag;
  final String title;
}

class _BannerCarousel extends StatelessWidget {
  const _BannerCarousel({
    required this.banners,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final List<_BannerData> banners;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      child: SizedBox(
        height: 180,
        child: Stack(
          children: [
            PageView.builder(
              controller: controller,
              onPageChanged: onPageChanged,
              itemCount: banners.length,
              itemBuilder: (_, i) => _BannerItem(data: banners[i]),
            ),
            Positioned(
              bottom: 10,
              right: 12,
              child: Row(
                children: List.generate(
                  banners.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: currentIndex == i ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentIndex == i
                          ? AppColors.primaryContainer
                          : AppColors.surfaceContainerLowest.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.blackCharcoal, width: 1),
                    ),
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

class _BannerItem extends StatelessWidget {
  const _BannerItem({required this.data});
  final _BannerData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.blackCharcoal,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryContainer, AppColors.blackCharcoal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: AppColors.blackCharcoal, width: 1),
                  ),
                  child: Text(
                    data.tag,
                    style: AppTypography.labelBold.copyWith(color: AppColors.onPrimaryContainer),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.title,
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.surfaceContainerLowest,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── User Card ────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  const _UserCard();

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      onTap: () => context.push('/poin'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.blackCharcoal, width: 2),
              boxShadow: const [AppColors.hardShadowSm],
            ),
            child: const Icon(Icons.person, size: 28, color: AppColors.tertiary),
          ),
          const SizedBox(width: 12),
          // Name & role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ahmad Ridhwan',
                  style: AppTypography.headlineSm.copyWith(
                    color: AppColors.blackCharcoal,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Senior Policy Analyst',
                  style: AppTypography.labelBold.copyWith(color: AppColors.tertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Divider + stats
          Container(
            margin: const EdgeInsets.only(left: 12),
            padding: const EdgeInsets.only(left: 12),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.blackCharcoal, width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                    border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                    boxShadow: const [AppColors.hardShadowSm],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 12, color: AppColors.onSecondaryContainer),
                      const SizedBox(width: 4),
                      Text(
                        'Gold',
                        style: AppTypography.labelBold.copyWith(
                          color: AppColors.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '1250 Pts',
                      style: AppTypography.bodyLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Access Grid ────────────────────────────────────────────────────────

class _QuickMenuData {
  const _QuickMenuData({
    required this.icon,
    required this.label,
    required this.route,
    this.isPush = false,
  });
  final IconData icon;
  final String label;
  final String route;
  final bool isPush;
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({required this.items});
  final List<_QuickMenuData> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.gutterGrid,
        mainAxisSpacing: AppSpacing.gutterGrid,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _QuickMenuCell(data: items[i]),
    );
  }
}

class _QuickMenuCell extends StatelessWidget {
  const _QuickMenuCell({required this.data});
  final _QuickMenuData data;

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      onTap: () => data.isPush ? context.push(data.route) : context.go(data.route),
      padding: const EdgeInsets.all(AppSpacing.innerPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.blackCharcoal, width: 1),
            ),
            child: Icon(data.icon, size: 22, color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            data.label,
            textAlign: TextAlign.center,
            style: AppTypography.labelBold,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── News List ────────────────────────────────────────────────────────────────

class _NewsData {
  const _NewsData({required this.date, required this.title, required this.id});
  final String date;
  final String title;
  final String id;
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onViewAll});
  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.primary, width: 4)),
          ),
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(title, style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w800)),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'Lihat Semua',
              style: AppTypography.labelBold.copyWith(
                color: AppColors.tertiary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }
}

class _HorizontalNewsList extends StatelessWidget {
  const _HorizontalNewsList({required this.news});
  final List<_NewsData> news;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: news.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.gutterGrid + 4),
        itemBuilder: (_, i) => _NewsCard(data: news[i]),
      ),
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.data});
  final _NewsData data;

  @override
  Widget build(BuildContext context) {
    return BrutalistCard(
      onTap: () => context.push('/berita/${data.id}'),
      child: SizedBox(
        width: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                border: Border(
                  bottom: BorderSide(color: AppColors.blackCharcoal, width: 2),
                ),
              ),
              child: const Center(
                child: Icon(Icons.newspaper, size: 40, color: AppColors.tertiary),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.innerPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.date,
                      style: AppTypography.labelBold.copyWith(color: AppColors.tertiary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.title,
                      style: AppTypography.headlineSm,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'Baca Selengkapnya',
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
