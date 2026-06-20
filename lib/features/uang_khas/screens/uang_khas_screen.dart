import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/session/app_session.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';

class _Transaksi {
  const _Transaksi({
    required this.label,
    required this.date,
    required this.amount,
    required this.isIncome,
    this.isPending = false,
  });
  final String label, date;
  final int amount;
  final bool isIncome;
  final bool isPending;
}

class UangKhasScreen extends StatefulWidget {
  const UangKhasScreen({super.key});

  @override
  State<UangKhasScreen> createState() => _UangKhasScreenState();
}

class _UangKhasScreenState extends State<UangKhasScreen> {
  late List<_Transaksi> _transactions;
  late List<String> _monthStatuses;

  final List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  final List<String> _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  @override
  void initState() {
    super.initState();
    // Default: Jan - Jun lunas (dikonfirmasi), Jul - Des belum bayar
    _monthStatuses = List.generate(12, (index) => index < 6 ? 'Lunas' : 'Belum Bayar');
    _transactions = [
      const _Transaksi(label: 'Iuran Bulanan — Ahmad Ridhwan', date: '1 Okt 2023', amount: 50000, isIncome: true),
      const _Transaksi(label: 'Konsumsi Seminar Q3', date: '3 Okt 2023', amount: 150000, isIncome: false),
      const _Transaksi(label: 'Iuran Bulanan — Siti Nurhaliza', date: '5 Okt 2023', amount: 50000, isIncome: true),
      const _Transaksi(label: 'Percetakan Materi', date: '8 Okt 2023', amount: 75000, isIncome: false),
      const _Transaksi(label: 'Iuran Bulanan — Budi Santoso', date: '10 Okt 2023', amount: 50000, isIncome: true),
      const _Transaksi(label: 'Sewa Ruangan Workshop', date: '12 Okt 2023', amount: 200000, isIncome: false),
    ];
  }

  void _showUploadReceiptSheet(int monthIdx) {
    bool isUploaded = false;
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
                    onTap: () {
                      setModalState(() {
                        isUploaded = true;
                      });
                    },
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: isUploaded ? AppColors.success.withValues(alpha: 0.1) : AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(color: AppColors.blackCharcoal, width: 2),
                        boxShadow: const [AppColors.hardShadowSm],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: isUploaded
                            ? [
                                const Icon(Icons.check_circle, size: 48, color: AppColors.success),
                                const SizedBox(height: 8),
                                Text(
                                  'bukti_bayar_${_monthsShort[monthIdx].toLowerCase()}.jpg',
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
                  BrutalistButton(
                    label: 'KIRIM BUKTI PEMBAYARAN',
                    onPressed: isUploaded
                        ? () {
                            Navigator.pop(context);
                            setState(() {
                              _monthStatuses[monthIdx] = 'Menunggu Verifikasi';
                              _transactions.insert(
                                0,
                                _Transaksi(
                                  label: 'Iuran Bulanan (${_monthsShort[monthIdx]}) — ${AppSession.nama}',
                                  date: 'Hari Ini',
                                  amount: 20000,
                                  isIncome: true,
                                  isPending: true,
                                ),
                              );
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Bukti transfer untuk bulan ${_months[monthIdx]} berhasil dikirim. Menunggu verifikasi Bendahara.',
                                  style: AppTypography.bodyMd.copyWith(color: Colors.white),
                                ),
                                backgroundColor: AppColors.blackCharcoal,
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(AppSpacing.marginPage),
                              ),
                            );
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
    final total = _transactions.fold<int>(
      0, (sum, t) => sum + (t.isIncome && !t.isPending ? t.amount : -t.amount));

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
                      value: _formatRupiah(_transactions
                        .where((t) => t.isIncome && !t.isPending)
                        .fold(0, (s, t) => s + t.amount)),
                      color: AppColors.secondaryContainer,
                      textColor: AppColors.onSecondaryContainer,
                    ),
                    const SizedBox(width: 12),
                    _BalanceStat(
                      label: 'Pengeluaran',
                      value: _formatRupiah(_transactions
                        .where((t) => !t.isIncome)
                        .fold(0, (s, t) => s + t.amount)),
                      color: AppColors.errorContainer,
                      textColor: AppColors.onErrorContainer,
                    ),
                  ]),
                ]),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // Status iuran
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
                    final status = _monthStatuses[i];
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
                child: Column(children: _transactions.map((t) => Column(children: [
                  _TransaksiRow(item: t),
                  if (t != _transactions.last) ...[
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
  final _Transaksi item;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: item.isIncome ? AppColors.secondaryContainer : AppColors.errorContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
        ),
        child: Icon(
          item.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          size: 18,
          color: item.isIncome ? AppColors.onSecondaryContainer : AppColors.onErrorContainer,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.label, style: AppTypography.bodyMd, overflow: TextOverflow.ellipsis),
        Row(
          children: [
            Text(item.date, style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
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
        '${item.isIncome ? '+' : '-'} Rp ${_fmt(item.amount)}',
        style: AppTypography.bodyMd.copyWith(
          color: item.isPending
              ? AppColors.tertiary
              : (item.isIncome ? AppColors.success : AppColors.error),
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

