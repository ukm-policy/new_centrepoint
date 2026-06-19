import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';

const _kTransaksi = [
  _Transaksi(label: 'Iuran Bulanan — Ahmad Ridhwan', date: '1 Okt 2023', amount: 50000, isIncome: true),
  _Transaksi(label: 'Konsumsi Seminar Q3', date: '3 Okt 2023', amount: 150000, isIncome: false),
  _Transaksi(label: 'Iuran Bulanan — Siti Nurhaliza', date: '5 Okt 2023', amount: 50000, isIncome: true),
  _Transaksi(label: 'Percetakan Materi', date: '8 Okt 2023', amount: 75000, isIncome: false),
  _Transaksi(label: 'Iuran Bulanan — Budi Santoso', date: '10 Okt 2023', amount: 50000, isIncome: true),
  _Transaksi(label: 'Sewa Ruangan Workshop', date: '12 Okt 2023', amount: 200000, isIncome: false),
];

class _Transaksi {
  const _Transaksi({
    required this.label, required this.date,
    required this.amount, required this.isIncome,
  });
  final String label, date;
  final int amount;
  final bool isIncome;
}

class UangKhasScreen extends StatelessWidget {
  const UangKhasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final total = _kTransaksi.fold<int>(
      0, (sum, t) => sum + (t.isIncome ? t.amount : -t.amount));

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
              // Balance card
              BrutalistCard(
                backgroundColor: AppColors.blackCharcoal,
                padding: const EdgeInsets.all(24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Saldo Kas',
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
                      value: _formatRupiah(_kTransaksi
                        .where((t) => t.isIncome)
                        .fold(0, (s, t) => s + t.amount)),
                      color: AppColors.secondaryContainer,
                      textColor: AppColors.onSecondaryContainer,
                    ),
                    const SizedBox(width: 12),
                    _BalanceStat(
                      label: 'Pengeluaran',
                      value: _formatRupiah(_kTransaksi
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
                title: 'Status Iuran Saya',
                child: Row(children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                      border: Border.all(color: AppColors.blackCharcoal, width: 2),
                    ),
                    child: const Icon(Icons.check_circle, color: AppColors.success),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Oktober 2023',
                      style: AppTypography.headlineSm),
                    Text('Iuran sudah dibayar',
                      style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                      border: Border.all(color: AppColors.blackCharcoal, width: 2),
                      boxShadow: const [AppColors.hardShadowSm],
                    ),
                    child: Text('LUNAS',
                      style: AppTypography.labelBold.copyWith(
                          color: AppColors.onSecondaryContainer)),
                  ),
                ]),
              ),
              const SizedBox(height: AppSpacing.stackGap),

              // Riwayat transaksi
              _SectionCard(
                title: 'Riwayat Transaksi',
                child: Column(children: _kTransaksi.map((t) => Column(children: [
                  _TransaksiRow(item: t),
                  if (t != _kTransaksi.last) ...[
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
        Text(item.date, style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
      ])),
      Text(
        '${item.isIncome ? '+' : '-'} Rp ${_fmt(item.amount)}',
        style: AppTypography.bodyMd.copyWith(
          color: item.isIncome ? AppColors.success : AppColors.error,
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
