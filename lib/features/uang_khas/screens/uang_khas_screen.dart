import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/session/app_session.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/repositories/uang_khas_repository.dart';
import '../../../data/models/uang_khas_model.dart';

class UangKhasScreen extends StatefulWidget {
  const UangKhasScreen({super.key});

  @override
  State<UangKhasScreen> createState() => _UangKhasScreenState();
}

class _UangKhasScreenState extends State<UangKhasScreen> {
  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  final List<String> _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  XFile? _receiptImage;
  bool _isUploading = false;
  final _picker = ImagePicker();

  Future<void> _pickReceipt(StateSetter setModalState) async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setModalState(() {
        _receiptImage = file;
      });
    }
  }

  Future<void> _submitReceipt(int monthIdx) async {
    if (_receiptImage == null) return;
    setState(() => _isUploading = true);
    
    try {
      final uid = AppSession.currentUser.id;
      if (uid.isEmpty) throw Exception("User not authenticated");
      
      final bytes = await _receiptImage!.readAsBytes();
      final fileExt = _receiptImage!.name.split('.').last;
      final filePath = '$uid/${_months[monthIdx]}_2026.$fileExt';
      
      await Supabase.instance.client.storage.from('bukti-bayar').uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true),
      );
      
      final publicUrl = Supabase.instance.client.storage.from('bukti-bayar').getPublicUrl(filePath);
      
      if (!mounted) return;
      context.read<UangKhasRepository>().payUangKhas(
        uid,
        _months[monthIdx],
        2026,
        20000, // Rp 20.000 nominal
        publicUrl,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bukti transfer untuk bulan ${_months[monthIdx]} berhasil dikirim. Menunggu verifikasi Bendahara.',
            style: AppTypography.bodyMd.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.blackCharcoal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim bukti: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _receiptImage = null;
        });
      }
    }
  }

  void _showUploadReceiptSheet(int monthIdx) {
    _receiptImage = null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusLg),
                  topRight: Radius.circular(AppSpacing.radiusLg),
                ),
                border: Border(
                  top: BorderSide(color: AppColors.blackCharcoal, width: 2.5),
                  left: BorderSide(color: AppColors.blackCharcoal, width: 2.5),
                  right: BorderSide(color: AppColors.blackCharcoal, width: 2.5),
                ),
              ),
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Bayar Iuran Bulan ${_months[monthIdx]}',
                    style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nominal Iuran: Rp 20.000',
                    style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                  ),
                  const SizedBox(height: 12),
                  const MyDivider(color: AppColors.borderSlate),
                  const SizedBox(height: 16),
                  
                  // Receipt Upload Area
                  GestureDetector(
                    onTap: () => _pickReceipt(setModalState),
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: _receiptImage != null ? AppColors.success.withValues(alpha: 0.1) : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(color: AppColors.blackCharcoal, width: 2),
                        boxShadow: const [AppColors.hardShadowSm],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _receiptImage != null
                            ? [
                                const Icon(Icons.check_circle, size: 48, color: AppColors.success),
                                const SizedBox(height: 8),
                                Text(
                                  _receiptImage!.name,
                                  style: AppTypography.labelBold,
                                ),
                                Text(
                                  'Ketuk untuk mengganti file',
                                  style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary, fontSize: 12),
                                ),
                              ]
                            : [
                                const Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.tertiary),
                                const SizedBox(height: 8),
                                Text('Upload Bukti Transfer', style: AppTypography.headlineSm.copyWith(fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(
                                  'Format JPG/PNG, maks. 2MB',
                                  style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary, fontSize: 12),
                                ),
                              ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  _isUploading
                      ? const Center(child: CircularProgressIndicator())
                      : BrutalistButton(
                          label: 'KIRIM BUKTI PEMBAYARAN',
                          onPressed: _receiptImage != null
                              ? () async {
                                  Navigator.pop(context);
                                  await _submitReceipt(monthIdx);
                                }
                              : null,
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<UangKhasRepository>();
    final uid = AppSession.currentUser.id;
    final myKhas = repo.khasBulan.where((k) => k.memberId == uid && k.tahun == 2026).toList();
    final transactions = repo.transaksi;

    final total = transactions.where((t) => !t.isPending).fold<int>(
      0, (sum, t) => sum + (t.isPemasukan ? t.jumlah : -t.jumlah));

    // Map month indices to statuses
    final monthStatuses = List.generate(12, (index) {
      final name = _months[index];
      final record = myKhas.where((k) => k.bulan == name).firstOrNull;
      if (record == null) return 'Belum Bayar';
      
      switch (record.status) {
        case StatusBayar.lunas:
          return 'Lunas';
        case StatusBayar.pending:
          return 'Menunggu Verifikasi';
        case StatusBayar.belumBayar:
          return 'Belum Bayar';
      }
    });

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: FloatingAppBar(title: 'Uang Khas', showBack: true)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginPage, AppSpacing.stackGap,
            AppSpacing.marginPage, AppSpacing.stackGap,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Admin Panel link (Conditional)
              if (AppSession.level >= 4) ...[
                BrutalistButton(
                  label: 'PANEL KELOLA UANG KHAS',
                  icon: Icons.admin_panel_settings,
                  onPressed: () => context.push('/admin/uang-khas'),
                ),
                const SizedBox(height: AppSpacing.stackGap),
              ],

              // Balance card
              BrutalistCard(
                backgroundColor: AppColors.blackCharcoal,
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Saldo Kas Aktif',
                    style: AppTypography.labelBold.copyWith(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text(
                    _formatRupiah(total),
                    style: AppTypography.displayLgMobile.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    _BalanceStat(
                      label: 'Pemasukan',
                      value: _formatRupiah(transactions
                        .where((t) => t.isPemasukan && !t.isPending)
                        .fold(0, (s, t) => s + t.jumlah)),
                      color: AppColors.secondaryContainer,
                      textColor: AppColors.onSecondaryContainer,
                    ),
                    const SizedBox(width: 12),
                    _BalanceStat(
                      label: 'Pengeluaran',
                      value: _formatRupiah(transactions
                        .where((t) => !t.isPemasukan)
                        .fold(0, (s, t) => s + t.jumlah)),
                      color: AppColors.errorContainer,
                      textColor: AppColors.onErrorContainer,
                    ),
                  ]),
                ]),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // Status iuran
              if (AppSession.kodeRole == 'demisioner')
                _SectionCard(
                  title: 'Status Iuran Saya',
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                      border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                      boxShadow: const [AppColors.hardShadowSm],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user, color: AppColors.onSecondaryContainer, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Sebagai Anggota Demisioner, Anda dibebaskan dari iuran uang khas organisasi. Terima kasih atas dedikasi Anda di periode sebelumnya!',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.onSecondaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _SectionCard(
                  title: 'Status Iuran Saya (2026)',
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, i) {
                      final status = monthStatuses[i];
                      final isLunas = status == 'Lunas';
                      final isPending = status == 'Menunggu Verifikasi';
                      final isDitolak = status == 'Ditolak';
                      
                      Color bg = AppColors.surfaceContainerLowest;
                      Color fg = AppColors.onSurface;
                      if (isLunas) {
                        bg = AppColors.success;
                        fg = Colors.white;
                      } else if (isPending) {
                        bg = AppColors.secondaryContainer;
                        fg = AppColors.onSecondaryContainer;
                      } else if (isDitolak) {
                        bg = AppColors.errorContainer;
                        fg = AppColors.onErrorContainer;
                      }

                      return GestureDetector(
                        onTap: () {
                          if (status != 'Lunas' && status != 'Menunggu Verifikasi') {
                            _showUploadReceiptSheet(i);
                          } else if (status == 'Menunggu Verifikasi') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Pembayaran bulan ${_months[i]} sedang diverifikasi oleh Bendahara.', style: AppTypography.bodyMd),
                                backgroundColor: AppColors.blackCharcoal,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Iuran bulan ${_months[i]} sudah lunas.', style: AppTypography.bodyMd),
                                backgroundColor: AppColors.blackCharcoal,
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(AppSpacing.radius),
                            border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _monthsShort[i],
                                style: AppTypography.labelBold.copyWith(color: fg),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                status == 'Lunas' ? 'LUNAS' : (status == 'Menunggu Verifikasi' ? 'PROSES' : (status == 'Ditolak' ? 'TOLAK' : 'BELUM')),
                                style: AppTypography.labelBold.copyWith(color: fg.withValues(alpha: 0.8), fontSize: 8),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.stackGap),

              // Riwayat transaksi
              _SectionCard(
                title: 'Riwayat Transaksi',
                child: transactions.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text('Belum ada transaksi kas.', style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                        ),
                      )
                    : Column(children: transactions.map((t) => Column(children: [
                        _TransaksiRow(item: t),
                        if (t != transactions.last) ...[
                          const SizedBox(height: 8),
                          const MyDivider(color: AppColors.borderSlate, height: 8),
                          const SizedBox(height: 8),
                        ],
                      ])).toList()),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  String _formatRupiah(int amount) {
    final abs = amount.abs();
    final formatted = abs.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }
}

class _BalanceStat extends StatelessWidget {
  const _BalanceStat({
    required this.label, required this.value,
    required this.color, required this.textColor,
  });
  final String label, value;
  final Color color, textColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTypography.labelBold.copyWith(color: textColor)),
          Text(value, style: AppTypography.bodyLg.copyWith(
            color: textColor, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
        boxShadow: const [AppColors.hardShadow],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTypography.headlineSm),
        const SizedBox(height: 12),
        const MyDivider(color: AppColors.borderSlate, height: 12),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

class _TransaksiRow extends StatelessWidget {
  const _TransaksiRow({required this.item});
  final TransaksiKhasModel item;

  @override
  Widget build(BuildContext context) {
    final List<String> monthsShort = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final formattedDate = "${item.tanggal.day} ${monthsShort[item.tanggal.month - 1]} ${item.tanggal.year}";
    return Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: item.isPemasukan ? AppColors.secondaryContainer : AppColors.errorContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
        ),
        child: Icon(
          item.isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
          size: 18,
          color: item.isPemasukan ? AppColors.onSecondaryContainer : AppColors.onErrorContainer,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.label, style: AppTypography.bodyMd, overflow: TextOverflow.ellipsis),
        Row(
          children: [
            Text(formattedDate, style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
            if (item.isPending) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.blackCharcoal, width: 1),
                ),
                child: Text(
                  'PROSES',
                  style: AppTypography.labelBold.copyWith(fontSize: 8, color: AppColors.onSecondaryContainer),
                ),
              ),
            ],
          ],
        ),
      ])),
      Text(
        '${item.isPemasukan ? '+' : '-'} Rp ${_fmt(item.jumlah)}',
        style: AppTypography.bodyMd.copyWith(
          color: item.isPending
              ? AppColors.tertiary
              : (item.isPemasukan ? AppColors.success : AppColors.error),
          fontWeight: FontWeight.w700,
        ),
      ),
    ]);
  }

  String _fmt(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}

