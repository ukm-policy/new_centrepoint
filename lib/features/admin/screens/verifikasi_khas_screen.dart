import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/my_divider.dart';

class VerifikasiKhasScreen extends StatefulWidget {
  const VerifikasiKhasScreen({super.key});

  @override
  State<VerifikasiKhasScreen> createState() => _VerifikasiKhasScreenState();
}

class _VerifikasiKhasScreenState extends State<VerifikasiKhasScreen> {
  String _filter = 'Menunggu';
  final List<_KhasSubmission> _submissions = [
    _KhasSubmission(id: '1', name: 'Farhan Maulana', month: 'Juli', nominal: 'Rp 20.000', date: '18 Juni 2026', status: 'Menunggu'),
    _KhasSubmission(id: '2', name: 'Nabila Syakieb', month: 'Juli', nominal: 'Rp 20.000', date: '19 Juni 2026', status: 'Menunggu'),
    _KhasSubmission(id: '3', name: 'Raka Saputra', month: 'Juni', nominal: 'Rp 20.000', date: '19 Juni 2026', status: 'Menunggu'),
    _KhasSubmission(id: '4', name: 'Genta Buana', month: 'Mei', nominal: 'Rp 20.000', date: '15 Juni 2026', status: 'Dikonfirmasi'),
    _KhasSubmission(id: '5', name: 'Sarah Azhari', month: 'April', nominal: 'Rp 20.000', date: '10 Juni 2026', status: 'Ditolak'),
  ];

  List<_KhasSubmission> get _filtered => _submissions.where((s) {
        if (_filter == 'Semua') return true;
        return s.status == _filter;
      }).toList();

  int get _pendingCount => _submissions.where((s) => s.status == 'Menunggu').length;

  void _handleApprove(String id) {
    setState(() {
      final idx = _submissions.indexWhere((s) => s.id == id);
      if (idx != -1) {
        _submissions[idx] = _submissions[idx].copyWith(status: 'Dikonfirmasi');
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pembayaran iuran disetujui & lunas!', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
      ),
    );
  }

  void _handleReject(String id) {
    setState(() {
      final idx = _submissions.indexWhere((s) => s.id == id);
      if (idx != -1) {
        _submissions[idx] = _submissions[idx].copyWith(status: 'Ditolak');
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pembayaran iuran ditolak.', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSpacing.marginPage),
      ),
    );
  }

  void _showDetailDialog(_KhasSubmission submission) {
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
              Text('Bukti Pembayaran', style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
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
              _DetailField(label: 'Nama Anggota', value: submission.name),
              const SizedBox(height: 8),
              _DetailField(label: 'Iuran Bulan', value: submission.month),
              const SizedBox(height: 8),
              _DetailField(label: 'Nominal Transfer', value: submission.nominal),
              const SizedBox(height: 12),
              
              // Fake Receipt image placeholder
              Text('Foto Bukti Transfer:', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
              const SizedBox(height: 6),
              BrutalistCard(
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.receipt_long, size: 40, color: AppColors.tertiary),
                      const SizedBox(height: 6),
                      Text('bukti_transfer.jpg', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (submission.status == 'Menunggu') ...[
                BrutalistButton(
                  label: 'KONFIRMASI LUNAS',
                  icon: Icons.check,
                  onPressed: () {
                    Navigator.pop(context);
                    _handleApprove(submission.id);
                  },
                ),
                const SizedBox(height: 12),
                BrutalistButton(
                  label: 'TOLAK BUKTI BAYAR',
                  variant: BrutalistButtonVariant.secondary,
                  icon: Icons.close,
                  onPressed: () {
                    Navigator.pop(context);
                    _handleReject(submission.id);
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
      'Dikonfirmasi' => AppColors.success,
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
                Row(
                  children: [
                    Text('Verifikasi Kas', style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
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
                  children: ['Semua', 'Menunggu', 'Dikonfirmasi', 'Ditolak'].map((f) {
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

            // Submissions List
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada bukti transfer masuk.',
                        style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
                      itemCount: _filtered.length,
                      itemBuilder: (context, i) {
                        final sub = _filtered[i];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
                          child: BrutalistCard(
                            onTap: () => _showDetailDialog(sub),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        sub.name,
                                        style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _statusColor(sub.status),
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                        border: Border.all(color: AppColors.blackCharcoal, width: 1.2),
                                      ),
                                      child: Text(
                                        sub.status,
                                        style: AppTypography.labelBold.copyWith(
                                          color: sub.status == 'Dikonfirmasi' ? AppColors.onSuccess : AppColors.onSurface,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('Iuran Bulan: ${sub.month} · Nominal: ${sub.nominal}', style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                                const SizedBox(height: 10),
                                const MyDivider(color: AppColors.borderSlate),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 14, color: AppColors.tertiary),
                                    const SizedBox(width: 6),
                                    Text('Dikirim: ${sub.date}', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        Text('Periksa Bukti', style: AppTypography.labelBold.copyWith(color: AppColors.primary)),
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

class _KhasSubmission {
  const _KhasSubmission({
    required this.id,
    required this.name,
    required this.month,
    required this.nominal,
    required this.date,
    required this.status,
  });

  final String id, name, month, nominal, date, status;

  _KhasSubmission copyWith({String? status}) {
    return _KhasSubmission(
      id: id,
      name: name,
      month: month,
      nominal: nominal,
      date: date,
      status: status ?? this.status,
    );
  }
}
