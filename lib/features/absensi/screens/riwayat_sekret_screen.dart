import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/session/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/absensi_model.dart';
import '../../../data/repositories/absensi_repository.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/list_status.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../shared/widgets/floating_app_bar.dart';

/// Absen masuk setelah jam ini dianggap terlambat.
const _batasJamMasuk = TimeOfDay(hour: 9, minute: 0);

const _hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

String _fmtTanggal(DateTime d) => '${_hari[d.weekday - 1]}, ${d.day} ${_bulan[d.month - 1]} ${d.year}';
String _fmtJam(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')} WIB';
String _fmtBulan(DateTime d) => '${_bulan[d.month - 1]} ${d.year}';

bool _isLate(DateTime d) =>
    d.hour > _batasJamMasuk.hour ||
    (d.hour == _batasJamMasuk.hour && d.minute > _batasJamMasuk.minute);

class RiwayatSekretScreen extends StatefulWidget {
  const RiwayatSekretScreen({super.key});

  @override
  State<RiwayatSekretScreen> createState() => _RiwayatSekretScreenState();
}

class _RiwayatSekretScreenState extends State<RiwayatSekretScreen> {
  DateTime? _bulanDipilih;

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AbsensiRepository>();
    // Pengurus (level >= 3) melihat riwayat semua anggota.
    final lihatSemua = AppSession.level >= 3 || AppSession.isAdmin;

    final semua = repo.absensi
        .where((a) => a.tipeKegiatan == 'sekret' && a.waktuScan != null)
        .where((a) => lihatSemua || a.memberId == AppSession.id)
        .toList()
      ..sort((a, b) => b.waktuScan!.compareTo(a.waktuScan!));

    // Daftar bulan yang punya data, terbaru dulu.
    final bulanList = <DateTime>[];
    for (final a in semua) {
      final m = DateTime(a.waktuScan!.year, a.waktuScan!.month);
      if (!bulanList.contains(m)) bulanList.add(m);
    }
    final bulanAktif = (_bulanDipilih != null && bulanList.contains(_bulanDipilih))
        ? _bulanDipilih!
        : (bulanList.isNotEmpty ? bulanList.first : DateTime(DateTime.now().year, DateTime.now().month));

    final entries = semua
        .where((a) => a.waktuScan!.year == bulanAktif.year && a.waktuScan!.month == bulanAktif.month)
        .toList();
    final telat = entries.where((e) => _isLate(e.waktuScan!)).length;
    final tepat = entries.length - telat;
    final persen = entries.isEmpty ? 0 : ((tepat / entries.length) * 100).round();

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: const PageAppBar(title: 'Riwayat Masuk Sekret'),
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
              Text('Ringkasan ${_fmtBulan(bulanAktif)}',
                style: AppTypography.labelBold.copyWith(color: Colors.white60)),
              const SizedBox(height: 12),
              Row(children: [
                Text('$persen%',
                  style: AppTypography.displayLgMobile.copyWith(color: Colors.white)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tepat waktu (≤ ${_batasJamMasuk.hour.toString().padLeft(2, '0')}.${_batasJamMasuk.minute.toString().padLeft(2, '0')})',
                    style: AppTypography.bodyLg.copyWith(color: Colors.white70),
                  ),
                ),
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
                  value: '${entries.length}',
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

          // ── Filter bulan ─────────────────────────────────────────────────
          if (bulanList.length > 1) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: bulanList.map((b) {
                  final active = b == bulanAktif;
                  return GestureDetector(
                    onTap: () => setState(() => _bulanDipilih = b),
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
                      child: Text(_fmtBulan(b), style: AppTypography.labelBold.copyWith(
                        color: active ? AppColors.onPrimaryContainer : AppColors.onSurface,
                      )),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.stackGap),
          ],

          // ── List riwayat ─────────────────────────────────────────────────
          Text('${entries.length} catatan',
            style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
          const SizedBox(height: 12),

          if (entries.isEmpty)
            ListStatus(
              loading: repo.isLoading && semua.isEmpty,
              icon: Icons.home_work_outlined,
              message: 'Belum ada catatan absen sekret.',
            ),

          ...entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
            child: _SekretEntryCard(entry: entry, tampilkanNama: lihatSemua),
          )),
        ],
      ),
    );
  }
}

// ── Entry Card ────────────────────────────────────────────────────────────────

class _SekretEntryCard extends StatefulWidget {
  const _SekretEntryCard({required this.entry, required this.tampilkanNama});
  final AbsensiModel entry;
  final bool tampilkanNama;

  @override
  State<_SekretEntryCard> createState() => _SekretEntryCardState();
}

class _SekretEntryCardState extends State<_SekretEntryCard> {
  bool _expanded = false;
  Future<String?>? _fotoUrl;

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      final path = widget.entry.fotoUrl;
      if (_expanded && _fotoUrl == null && path != null) {
        _fotoUrl = context.read<AbsensiRepository>().fotoSekretUrl(path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final waktu = e.waktuScan!;
    final late = _isLate(waktu);

    return BrutalistCard(
      onTap: _toggle,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                border: Border.all(color: AppColors.blackCharcoal, width: 2),
              ),
              child: Icon(
                e.fotoUrl != null ? Icons.photo_camera_outlined : Icons.home_work,
                size: 26,
                color: AppColors.tertiary,
              ),
            ),
            const SizedBox(width: 12),

            // Info utama
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (widget.tampilkanNama)
                Text(e.memberNama,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w800)),
              Text(_fmtTanggal(waktu),
                style: widget.tampilkanNama
                    ? AppTypography.bodyMd.copyWith(color: AppColors.tertiary)
                    : AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.login, size: 14, color: AppColors.tertiary),
                const SizedBox(width: 4),
                Text('Masuk ${_fmtJam(waktu)}',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
              ]),
            ])),

            _StatusBadge(isLate: late),
          ]),

          // Detail ekspand
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 12),
              const MyDivider(color: AppColors.borderSlate, height: 12),
              const SizedBox(height: 12),
              _FotoBukti(future: _fotoUrl),
              const SizedBox(height: 12),
              _DetailRow(icon: Icons.calendar_today_outlined, label: 'Tanggal', value: _fmtTanggal(waktu)),
              const SizedBox(height: 6),
              _DetailRow(icon: Icons.login, label: 'Jam Masuk', value: _fmtJam(waktu)),
              if (e.keterangan != null && e.keterangan!.isNotEmpty) ...[
                const SizedBox(height: 6),
                _DetailRow(icon: Icons.notes, label: 'Keterangan', value: e.keterangan!),
              ],
            ]),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: _expanded ? 0.5 : 0,
              child: const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.tertiary),
            ),
          ),
        ]),
      ),
    );
  }
}

class _FotoBukti extends StatelessWidget {
  const _FotoBukti({required this.future});
  final Future<String?>? future;

  Widget _box(Widget child) => Container(
        height: 180,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
        ),
        child: child,
      );

  Widget _message(String text) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.image_not_supported_outlined, size: 36, color: AppColors.tertiary),
          const SizedBox(height: 6),
          Text(text, style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    if (future == null) return _box(_message('Tidak ada foto bukti'));
    return FutureBuilder<String?>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _box(const Center(child: CircularProgressIndicator(color: AppColors.blackCharcoal)));
        }
        final url = snap.data;
        if (snap.hasError || url == null) return _box(_message('Foto tidak dapat dimuat'));
        return _box(Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _message('Foto tidak dapat dimuat'),
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const Center(child: CircularProgressIndicator(color: AppColors.blackCharcoal)),
        ));
      },
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isLate});
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
      child: Text(isLate ? 'Terlambat' : 'Tepat Waktu', style: AppTypography.labelBold.copyWith(
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
