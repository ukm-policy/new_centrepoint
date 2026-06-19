import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';

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

class _KegiatanItem {
  const _KegiatanItem({
    required this.id, required this.title, required this.date,
    required this.location, required this.status, required this.participants,
  });
  final String id, title, date, location, status;
  final int participants;
}

class ListKegiatanScreen extends StatefulWidget {
  const ListKegiatanScreen({super.key});

  @override
  State<ListKegiatanScreen> createState() => _ListKegiatanScreenState();
}

class _ListKegiatanScreenState extends State<ListKegiatanScreen> {
  String _filter = 'Semua';

  List<_KegiatanItem> get _filtered => _kKegiatanList
      .where((k) => _filter == 'Semua' || k.status == _filter)
      .toList();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FloatingAppBar(
            title: 'Kegiatan',
            trailing: GestureDetector(
              onTap: () => context.push('/kegiatan/riwayat'),
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                  border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                ),
                child: Text('Riwayat', style: AppTypography.labelBold),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginPage, AppSpacing.stackGap,
            AppSpacing.marginPage, AppSpacing.stackGap,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
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
                        color: active ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                        border: Border.all(color: AppColors.blackCharcoal, width: 2),
                        boxShadow: [BoxShadow(
                          color: AppColors.blackCharcoal,
                          offset: active ? const Offset(2, 2) : const Offset(3, 3),
                          blurRadius: 0,
                        )],
                      ),
                      child: Text(f, style: AppTypography.labelBold.copyWith(
                        color: active ? AppColors.onPrimaryContainer : AppColors.onSurface,
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
            ]),
          ),
        ),
      ],
    );
  }
}

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
