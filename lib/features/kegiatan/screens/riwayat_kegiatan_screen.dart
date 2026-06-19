import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/my_divider.dart';

const _kRiwayat = [
  _RiwayatItem(title: 'Pelatihan Advokasi Kebijakan', date: '5 Okt 2023', hadir: true),
  _RiwayatItem(title: 'Musyawarah Anggota Q3', date: '10 Okt 2023', hadir: true),
  _RiwayatItem(title: 'Workshop Penulisan Naskah Q2', date: '20 Agu 2023', hadir: false),
  _RiwayatItem(title: 'Seminar Hukum & Kebijakan', date: '15 Jul 2023', hadir: true),
  _RiwayatItem(title: 'Orientasi Anggota Baru 2023', date: '1 Jun 2023', hadir: true),
];

class _RiwayatItem {
  const _RiwayatItem({required this.title, required this.date, required this.hadir});
  final String title, date;
  final bool hadir;
}

class RiwayatKegiatanScreen extends StatelessWidget {
  const RiwayatKegiatanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hadirCount = _kRiwayat.where((r) => r.hadir).length;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        backgroundColor: AppColors.bgGray,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(color: AppColors.blackCharcoal, width: 2),
              boxShadow: const [AppColors.hardShadowSm],
            ),
            child: const Icon(Icons.arrow_back, color: AppColors.onSurface, size: 20),
          ),
        ),
        title: Text('Riwayat Kegiatan', style: AppTypography.headlineSm),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginPage, 8, AppSpacing.marginPage, AppSpacing.stackGap,
        ),
        children: [
          // Summary card
          BrutalistCard(
            padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
            child: Row(children: [
              _StatBox(value: '${_kRiwayat.length}', label: 'Total Kegiatan',
                color: AppColors.surfaceContainerHigh),
              const SizedBox(width: AppSpacing.gutterGrid),
              _StatBox(value: '$hadirCount', label: 'Hadir',
                color: AppColors.secondaryContainer),
              const SizedBox(width: AppSpacing.gutterGrid),
              _StatBox(
                value: '${_kRiwayat.length - hadirCount}',
                label: 'Tidak Hadir',
                color: AppColors.errorContainer,
              ),
            ]),
          ),
          const SizedBox(height: AppSpacing.stackGap),

          Text('Timeline', style: AppTypography.headlineSm),
          const SizedBox(height: 12),

          ...List.generate(_kRiwayat.length, (i) {
            final item = _kRiwayat[i];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline indicator
                Column(children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: item.hadir ? AppColors.secondary : AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.blackCharcoal, width: 2),
                    ),
                    child: Icon(
                      item.hadir ? Icons.check : Icons.close,
                      size: 12, color: Colors.white,
                    ),
                  ),
                  if (i < _kRiwayat.length - 1)
                    Container(width: 2, height: 60, color: AppColors.borderSlate),
                ]),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.gutterGrid),
                    child: BrutalistCard(
                      padding: const EdgeInsets.all(AppSpacing.innerPadding),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          _AttendanceBadge(hadir: item.hadir),
                          const Spacer(),
                          Text(item.date,
                            style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                        ]),
                        const SizedBox(height: 6),
                        Text(item.title, style: AppTypography.bodyLg),
                        const SizedBox(height: 6),
                        const MyDivider(color: AppColors.borderSlate, height: 8),
                      ]),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label, required this.color});
  final String value, label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
        ),
        child: Column(children: [
          Text(value, style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w800)),
          Text(label, style: AppTypography.labelBold.copyWith(color: AppColors.tertiary),
            textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _AttendanceBadge extends StatelessWidget {
  const _AttendanceBadge({required this.hadir});
  final bool hadir;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hadir ? AppColors.secondaryContainer : AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
      ),
      child: Text(
        hadir ? 'Hadir' : 'Tidak Hadir',
        style: AppTypography.labelBold.copyWith(
          color: hadir ? AppColors.onSecondaryContainer : AppColors.onErrorContainer,
        ),
      ),
    );
  }
}
