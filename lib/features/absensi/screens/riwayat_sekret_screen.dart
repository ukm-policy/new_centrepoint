import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/my_divider.dart';

const _kRiwayatSekret = [
  _SekretEntry(
    tanggal: 'Jumat, 20 Jun 2025',
    jamMasuk: '08.14 WIB',
    status: 'Tepat Waktu',
    isLate: false,
    keterangan: 'Piket rutin',
  ),
  _SekretEntry(
    tanggal: 'Kamis, 19 Jun 2025',
    jamMasuk: '09.47 WIB',
    status: 'Terlambat',
    isLate: true,
    keterangan: 'Rapat divisi',
  ),
  _SekretEntry(
    tanggal: 'Rabu, 18 Jun 2025',
    jamMasuk: '07.58 WIB',
    status: 'Tepat Waktu',
    isLate: false,
    keterangan: 'Piket rutin',
  ),
  _SekretEntry(
    tanggal: 'Selasa, 17 Jun 2025',
    jamMasuk: '08.02 WIB',
    status: 'Tepat Waktu',
    isLate: false,
    keterangan: 'Koordinasi kegiatan',
  ),
  _SekretEntry(
    tanggal: 'Senin, 16 Jun 2025',
    jamMasuk: '10.15 WIB',
    status: 'Terlambat',
    isLate: true,
    keterangan: 'Izin terlambat',
  ),
  _SekretEntry(
    tanggal: 'Jumat, 13 Jun 2025',
    jamMasuk: '08.00 WIB',
    status: 'Tepat Waktu',
    isLate: false,
    keterangan: 'Piket rutin',
  ),
  _SekretEntry(
    tanggal: 'Kamis, 12 Jun 2025',
    jamMasuk: '08.30 WIB',
    status: 'Tepat Waktu',
    isLate: false,
    keterangan: 'Belajar bersama',
  ),
];

class _SekretEntry {
  const _SekretEntry({
    required this.tanggal,
    required this.jamMasuk,
    required this.status,
    required this.isLate,
    required this.keterangan,
  });
  final String tanggal, jamMasuk, status, keterangan;
  final bool isLate;
}

class RiwayatSekretScreen extends StatelessWidget {
  const RiwayatSekretScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tepat = _kRiwayatSekret.where((e) => !e.isLate).length;
    final telat = _kRiwayatSekret.where((e) => e.isLate).length;
    final persen = ((tepat / _kRiwayatSekret.length) * 100).round();

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
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Riwayat Masuk Sekret', style: AppTypography.headlineSm),
          Text('Juni 2025', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
        ]),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginPage, 8, AppSpacing.marginPage, AppSpacing.stackGap,
        ),
        children: [

          // ── Statistik ringkasan ──────────────────────────────────────────
          BrutalistCard(
            backgroundColor: AppColors.blackCharcoal,
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Ringkasan Bulan Ini',
                style: AppTypography.labelBold.copyWith(color: Colors.white60)),
              const SizedBox(height: 12),
              Row(children: [
                Text('$persen%',
                  style: AppTypography.displayLgMobile.copyWith(color: Colors.white)),
                const SizedBox(width: 8),
                Text('Ketepatan Waktu',
                  style: AppTypography.bodyLg.copyWith(color: Colors.white70)),
              ]),
              const SizedBox(height: 16),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(children: [
                  Container(height: 10, color: Colors.white12),
                  FractionallySizedBox(
                    widthFactor: persen / 100,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              Row(children: [
                _StatPill(
                  value: '${_kRiwayatSekret.length}',
                  label: 'Total',
                  bgColor: Colors.white12,
                  textColor: Colors.white,
                ),
                const SizedBox(width: 8),
                _StatPill(
                  value: '$tepat',
                  label: 'Tepat Waktu',
                  bgColor: AppColors.secondary.withValues(alpha: 0.3),
                  textColor: AppColors.secondaryContainer,
                ),
                const SizedBox(width: 8),
                _StatPill(
                  value: '$telat',
                  label: 'Terlambat',
                  bgColor: AppColors.error.withValues(alpha: 0.3),
                  textColor: AppColors.errorContainer,
                ),
              ]),
            ]),
          ),
          const SizedBox(height: AppSpacing.stackGap),

          // ── Filter bulan (dekoratif) ─────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Jun 2025', 'Mei 2025', 'Apr 2025', 'Mar 2025'].map((b) {
                final active = b == 'Jun 2025';
                return Container(
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
                  child: Text(b, style: AppTypography.labelBold.copyWith(
                    color: active ? AppColors.onPrimaryContainer : AppColors.onSurface,
                  )),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.stackGap),

          // ── List riwayat ─────────────────────────────────────────────────
          Text('${_kRiwayatSekret.length} catatan',
            style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
          const SizedBox(height: 12),

          ..._kRiwayatSekret.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
            child: _SekretEntryCard(entry: entry),
          )),
        ],
      ),
    );
  }
}

// ── Entry Card ────────────────────────────────────────────────────────────────

class _SekretEntryCard extends StatefulWidget {
  const _SekretEntryCard({required this.entry});
  final _SekretEntry entry;

  @override
  State<_SekretEntryCard> createState() => _SekretEntryCardState();
}

class _SekretEntryCardState extends State<_SekretEntryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    return BrutalistCard(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            // Foto thumbnail
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                border: Border.all(color: AppColors.blackCharcoal, width: 2),
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D3436), Color(0xFF636E72)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.home_work, size: 28, color: Colors.white54),
            ),
            const SizedBox(width: 12),

            // Info utama
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.tanggal,
                style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.login, size: 14, color: AppColors.tertiary),
                const SizedBox(width: 4),
                Text('Masuk ${e.jamMasuk}',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
              ]),
            ])),

            // Status badge
            _StatusBadge(status: e.status, isLate: e.isLate),
          ]),

          // Detail ekspand
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 12),
              const MyDivider(color: AppColors.borderSlate, height: 12),
              const SizedBox(height: 12),

              // Foto preview besar
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                  border: Border.all(color: AppColors.blackCharcoal, width: 2),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D3436), Color(0xFF636E72)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.home_work, size: 48, color: Colors.white38),
                  const SizedBox(height: 6),
                  Text('Foto Bukti Sekret',
                    style: AppTypography.labelBold.copyWith(color: Colors.white54)),
                ]),
              ),
              const SizedBox(height: 12),

              // Detail baris
              _DetailRow(icon: Icons.calendar_today_outlined, label: 'Tanggal', value: e.tanggal),
              const SizedBox(height: 6),
              _DetailRow(icon: Icons.login, label: 'Jam Masuk', value: e.jamMasuk),
              const SizedBox(height: 6),
              _DetailRow(icon: Icons.notes, label: 'Keterangan', value: e.keterangan),
            ]),
          ),

          // Expand chevron
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: _expanded ? 0.5 : 0,
              child: const Icon(Icons.keyboard_arrow_down,
                size: 20, color: AppColors.tertiary),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.isLate});
  final String status;
  final bool isLate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isLate ? AppColors.errorContainer : AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
        boxShadow: const [AppColors.hardShadowSm],
      ),
      child: Text(status, style: AppTypography.labelBold.copyWith(
        color: isLate ? AppColors.onErrorContainer : AppColors.onSecondaryContainer,
      )),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.value,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });
  final String value, label;
  final Color bgColor, textColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(children: [
          Text(value, style: AppTypography.headlineSm.copyWith(color: textColor)),
          Text(label, style: AppTypography.labelBold.copyWith(
            color: textColor.withValues(alpha: 0.8), fontSize: 10)),
        ]),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: AppColors.tertiary),
      const SizedBox(width: 8),
      Text('$label: ', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
      Expanded(child: Text(value, style: AppTypography.bodyMd)),
    ]);
  }
}
