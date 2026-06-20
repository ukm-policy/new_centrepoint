import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/session/app_session.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/repositories/kegiatan_repository.dart';

class _LocalRiwayat {
  const _LocalRiwayat({
    required this.title,
    required this.date,
    required this.hadir,
    required this.role,
    required this.year,
  });
  final String title, date, role, year;
  final bool hadir;
}

class RiwayatKegiatanScreen extends StatefulWidget {
  const RiwayatKegiatanScreen({super.key});

  @override
  State<RiwayatKegiatanScreen> createState() => _RiwayatKegiatanScreenState();
}

class _RiwayatKegiatanScreenState extends State<RiwayatKegiatanScreen> {
  String _filter = 'Semua';

  String _fmtDate(DateTime d) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final kegiatanList = context.watch<KegiatanRepository>().kegiatan;
    final List<_LocalRiwayat> list = [];

    for (final k in kegiatanList) {
      bool isPanitia = false;
      String roleLabel = 'Peserta';

      if (k.ketuaPelaksana?.nama == AppSession.nama) {
        isPanitia = true;
        roleLabel = 'Ketua Pelaksana';
      } else if (k.sekretarisPelaksana?.nama == AppSession.nama) {
        isPanitia = true;
        roleLabel = 'Sekretaris Pelaksana';
      } else if (k.bendaharaPelaksana?.nama == AppSession.nama) {
        isPanitia = true;
        roleLabel = 'Bendahara Pelaksana';
      } else {
        for (final sie in k.sie) {
          if (sie.ketua?.nama == AppSession.nama) {
            isPanitia = true;
            roleLabel = 'Ketua ${sie.namaSie}';
            break;
          }
          if (sie.anggota.any((a) => a.nama == AppSession.nama)) {
            isPanitia = true;
            roleLabel = 'Anggota ${sie.namaSie}';
            break;
          }
        }
      }

      if (isPanitia || k.status == 'Selesai') {
        list.add(_LocalRiwayat(
          title: k.judul,
          date: _fmtDate(k.tanggal),
          hadir: k.id != '2', // mock absence for id 2
          role: roleLabel,
          year: k.tanggal.year.toString(),
        ));
      }
    }

    if (list.isEmpty) {
      list.addAll([
        const _LocalRiwayat(title: 'Seminar Kebijakan Publik 2023', date: '28 Oktober 2023', hadir: true, role: 'Peserta', year: '2023'),
        const _LocalRiwayat(title: 'Pelatihan Advokasi Kebijakan', date: '5 Oktober 2023', hadir: true, role: 'Panitia', year: '2023'),
      ]);
    }

    final filtered = list.where((item) {
      if (_filter == 'Semua') return true;
      if (_filter == 'Tahun Ini') return item.year == '2026';
      return item.year == '2023';
    }).toList();

    final hadirCount = filtered.where((r) => r.hadir).length;

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
                  'Riwayat Kegiatan',
                  style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginPage, 8, AppSpacing.marginPage, AppSpacing.stackGap,
        ),
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Semua', 'Tahun Ini', 'Tahun Lalu'].map((f) {
                final active = _filter == f;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8, bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
          ),
          const SizedBox(height: 8),

          // Summary card
          BrutalistCard(
            padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
            child: Row(children: [
              _StatBox(value: '${filtered.length}', label: 'Total Kegiatan',
                color: AppColors.surfaceContainerHigh),
              const SizedBox(width: AppSpacing.gutterGrid),
              _StatBox(value: '$hadirCount', label: 'Hadir',
                color: AppColors.secondaryContainer),
              const SizedBox(width: AppSpacing.gutterGrid),
              _StatBox(
                value: '${filtered.length - hadirCount}',
                label: 'Tidak Hadir',
                color: AppColors.errorContainer,
              ),
            ]),
          ),
          const SizedBox(height: AppSpacing.stackGap),

          Text('Timeline Kehadiran', style: AppTypography.headlineSm),
          const SizedBox(height: 12),

          filtered.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Tidak ada riwayat kegiatan untuk filter ini.',
                      style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                    ),
                  ),
                )
              : Column(
                  children: List.generate(filtered.length, (i) {
                    final item = filtered[i];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline indicator
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
                          if (i < filtered.length - 1)
                            Container(width: 2, height: 75, color: AppColors.borderSlate),
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
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceContainerLowest,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                      border: Border.all(color: AppColors.borderSlate, width: 1),
                                    ),
                                    child: Text(item.role.toUpperCase(), style: AppTypography.labelBold.copyWith(fontSize: 8, color: AppColors.tertiary)),
                                  ),
                                  const Spacer(),
                                  Text(item.date,
                                    style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, fontSize: 10)),
                                ]),
                                const SizedBox(height: 8),
                                Text(item.title, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                const MyDivider(color: AppColors.borderSlate, height: 8),
                              ]),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
        ],
      ),
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
          Text(label, style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, fontSize: 10),
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
          fontSize: 9,
        ),
      ),
    );
  }
}
