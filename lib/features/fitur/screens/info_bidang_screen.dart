import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/session/app_session.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../anggota/anggota_data.dart';

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
    'Riset': _BidangDetail(
      nama: 'Riset Kebijakan',
      alias: 'Riset',
      deskripsi: 'Bidang Riset bertanggung jawab atas penelitian mendalam, analisis data primer/sekunder, dan penyusunan naskah kajian kebijakan publik secara komprehensif.',
      hadirRate: '94%',
      timeline: [
        ('Penyusunan Kajian AI Digital', '10 Juli 2026', false),
        ('Survei Kepuasan Kebijakan Kampus', '22 Juni 2026', true),
        ('Focus Group Discussion Riset Q2', '5 Juni 2026', true),
      ],
    ),
    'Publikasi': _BidangDetail(
      nama: 'Media & Publikasi',
      alias: 'Publikasi',
      deskripsi: 'Bidang Publikasi mengelola media sosial, website resmi, dokumentasi kegiatan, serta merancang konten infografis dan policy brief agar menarik bagi publik.',
      hadirRate: '89%',
      timeline: [
        ('Rilis Policy Brief Vol. 4', '15 Juli 2026', false),
        ('Workshop Desain Infografis', '12 Juni 2026', true),
        ('Dokumentasi Rapat Koordinasi', '1 Juni 2026', true),
      ],
    ),
    'Advokasi': _BidangDetail(
      nama: 'Kajian & Advokasi Isu',
      alias: 'Advokasi',
      deskripsi: 'Bidang Advokasi mengawal isu-isu regulasi krusial, mengadakan kajian kritis, melakukan lobi/audiensi dengan pihak eksternal, dan menggerakkan advokasi strategis.',
      hadirRate: '96%',
      timeline: [
        ('Audiensi Rektorat Isu UKT', '18 Juni 2026', true),
        ('Kajian Kritis UU Pers Kampus', '28 Mei 2026', true),
        ('Pelatihan Advokasi Dasar', '10 Mei 2026', true),
      ],
    ),
    'Kegiatan': _BidangDetail(
      nama: 'Manajemen Event & Internal',
      alias: 'Kegiatan',
      deskripsi: 'Bidang Kegiatan merancang, mengkoordinasikan, dan menyelenggarakan seluruh event eksternal maupun makrab/outbound internal pengurus.',
      hadirRate: '98%',
      timeline: [
        ('Persiapan POLICY Championship 2026', '12 Agustus 2026', false),
        ('Outbound & Team Building Pengurus', '20 Juni 2026', true),
        ('Orientasi Pengurus Baru', '2 Juni 2026', true),
      ],
    ),
  };

  @override
  void initState() {
    super.initState();
    // Check if user is in a general role
    _isGeneral = AppSession.bidang == '-' || AppSession.bidang.isEmpty;
    _selectedDiv = _isGeneral ? 'Riset' : AppSession.bidang;
  }

  @override
  Widget build(BuildContext context) {
    final detail = _details[_selectedDiv] ?? _details['Riset']!;
    
    // Filter members belonging to the active division
    final members = kMemberList.where((m) => m.division == _selectedDiv).toList();

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
                          DropdownMenuItem(value: 'Riset', child: Text('Riset Kebijakan')),
                          DropdownMenuItem(value: 'Publikasi', child: Text('Media & Publikasi')),
                          DropdownMenuItem(value: 'Advokasi', child: Text('Kajian & Advokasi Isu')),
                          DropdownMenuItem(value: 'Kegiatan', child: Text('Manajemen Event & Internal')),
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
                    final isKetua = m.role.contains('Lead') || m.role.contains('Manager') || m.role.contains('Senior');
                    final initials = m.name.split(' ').map((e) => e[0]).take(2).join().toUpperCase();

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
                                    Text(m.name, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold)),
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
