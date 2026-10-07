import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/session/app_session.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/my_divider.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../shared/utils/initials.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../data/repositories/rapat_repository.dart';
import '../../../data/models/rapat_model.dart';

class _BidangDetail {
  const _BidangDetail({
    required this.nama,
    required this.alias,
    required this.deskripsi,
  });
  final String nama, alias, deskripsi;
}

class InfoBidangScreen extends StatefulWidget {
  const InfoBidangScreen({super.key});

  @override
  State<InfoBidangScreen> createState() => _InfoBidangScreenState();
}

class _InfoBidangScreenState extends State<InfoBidangScreen> {
  late String _selectedDiv;
  late bool _isGeneral;

  final Map<String, _BidangDetail> _details = const {
    'Pemrograman': _BidangDetail(
      nama: 'Bidang Pemrograman',
      alias: 'Pemrograman',
      deskripsi:
          'Bidang Pemrograman bertanggung jawab atas pengembangan aplikasi, website, dan sistem informasi internal UKM, serta pelatihan coding bagi anggota.',
    ),
    'Jaringan': _BidangDetail(
      nama: 'Bidang Jaringan',
      alias: 'Jaringan',
      deskripsi:
          'Bidang Jaringan mengelola infrastruktur jaringan komputer, keamanan siber, dan konektivitas sistem digital yang digunakan oleh UKM.',
    ),
    'Multimedia': _BidangDetail(
      nama: 'Bidang Multimedia',
      alias: 'Multimedia',
      deskripsi:
          'Bidang Multimedia mengelola konten visual, video, desain grafis, dan dokumentasi kegiatan untuk media sosial serta kebutuhan publikasi UKM.',
    ),
    'Pengembangan': _BidangDetail(
      nama: 'Bidang Pengembangan',
      alias: 'Pengembangan',
      deskripsi:
          'Bidang Pengembangan berfokus pada riset teknologi terbaru, inovasi organisasi, serta pengembangan kapasitas anggota melalui pelatihan dan studi banding.',
    ),
    'Kaderisasi': _BidangDetail(
      nama: 'Bidang Kaderisasi',
      alias: 'Kaderisasi',
      deskripsi:
          'Bidang Kaderisasi bertanggung jawab atas rekrutmen, pembinaan, dan pengembangan anggota baru agar menjadi kader organisasi yang kompeten dan berkarakter.',
    ),
    'Humas': _BidangDetail(
      nama: 'Bidang Humas',
      alias: 'Humas',
      deskripsi:
          'Bidang Humas mengelola hubungan eksternal, kerjasama dengan institusi lain, media relations, dan membangun citra positif UKM di lingkungan kampus maupun luar.',
    ),
  };

  @override
  void initState() {
    super.initState();
    // Check if user is in a general role
    _isGeneral = AppSession.bidang == '-' || AppSession.bidang.isEmpty;
    _selectedDiv = _isGeneral ? _details.keys.first : AppSession.bidang;
  }

  static const _bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  Widget build(BuildContext context) {
    final detail =
        _details[_selectedDiv] ??
        _BidangDetail(
          nama: 'Bidang $_selectedDiv',
          alias: _selectedDiv,
          deskripsi: 'Deskripsi bidang belum tersedia.',
        );

    // Filter members belonging to the active division
    final allMembers = context.watch<MemberRepository>().members;
    final members = allMembers.where((m) => m.bidang == _selectedDiv).toList();
    final bidangList = {
      ..._details.keys,
      ...allMembers
          .map((m) => m.bidang)
          .whereType<String>()
          .where((b) => b.isNotEmpty && b != '-'),
    }.toList();

    // Rata-rata kehadiran anggota bidang yang pernah terdaftar di kegiatan.
    final tercatat = members.where((m) => m.kegiatanCount > 0).toList();
    final hadirRate = tercatat.isEmpty
        ? '-'
        : '${(tercatat.fold<double>(0, (s, m) => s + m.kehadiranRate) / tercatat.length * 100).round()}%';

    // Timeline: rapat internal bidang terbaru.
    final timeline =
        context
            .watch<RapatRepository>()
            .rapat
            .where(
              (r) =>
                  r.namaBidang == _selectedDiv &&
                  r.status != RapatStatus.dibatalkan,
            )
            .toList()
          ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
    final timelineShown = timeline.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: PageAppBar(title: 'Info Internal Bidang'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginPage),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // General Mode Selector Info
              if (_isGeneral) ...[
                BrutalistCard(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: AppColors.surfaceContainerLowest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PILIH BIDANG KEPENGURUSAN',
                        style: AppTypography.labelBold.copyWith(
                          color: AppColors.tertiary,
                          fontSize: 10,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDiv,
                        onChanged: (v) {
                          setState(() {
                            _selectedDiv = v ?? _selectedDiv;
                          });
                        },
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurface,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          prefixIcon: Icon(Icons.workspaces_outline, size: 18),
                        ),
                        items: [
                          for (final b in bidangList)
                            DropdownMenuItem(
                              value: b,
                              child: Text('Bidang $b'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.stackGap),
              ],

              // Division Profile Card
              BrutalistCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          detail.nama,
                          style: AppTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                            border: Border.all(
                              color: AppColors.blackCharcoal,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            'BIDANG',
                            style: AppTypography.labelBold.copyWith(
                              color: AppColors.onPrimaryContainer,
                              fontSize: 10,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      detail.deskripsi,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.tertiary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const MyDivider(color: AppColors.borderSlate),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.show_chart,
                          size: 18,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rata-rata Kehadiran Anggota:',
                          style: AppTypography.bodyMd,
                        ),
                        const Spacer(),
                        Text(
                          hadirRate,
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.success,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // Members List Section
              Text(
                'ANGGOTA BIDANG (${members.length})',
                style: AppTypography.labelBold.copyWith(
                  color: AppColors.tertiary,
                  letterSpacing: 1.2,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 8),
              BrutalistCard(
                padding: const EdgeInsets.all(12),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  itemBuilder: (context, idx) {
                    final m = members[idx];
                    final isKetua =
                        m.jabatan?.contains('Kepala Bidang') ?? false;
                    final initials = initialsOf(m.nama);

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isKetua
                                      ? AppColors.secondaryContainer
                                      : AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm,
                                  ),
                                  border: Border.all(
                                    color: AppColors.blackCharcoal,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: AppTypography.labelBold.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.nama,
                                      style: AppTypography.bodyMd.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      m.nim,
                                      style: AppTypography.bodyMd.copyWith(
                                        color: AppColors.tertiary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isKetua
                                      ? AppColors.secondaryContainer
                                      : AppColors.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm,
                                  ),
                                  border: Border.all(
                                    color: AppColors.blackCharcoal,
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  isKetua ? 'KEPALA BIDANG' : 'STAFF',
                                  style: AppTypography.labelBold.copyWith(
                                    fontSize: 10,
                                    color: isKetua
                                        ? AppColors.onSecondaryContainer
                                        : AppColors.tertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (idx != members.length - 1)
                          const MyDivider(
                            color: AppColors.borderSlate,
                            height: 8,
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // Activity Timeline Section
              Text(
                'RAPAT INTERNAL BIDANG',
                style: AppTypography.labelBold.copyWith(
                  color: AppColors.tertiary,
                  letterSpacing: 1.2,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 8),
              BrutalistCard(
                padding: const EdgeInsets.all(16),
                child: timelineShown.isEmpty
                    ? Text(
                        'Belum ada rapat internal untuk bidang ini.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.tertiary,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: timelineShown.length,
                        itemBuilder: (context, idx) {
                          final r = timelineShown[idx];
                          final t = (
                            r.judul,
                            '${r.tanggal.day} ${_bulan[r.tanggal.month - 1]} ${r.tanggal.year}',
                            r.status == RapatStatus.selesai,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  t.$3
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: t.$3
                                      ? AppColors.success
                                      : AppColors.tertiary,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.$1,
                                        style: AppTypography.bodyMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                          decoration: t.$3
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: t.$3
                                              ? AppColors.tertiary
                                              : AppColors.onSurface,
                                        ),
                                      ),
                                      Text(
                                        t.$2,
                                        style: AppTypography.bodyMd.copyWith(
                                          color: AppColors.tertiary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
