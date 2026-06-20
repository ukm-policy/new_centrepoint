import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';

class VerifikasiAnggotaScreen extends StatefulWidget {
  const VerifikasiAnggotaScreen({super.key});

  @override
  State<VerifikasiAnggotaScreen> createState() => _VerifikasiAnggotaScreenState();
}

class _VerifikasiAnggotaScreenState extends State<VerifikasiAnggotaScreen> {
  String _filter = 'Menunggu';
  final List<_Applicant> _applicants = [
    _Applicant(id: '1', name: 'Farhan Maulana', email: 'farhan@email.com', nim: '2024010012', angkatan: '2024', date: '18 Juni 2026', status: 'Menunggu'),
    _Applicant(id: '2', name: 'Nabila Syakieb', email: 'nabila@email.com', nim: '2024010015', angkatan: '2024', date: '19 Juni 2026', status: 'Menunggu'),
    _Applicant(id: '3', name: 'Raka Saputra', email: 'raka@email.com', nim: '2024010020', angkatan: '2024', date: '19 Juni 2026', status: 'Menunggu'),
    _Applicant(id: '4', name: 'Indah Permata', email: 'indah@email.com', nim: '2024010025', angkatan: '2024', date: '20 Juni 2026', status: 'Menunggu'),
    _Applicant(id: '5', name: 'Genta Buana', email: 'genta@email.com', nim: '2023010080', angkatan: '2023', date: '15 Juni 2026', status: 'Diterima'),
    _Applicant(id: '6', name: 'Sarah Azhari', email: 'sarah@email.com', nim: '2022010110', angkatan: '2022', date: '10 Juni 2026', status: 'Ditolak'),
  ];

  int get _pendingCount => _applicants.where((a) => a.status == 'Menunggu').length;

  List<_Applicant> get _filtered => _applicants.where((a) {
        if (_filter == 'Semua') return true;
        return a.status == _filter;
      }).toList();

  void _handleApprove(String id) {
    setState(() {
      final idx = _applicants.indexWhere((a) => a.id == id);
      if (idx != -1) {
        _applicants[idx] = _applicants[idx].copyWith(status: 'Diterima');
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Anggota berhasil diterima & diverifikasi!', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
      ),
    );
  }

  void _handleReject(String id) {
    setState(() {
      final idx = _applicants.indexWhere((a) => a.id == id);
      if (idx != -1) {
        _applicants[idx] = _applicants[idx].copyWith(status: 'Ditolak');
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pendaftaran anggota ditolak.', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
      ),
    );
  }

  void _showDetailDialog(_Applicant applicant) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            side: const BorderSide(color: AppColors.blackCharcoal, width: 2.5),
          ),
          backgroundColor: AppColors.surface,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Detail Pendaftar', style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: AppColors.tertiary),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MyDivider(color: AppColors.borderSlate, height: 16),
              _DetailField(label: 'Nama Lengkap', value: applicant.name),
              const SizedBox(height: 8),
              _DetailField(label: 'NIM', value: applicant.nim),
              const SizedBox(height: 8),
              _DetailField(label: 'Email', value: applicant.email),
              const SizedBox(height: 8),
              _DetailField(label: 'Angkatan', value: applicant.angkatan),
              const SizedBox(height: 8),
              _DetailField(label: 'Tanggal Daftar', value: applicant.date),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Status: ', style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor(applicant.status),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                    ),
                    child: Text(
                      applicant.status,
                      style: AppTypography.labelBold.copyWith(
                        color: applicant.status == 'Diterima' ? AppColors.onSuccess : AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (applicant.status == 'Menunggu') ...[
                BrutalistButton(
                  label: 'TERIMA & VERIFIKASI',
                  icon: Icons.check,
                  onPressed: () {
                    Navigator.pop(context);
                    _handleApprove(applicant.id);
                  },
                ),
                const SizedBox(height: 12),
                BrutalistButton(
                  label: 'TOLAK PENDAFTARAN',
                  variant: BrutalistButtonVariant.secondary,
                  icon: Icons.close,
                  onPressed: () {
                    Navigator.pop(context);
                    _handleReject(applicant.id);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'Diterima' => AppColors.success,
      'Ditolak' => AppColors.errorContainer,
      _ => AppColors.secondaryContainer,
    };
  }

  @override
  Widget build(BuildContext context) {
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
                // Badge waiting verif
                Row(
                  children: [
                    Text('Verifikasi', style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
                    if (_pendingCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                        ),
                        child: Text(
                          '$_pendingCount',
                          style: AppTypography.labelBold.copyWith(color: AppColors.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chips
            Padding(
              padding: const EdgeInsets.all(AppSpacing.marginPage),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Semua', 'Menunggu', 'Diterima', 'Ditolak'].map((f) {
                    final active = _filter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
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
            ),

            // Waiting List pendaftar
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada data pendaftar.',
                        style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) {
                        final app = _filtered[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
                          child: BrutalistCard(
                            onTap: () => _showDetailDialog(app),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        app.name,
                                        style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _statusColor(app.status),
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                        border: Border.all(color: AppColors.blackCharcoal, width: 1),
                                      ),
                                      child: Text(
                                        app.status,
                                        style: AppTypography.labelBold.copyWith(
                                          color: app.status == 'Diterima' ? AppColors.onSuccess : AppColors.onSurface,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('NIM: ${app.nim} · Angkatan ${app.angkatan}', style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                                const SizedBox(height: 10),
                                const MyDivider(color: AppColors.borderSlate),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 14, color: AppColors.tertiary),
                                    const SizedBox(width: 6),
                                    Text('Daftar: ${app.date}', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Text('Detail', style: AppTypography.labelBold.copyWith(color: AppColors.primary)),
                                        const SizedBox(width: 4),
                                        Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Applicant {
  const _Applicant({
    required this.id,
    required this.name,
    required this.email,
    required this.nim,
    required this.angkatan,
    required this.date,
    required this.status,
  });
  final String id, name, email, nim, angkatan, date, status;

  _Applicant copyWith({String? status}) {
    return _Applicant(
      id: id,
      name: name,
      email: email,
      nim: nim,
      angkatan: angkatan,
      date: date,
      status: status ?? this.status,
    );
  }
}
