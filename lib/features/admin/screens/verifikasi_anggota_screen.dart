import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/repositories/or_repository.dart';
import '../../../data/repositories/audit_log_repository.dart';
import '../../../data/models/or_model.dart';

class VerifikasiAnggotaScreen extends StatefulWidget {
  const VerifikasiAnggotaScreen({super.key});

  @override
  State<VerifikasiAnggotaScreen> createState() => _VerifikasiAnggotaScreenState();
}

class _VerifikasiAnggotaScreenState extends State<VerifikasiAnggotaScreen> {
  String _filter = 'Menunggu';

  String _statusLabel(ApplicantStatus s) => switch (s) {
    ApplicantStatus.pending => 'Menunggu',
    ApplicantStatus.diterima => 'Diterima',
    ApplicantStatus.ditolak => 'Ditolak',
  };

  bool _matchFilter(ApplicantStatus s) {
    if (_filter == 'Semua') return true;
    return _statusLabel(s) == _filter;
  }

  void _handleApprove(String id, String nama) {
    context.read<ORRepository>().reviewApplicant(id, ApplicantStatus.diterima);
    context.read<AuditLogRepository>().logAction(
      aksi: 'Menerima pendaftaran anggota: $nama',
      tipe: 'Verifikasi',
      entityId: id,
      entityType: 'or_pelamar',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Anggota berhasil diterima & diverifikasi!', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
      ),
    );
  }

  void _handleReject(String id, String nama) {
    context.read<ORRepository>().reviewApplicant(id, ApplicantStatus.ditolak);
    context.read<AuditLogRepository>().logAction(
      aksi: 'Menolak pendaftaran anggota: $nama',
      tipe: 'Verifikasi',
      entityId: id,
      entityType: 'or_pelamar',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pendaftaran anggota ditolak.', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
      ),
    );
  }

  void _showDetailDialog(ORApplicantModel applicant) {
    showDialog(
      context: context,
      builder: (context) {
        final statusLabel = _statusLabel(applicant.status);
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MyDivider(color: AppColors.borderSlate, height: 16),
                _DetailField(label: 'Nama Lengkap', value: applicant.nama),
                const SizedBox(height: 8),
                _DetailField(label: 'NIM', value: applicant.nim),
                const SizedBox(height: 8),
                _DetailField(label: 'Program Studi', value: applicant.prodi),
                const SizedBox(height: 8),
                _DetailField(label: 'Angkatan', value: applicant.angkatan),
                const SizedBox(height: 8),
                _DetailField(label: 'No. HP', value: applicant.noHp),
                const SizedBox(height: 8),
                _DetailField(label: 'Bidang Minat', value: applicant.bidangMinat),
                const SizedBox(height: 8),
                _DetailField(label: 'Tanggal Daftar', value: '${applicant.tanggalDaftar.day} ${_bulan(applicant.tanggalDaftar.month)} ${applicant.tanggalDaftar.year}'),
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
                        statusLabel,
                        style: AppTypography.labelBold.copyWith(
                          color: applicant.status == ApplicantStatus.diterima ? AppColors.onSuccess : AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (applicant.status == ApplicantStatus.pending) ...[
                  BrutalistButton(
                    label: 'TERIMA & VERIFIKASI',
                    icon: Icons.check,
                    onPressed: () {
                      Navigator.pop(context);
                      _handleApprove(applicant.id, applicant.nama);
                    },
                  ),
                  const SizedBox(height: 12),
                  BrutalistButton(
                    label: 'TOLAK PENDAFTARAN',
                    variant: BrutalistButtonVariant.secondary,
                    icon: Icons.close,
                    onPressed: () {
                      Navigator.pop(context);
                      _handleReject(applicant.id, applicant.nama);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Color _statusColor(ApplicantStatus s) => switch (s) {
    ApplicantStatus.diterima => AppColors.success,
    ApplicantStatus.ditolak => AppColors.errorContainer,
    ApplicantStatus.pending => AppColors.secondaryContainer,
  };

  String _bulan(int m) => ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][m];

  @override
  Widget build(BuildContext context) {
    return Consumer<ORRepository>(
      builder: (context, repo, _) {
        final all = repo.applicants;
        final pendingCount = all.where((a) => a.status == ApplicantStatus.pending).length;
        final filtered = all.where((a) => _matchFilter(a.status)).toList();

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
                    Row(
                      children: [
                        Text('Verifikasi', style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
                        if (pendingCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                            ),
                            child: Text(
                              '$pendingCount',
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
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada data pendaftar.',
                            style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final app = filtered[i];
                            final statusLabel = _statusLabel(app.status);
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
                                            app.nama,
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
                                            statusLabel,
                                            style: AppTypography.labelBold.copyWith(
                                              color: app.status == ApplicantStatus.diterima ? AppColors.onSuccess : AppColors.onSurface,
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
                                        Text(
                                          'Daftar: ${app.tanggalDaftar.day} ${_bulan(app.tanggalDaftar.month)} ${app.tanggalDaftar.year}',
                                          style: AppTypography.labelBold.copyWith(color: AppColors.tertiary),
                                        ),
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
      },
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
