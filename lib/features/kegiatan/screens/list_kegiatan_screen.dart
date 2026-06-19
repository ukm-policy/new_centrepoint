import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

const _kKegiatanList = [
  _KegiatanItem(
    id: '1', title: 'Seminar Kebijakan Publik 2023',
    date: '28 Okt 2023', location: 'Aula Utama Kampus',
    status: 'Upcoming', participants: 45,
  ),
  _KegiatanItem(
    id: '2', title: 'Workshop Penulisan Naskah Kebijakan',
    date: '15 Nov 2023', location: 'Ruang Rapat Lt. 3',
    status: 'Upcoming', participants: 20,
  ),
  _KegiatanItem(
    id: '3', title: 'Musyawarah Anggota Q3',
    date: '10 Okt 2023', location: 'Zoom Meeting',
    status: 'Selesai', participants: 38,
  ),
  _KegiatanItem(
    id: '4', title: 'Pelatihan Advokasi Kebijakan',
    date: '5 Okt 2023', location: 'Gedung B Lantai 2',
    status: 'Selesai', participants: 30,
  ),
];

const _kRiwayat = [
  _RiwayatItem(title: 'Pelatihan Advokasi Kebijakan', date: '5 Okt 2023', hadir: true),
  _RiwayatItem(title: 'Musyawarah Anggota Q3', date: '10 Okt 2023', hadir: true),
  _RiwayatItem(title: 'Workshop Penulisan Naskah Q2', date: '20 Agu 2023', hadir: false),
  _RiwayatItem(title: 'Seminar Hukum & Kebijakan', date: '15 Jul 2023', hadir: true),
  _RiwayatItem(title: 'Orientasi Anggota Baru 2023', date: '1 Jun 2023', hadir: true),
];

// ── Models ────────────────────────────────────────────────────────────────────

class _KegiatanItem {
  const _KegiatanItem({
    required this.id, required this.title, required this.date,
    required this.location, required this.status, required this.participants,
  });
  final String id, title, date, location, status;
  final int participants;
}

class _RiwayatItem {
  const _RiwayatItem({required this.title, required this.date, required this.hadir});
  final String title, date;
  final bool hadir;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ListKegiatanScreen extends StatefulWidget {
  const ListKegiatanScreen({super.key});

  @override
  State<ListKegiatanScreen> createState() => _ListKegiatanScreenState();
}

class _ListKegiatanScreenState extends State<ListKegiatanScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingAppBar(title: 'Kegiatan'),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
          child: _KegiatanTabBar(controller: _tabController),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _KegiatanTab(),
              _RiwayatTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tab Bar ───────────────────────────────────────────────────────────────────

class _KegiatanTabBar extends StatelessWidget {
  const _KegiatanTabBar({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
        boxShadow: const [AppColors.hardShadowSm],
      ),
      child: Row(
        children: ['Kegiatan', 'Riwayat'].asMap().entries.map((entry) {
          final i = entry.key;
          final label = entry.value;
          final active = controller.index == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.animateTo(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                  border: active
                      ? Border.all(color: AppColors.blackCharcoal, width: 1.5)
                      : null,
                  boxShadow: active ? const [AppColors.hardShadowSm] : null,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelBold.copyWith(
                    color: active
                        ? AppColors.onPrimaryContainer
                        : AppColors.tertiary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Tab 0: Kegiatan ───────────────────────────────────────────────────────────

class _KegiatanTab extends StatefulWidget {
  const _KegiatanTab();

  @override
  State<_KegiatanTab> createState() => _KegiatanTabState();
}

class _KegiatanTabState extends State<_KegiatanTab> {
  String _filter = 'Semua';

  List<_KegiatanItem> get _filtered => _kKegiatanList
      .where((k) => _filter == 'Semua' || k.status == _filter)
      .toList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginPage, AppSpacing.stackGap,
        AppSpacing.marginPage, AppSpacing.stackGap,
      ),
      children: [
        // Filter chips
        Row(
          children: ['Semua', 'Upcoming', 'Selesai'].map((f) {
            final active = _filter == f;
            return GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                  border: Border.all(color: AppColors.blackCharcoal, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blackCharcoal,
                      offset: active ? const Offset(2, 2) : const Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(f, style: AppTypography.labelBold.copyWith(
                  color: active
                      ? AppColors.onPrimaryContainer
                      : AppColors.onSurface,
                )),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.stackGap),

        ..._filtered.map((k) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
          child: BrutalistCard(
            onTap: () => context.push('/kegiatan/${k.id}'),
            padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _StatusBadge(status: k.status),
                const Spacer(),
                Row(children: [
                  const Icon(Icons.people_outline, size: 14, color: AppColors.tertiary),
                  const SizedBox(width: 4),
                  Text('${k.participants} peserta',
                    style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                ]),
              ]),
              const SizedBox(height: 10),
              Text(k.title, style: AppTypography.headlineSm),
              const SizedBox(height: 10),
              const MyDivider(color: AppColors.borderSlate, height: 12),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.tertiary),
                const SizedBox(width: 6),
                Text(k.date, style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                const SizedBox(width: 16),
                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.tertiary),
                const SizedBox(width: 6),
                Expanded(child: Text(k.location,
                  style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                  overflow: TextOverflow.ellipsis)),
              ]),
            ]),
          ),
        )),
      ],
    );
  }
}

// ── Tab 1: Riwayat ────────────────────────────────────────────────────────────

class _RiwayatTab extends StatelessWidget {
  const _RiwayatTab();

  @override
  Widget build(BuildContext context) {
    final hadirCount = _kRiwayat.where((r) => r.hadir).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginPage, AppSpacing.stackGap,
        AppSpacing.marginPage, AppSpacing.stackGap,
      ),
      children: [
        // Summary card
        BrutalistCard(
          padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
          child: Row(children: [
            _StatBox(value: '${_kRiwayat.length}', label: 'Total',
              color: AppColors.surfaceContainerHigh),
            const SizedBox(width: AppSpacing.gutterGrid),
            _StatBox(value: '$hadirCount', label: 'Hadir',
              color: AppColors.secondaryContainer),
            const SizedBox(width: AppSpacing.gutterGrid),
            _StatBox(
              value: '${_kRiwayat.length - hadirCount}',
              label: 'Tidak Hadir',
              color: AppColors.errorContainer,
            ),
          ]),
        ),
        const SizedBox(height: AppSpacing.stackGap),

        Text('Timeline', style: AppTypography.headlineSm),
        const SizedBox(height: 12),

        ...List.generate(_kRiwayat.length, (i) {
          final item = _kRiwayat[i];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: item.hadir ? AppColors.secondary : AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.blackCharcoal, width: 2),
                  ),
                  child: Icon(
                    item.hadir ? Icons.check : Icons.close,
                    size: 12, color: Colors.white,
                  ),
                ),
                if (i < _kRiwayat.length - 1)
                  Container(width: 2, height: 60, color: AppColors.borderSlate),
              ]),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.gutterGrid),
                  child: BrutalistCard(
                    padding: const EdgeInsets.all(AppSpacing.innerPadding),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        _AttendanceBadge(hadir: item.hadir),
                        const Spacer(),
                        Text(item.date,
                          style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                      ]),
                      const SizedBox(height: 6),
                      Text(item.title, style: AppTypography.bodyLg),
                      const SizedBox(height: 6),
                      const MyDivider(color: AppColors.borderSlate, height: 8),
                    ]),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = status == 'Upcoming';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isUpcoming ? AppColors.secondaryContainer : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
      ),
      child: Text(status, style: AppTypography.labelBold.copyWith(
        color: isUpcoming ? AppColors.onSecondaryContainer : AppColors.tertiary,
      )),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label, required this.color});
  final String value, label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
        ),
        child: Column(children: [
          Text(value, style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w800)),
          Text(label, style: AppTypography.labelBold.copyWith(color: AppColors.tertiary),
            textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _AttendanceBadge extends StatelessWidget {
  const _AttendanceBadge({required this.hadir});
  final bool hadir;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hadir ? AppColors.secondaryContainer : AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
      ),
      child: Text(
        hadir ? 'Hadir' : 'Tidak Hadir',
        style: AppTypography.labelBold.copyWith(
          color: hadir ? AppColors.onSecondaryContainer : AppColors.onErrorContainer,
        ),
      ),
    );
  }
}
