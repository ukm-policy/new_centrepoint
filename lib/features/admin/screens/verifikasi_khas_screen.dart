import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/uang_khas_model.dart';
import '../../../data/repositories/member_repository.dart';
import '../../../data/repositories/uang_khas_repository.dart';
import '../../../shared/utils/feedback.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/list_status.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../shared/widgets/floating_app_bar.dart';

class VerifikasiKhasScreen extends StatefulWidget {
  const VerifikasiKhasScreen({super.key});

  @override
  State<VerifikasiKhasScreen> createState() => _VerifikasiKhasScreenState();
}

class _VerifikasiKhasScreenState extends State<VerifikasiKhasScreen> {
  // Catatan: pembayaran yang ditolak dikembalikan ke status "belum bayar"
  // (bukti dihapus), jadi tidak ada filter "Ditolak".
  String _filter = 'Menunggu';

  static const _bulanSingkat = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  static String _fmtDate(DateTime? d) =>
      d == null ? '-' : '${d.day} ${_bulanSingkat[d.month - 1]} ${d.year}';

  static String _fmtRupiah(int v) => 'Rp ${v.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      )}';

  List<_KhasSubmission> _buildSubmissions(BuildContext context) {
    final khas = context.watch<UangKhasRepository>().khasBulan;
    final members = context.watch<MemberRepository>().members;
    final namaById = {for (final m in members) m.id: m.nama};

    final list = khas
        .where((k) =>
            k.status == StatusBayar.pending ||
            (k.status == StatusBayar.lunas && k.buktiUrl != null))
        .map((k) => _KhasSubmission(
              id: k.id,
              name: namaById[k.memberId] ?? 'Anggota',
              month: '${k.bulan} ${k.tahun}',
              nominal: _fmtRupiah(k.nominal),
              date: _fmtDate(k.tanggalBayar),
              status: k.status == StatusBayar.pending ? 'Menunggu' : 'Dikonfirmasi',
              buktiUrl: k.buktiUrl,
              tanggalBayar: k.tanggalBayar,
            ))
        .toList()
      // Yang menunggu paling atas, lalu terbaru dulu.
      ..sort((a, b) {
        if (a.status != b.status) return a.status == 'Menunggu' ? -1 : 1;
        final ta = a.tanggalBayar ?? DateTime(0);
        final tb = b.tanggalBayar ?? DateTime(0);
        return tb.compareTo(ta);
      });
    return list;
  }

  Future<void> _handleApprove(_KhasSubmission sub) async {
    await runWithFeedback(
      context,
      () => context.read<UangKhasRepository>().verifyPayment(sub.id, sub.name),
      success: 'Pembayaran iuran ${sub.name} disetujui & lunas!',
      errorPrefix: 'Gagal memverifikasi',
    );
  }

  Future<void> _handleReject(_KhasSubmission sub) async {
    await runWithFeedback(
      context,
      () => context.read<UangKhasRepository>().rejectPayment(sub.id),
      success: 'Pembayaran iuran ${sub.name} ditolak.',
      errorPrefix: 'Gagal menolak pembayaran',
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
              
              Text('Foto Bukti Transfer:', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
              const SizedBox(height: 6),
              BrutalistCard(
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                padding: EdgeInsets.zero,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: submission.buktiUrl == null
                      ? const _ReceiptPlaceholder(label: 'Tidak ada bukti')
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(AppSpacing.radius),
                          child: CachedNetworkImage(
                            imageUrl: submission.buktiUrl!,
                            fit: BoxFit.contain,
                            placeholder: (_, _) => const Center(
                              child: CircularProgressIndicator(color: AppColors.blackCharcoal),
                            ),
                            errorWidget: (_, _, _) =>
                                const _ReceiptPlaceholder(label: 'Gambar tidak dapat dimuat'),
                          ),
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
                    _handleApprove(submission);
                  },
                ),
                const SizedBox(height: 12),
                BrutalistButton(
                  label: 'TOLAK BUKTI BAYAR',
                  variant: BrutalistButtonVariant.secondary,
                  icon: Icons.close,
                  onPressed: () {
                    Navigator.pop(context);
                    _handleReject(submission);
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
      _ => AppColors.secondaryContainer,
    };
  }

  @override
  Widget build(BuildContext context) {
    final submissions = _buildSubmissions(context);
    final filtered = submissions.where((s) => _filter == 'Semua' || s.status == _filter).toList();
    final pendingCount = submissions.where((s) => s.status == 'Menunggu').length;
    final loading = context.watch<UangKhasRepository>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: PageAppBar(title: 'Verifikasi Kas', badgeCount: pendingCount),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Chips
            Padding(
              padding: const EdgeInsets.all(AppSpacing.marginPage),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Semua', 'Menunggu', 'Dikonfirmasi'].map((f) {
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
              child: filtered.isEmpty
                  ? ListStatus(
                      loading: loading && submissions.isEmpty,
                      icon: Icons.receipt_long_outlined,
                      message: 'Tidak ada bukti transfer masuk.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final sub = filtered[i];

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
                                          fontSize: 10,
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

class _ReceiptPlaceholder extends StatelessWidget {
  const _ReceiptPlaceholder({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.receipt_long, size: 40, color: AppColors.tertiary),
        const SizedBox(height: 6),
        Text(label, style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
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
    this.buktiUrl,
    this.tanggalBayar,
  });

  final String id, name, month, nominal, date, status;
  final String? buktiUrl;
  final DateTime? tanggalBayar;
}
