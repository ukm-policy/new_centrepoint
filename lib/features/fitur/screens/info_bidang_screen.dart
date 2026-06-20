import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/session/app_session.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/my_divider.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/member_repository.dart';

class _BidangDetail {
  const _BidangDetail({
    required this.nama,
    required this.alias,
    required this.deskripsi,
    required this.hadirRate,
    required this.timeline,
  });
  final String nama, alias, deskripsi, hadirRate;
  final List<(String, String, bool)> timeline;
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
      deskripsi: 'Bidang Pemrograman bertanggung jawab atas pengembangan aplikasi, website, dan sistem informasi internal UKM, serta pelatihan coding bagi anggota.',
      hadirRate: '95%',
      timeline: [
        ('Rilis Fitur Absensi QR v2', '10 Juli 2026', false),
        ('Workshop Flutter Lanjutan', '5 Juni 2026', true),
        ('Sprint Review Aplikasi Q2', '22 Mei 2026', true),
      ],
    ),
    'Jaringan': _BidangDetail(
      nama: 'Bidang Jaringan',
      alias: 'Jaringan',
      deskripsi: 'Bidang Jaringan mengelola infrastruktur jaringan komputer, keamanan siber, dan konektivitas sistem digital yang digunakan oleh UKM.',
      hadirRate: '91%',
      timeline: [
        ('Audit Keamanan Jaringan Internal', '20 Juli 2026', false),
        ('Workshop Networking Dasar', '15 Juni 2026', true),
        ('Setup Server Internal UKM', '1 Juni 2026', true),
      ],
    ),
    'Multimedia': _BidangDetail(
      nama: 'Bidang Multimedia',
      alias: 'Multimedia',
      deskripsi: 'Bidang Multimedia mengelola konten visual, video, desain grafis, dan dokumentasi kegiatan untuk media sosial serta kebutuhan publikasi UKM.',
      hadirRate: '89%',
      timeline: [
        ('Produksi Video Profil UKM 2026', '15 Juli 2026', false),
        ('Workshop Desain Konten', '20 Mei 2026', true),
        ('Dokumentasi Kegiatan Pelantikan', '2 Juni 2026', true),
      ],
    ),
    'Pengembangan': _BidangDetail(
      nama: 'Bidang Pengembangan',
      alias: 'Pengembangan',
      deskripsi: 'Bidang Pengembangan berfokus pada riset teknologi terbaru, inovasi organisasi, serta pengembangan kapasitas anggota melalui pelatihan dan studi banding.',
      hadirRate: '93%',
      timeline: [
        ('Seminar Inovasi Teknologi Q3', '18 Juli 2026', false),
        ('Pelatihan Leadership & Inovasi', '5 Juni 2026', true),
        ('Rapat Perencanaan Program Kerja', '28 Mei 2026', true),
      ],
    ),
    'Kaderisasi': _BidangDetail(
      nama: 'Bidang Kaderisasi',
      alias: 'Kaderisasi',
      deskripsi: 'Bidang Kaderisasi bertanggung jawab atas rekrutmen, pembinaan, dan pengembangan anggota baru agar menjadi kader organisasi yang kompeten dan berkarakter.',
      hadirRate: '97%',
      timeline: [
        ('Open Recruitment 2026/2027', '15 Juli 2026', false),
        ('Pelantikan Anggota Baru', '5 Juni 2026', true),
        ('Workshop Kaderisasi Internal', '20 Mei 2026', true),
      ],
    ),
    'Humas': _BidangDetail(
      nama: 'Bidang Humas',
      alias: 'Humas',
      deskripsi: 'Bidang Humas mengelola hubungan eksternal, kerjasama dengan institusi lain, media relations, dan membangun citra positif UKM di lingkungan kampus maupun luar.',
      hadirRate: '90%',
      timeline: [
        ('MoU Kerjasama dengan UKM Lain', '25 Juli 2026', false),
        ('Workshop Public Relations', '20 Mei 2026', true),
        ('Kunjungan Studi ke Universitas X', '10 Juni 2026', true),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    // Check if user is in a general role
    _isGeneral = AppSession.bidang == '-' || AppSession.bidang.isEmpty;
    _selectedDiv = _isGeneral ? 'Pemrograman' : AppSession.bidang;
  }

  @override
  Widget build(BuildContext context) {
    final detail = _details[_selectedDiv] ?? _details['Pemrograman']!;
    
    // Filter members belonging to the active division
    final members = context.watch<MemberRepository>().members.where((m) => m.bidang == _selectedDiv).toList();

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
                  'Info Internal Bidang',
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
                        style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, fontSize: 9, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDiv,
                        onChanged: (v) {
                          setState(() {
                            _selectedDiv = v ?? _selectedDiv;
                          });
                        },
                        style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          prefixIcon: Icon(Icons.workspaces_outline, size: 18),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Pemrograman', child: Text('Bidang Pemrograman')),
                          DropdownMenuItem(value: 'Jaringan', child: Text('Bidang Jaringan')),
                          DropdownMenuItem(value: 'Multimedia', child: Text('Bidang Multimedia')),
                          DropdownMenuItem(value: 'Pengembangan', child: Text('Bidang Pengembangan')),
                          DropdownMenuItem(value: 'Kaderisasi', child: Text('Bidang Kaderisasi')),
                          DropdownMenuItem(value: 'Humas', child: Text('Bidang Humas')),
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
                        Text(detail.nama, style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w900)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                          ),
                          child: Text(
                            'BIDANG',
                            style: AppTypography.labelBold.copyWith(color: AppColors.onPrimaryContainer, fontSize: 9, letterSpacing: 1.2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      detail.deskripsi,
                      style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                    ),
                    const SizedBox(height: 16),
                    const MyDivider(color: AppColors.borderSlate),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.show_chart, size: 18, color: AppColors.success),
                        const SizedBox(width: 8),
                        Text(
                          'Rata-rata Kehadiran Rapat:',
                          style: AppTypography.bodyMd,
                        ),
                        const Spacer(),
                        Text(
                          detail.hadirRate,
                          style: AppTypography.labelBold.copyWith(color: AppColors.success, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // Members List Section
              Text('ANGGOTA BIDANG (${members.length})', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, letterSpacing: 1.2, fontSize: 10)),
              const SizedBox(height: 8),
              BrutalistCard(
                padding: const EdgeInsets.all(12),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  itemBuilder: (context, idx) {
                    final m = members[idx];
                    final isKetua = m.jabatan?.contains('Kepala Bidang') ?? false;
                    final initials = m.nama.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
 
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
                                  color: isKetua ? AppColors.secondaryContainer : AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                                ),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: AppTypography.labelBold.copyWith(fontSize: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m.nama, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold)),
                                    Text(m.nim, style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary, fontSize: 11)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isKetua ? AppColors.secondaryContainer : AppColors.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  border: Border.all(color: AppColors.blackCharcoal, width: 1.2),
                                ),
                                child: Text(
                                  isKetua ? 'KEPALA BIDANG' : 'STAFF',
                                  style: AppTypography.labelBold.copyWith(fontSize: 8, color: isKetua ? AppColors.onSecondaryContainer : AppColors.tertiary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (idx != members.length - 1)
                          const MyDivider(color: AppColors.borderSlate, height: 8),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // Activity Timeline Section
              Text('TIMELINE & PROGRESS KERJA', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, letterSpacing: 1.2, fontSize: 10)),
              const SizedBox(height: 8),
              BrutalistCard(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: detail.timeline.length,
                  itemBuilder: (context, idx) {
                    final t = detail.timeline[idx];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            t.$3 ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: t.$3 ? AppColors.success : AppColors.tertiary,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.$1,
                                  style: AppTypography.bodyMd.copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration: t.$3 ? TextDecoration.lineThrough : null,
                                    color: t.$3 ? AppColors.tertiary : AppColors.onSurface,
                                  ),
                                ),
                                Text(
                                  'Target: ${t.$2}',
                                  style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary, fontSize: 11),
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
