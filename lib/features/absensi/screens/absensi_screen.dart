import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../core/session/app_session.dart';
import '../../../data/repositories/absensi_repository.dart';
import '../../../data/models/absensi_model.dart';

class AbsensiScreen extends StatefulWidget {
  const AbsensiScreen({super.key});

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanAnim;

  // Foto bukti sekret (simulasi: null = belum ambil foto)
  bool _hasFoto = false;
  bool _sekretSubmitted = false;

  bool _isProcessingScan = false;

  @override
  void initState() {
    super.initState();
    _scanAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _scanAnim.dispose();
    super.dispose();
  }

  void _ambilFoto() {
    setState(() => _hasFoto = true);
  }

  void _submitSekret() {
    if (!_hasFoto) return;
    setState(() => _sekretSubmitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Absen masuk sekret berhasil dicatat!',
          style: AppTypography.bodyMd.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          side: const BorderSide(color: AppColors.blackCharcoal, width: 2),
        ),
      ),
    );
  }

  void _handleScan(String qrContent) async {
    if (_isProcessingScan) return;
    _isProcessingScan = true;

    try {
      final uid = AppSession.currentUser.id;
      final name = AppSession.nama;
      
      context.read<AbsensiRepository>().scanQr(qrContent, uid, name);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mengirim data absensi...', style: AppTypography.bodyMd),
          backgroundColor: AppColors.blackCharcoal,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scan: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      _isProcessingScan = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDemisioner = AppSession.kodeRole == 'demisioner';
    final uid = AppSession.currentUser.id;

    final absensiRepo = context.watch<AbsensiRepository>();
    final myAbsensi = absensiRepo.absensi.where((a) => a.memberId == uid).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: FloatingAppBar(title: 'Absensi')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginPage, AppSpacing.stackGap,
            AppSpacing.marginPage, AppSpacing.stackGap,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              isDemisioner
                  ? [
                      BrutalistCard(
                        backgroundColor: AppColors.surfaceContainerLowest,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.blackCharcoal, width: 2),
                                boxShadow: const [AppColors.hardShadowSm],
                              ),
                              child: const Icon(
                                Icons.no_accounts_outlined,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Status Absensi Tidak Aktif',
                              textAlign: TextAlign.center,
                              style: AppTypography.headlineSm.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.blackCharcoal,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Anggota Demisioner tidak memiliki kewajiban absensi kegiatan organisasi.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.tertiary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]
                  : [
                      // ── Bagian 1: Absen Kegiatan ─────────────────────────────────
                      _SectionLabel(label: '01', title: 'Absen Kegiatan'),
                      const SizedBox(height: 12),

                      // Scanner card
                      BrutalistCard(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 22),
                              const SizedBox(width: 8),
                              Text('Scan QR', style: AppTypography.headlineSm),
                              const Spacer(),
                              _ActiveBadge(),
                            ]),
                            const SizedBox(height: 16),
                            AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.blackCharcoal,
                                  borderRadius: BorderRadius.circular(AppSpacing.radius),
                                  border: Border.all(color: AppColors.blackCharcoal, width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(AppSpacing.radius - 2),
                                  child: Stack(
                                    children: [
                                      MobileScanner(
                                        onDetect: (capture) {
                                          final List<Barcode> barcodes = capture.barcodes;
                                          if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                                            _handleScan(barcodes.first.rawValue!);
                                          }
                                        },
                                      ),
                                      AnimatedBuilder(
                                        animation: _scanAnim,
                                        builder: (context, child) => Positioned(
                                          top: _scanAnim.value *
                                              (MediaQuery.of(context).size.width -
                                                  AppSpacing.marginPage * 2 -
                                                  (AppSpacing.innerPadding + 4) * 2),
                                          left: 0, right: 0,
                                          child: Container(
                                            height: 2,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.primary.withValues(alpha: 0.6),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      ..._cornerMarkers(),
                                      Positioned(
                                        bottom: 16, left: 0, right: 0,
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: AppColors.blackCharcoal.withValues(alpha: 0.8),
                                              borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                                              border: Border.all(color: AppColors.tertiary, width: 1),
                                            ),
                                            child: Text(
                                              'Arahkan kamera ke QR Code Acara',
                                              style: AppTypography.labelBold.copyWith(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.stackGap),

                      // Status hari ini
                      _InfoCard(
                        title: 'Status Hari Ini',
                        child: myAbsensi.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text(
                                    'Belum ada absensi terdaftar.',
                                    style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                                  ),
                                ),
                              )
                            : Column(
                                children: myAbsensi.map((a) {
                                  final formattedTime = a.waktuScan != null
                                      ? "${a.waktuScan!.hour.toString().padLeft(2, '0')}.${a.waktuScan!.minute.toString().padLeft(2, '0')} WIB"
                                      : "Belum Absen";
                                  return Column(
                                    children: [
                                      _StatusRow(
                                        icon: a.tipeKegiatan == 'rapat' ? Icons.event : Icons.event_available,
                                        title: a.kegiatanJudul,
                                        subtitle: "${a.tipeKegiatan.toUpperCase()} • $formattedTime",
                                        status: a.status == StatusAbsensi.hadir ? 'Hadir' : (a.status == StatusAbsensi.belumAbsen ? 'Belum' : a.status.toString().split('.').last.toUpperCase()),
                                        isGood: a.status == StatusAbsensi.hadir,
                                      ),
                                      if (a != myAbsensi.last) ...[
                                        const SizedBox(height: 8),
                                        const MyDivider(color: AppColors.borderSlate, height: 8),
                                        const SizedBox(height: 8),
                                      ],
                                    ],
                                  );
                                }).toList(),
                              ),
                      ),

                      // ── Bagian 2: Absen Masuk Sekret ─────────────────────────────
                      const SizedBox(height: AppSpacing.stackGap),
                      const MyDivider(color: AppColors.blackCharcoal),
                      const SizedBox(height: AppSpacing.stackGap),

                      _SectionLabel(label: '02', title: 'Absen Masuk Sekret'),
                      const SizedBox(height: 12),

                      _SekretCard(
                        hasFoto: _hasFoto,
                        submitted: _sekretSubmitted,
                        onAmbilFoto: _ambilFoto,
                        onUlangFoto: () => setState(() {
                          _hasFoto = false;
                          _sekretSubmitted = false;
                        }),
                        onSubmit: _submitSekret,
                        onLihatRiwayat: () => context.push('/absensi/riwayat-sekret'),
                      ),
                    ]),
          ),
        ),
      ],
    );
  }

  List<Widget> _cornerMarkers() => [
    Positioned(top: 16, left: 16, child: _CornerMark(top: true, left: true)),
    Positioned(top: 16, right: 16, child: _CornerMark(top: true, left: false)),
    Positioned(bottom: 16, left: 16, child: _CornerMark(top: false, left: true)),
    Positioned(bottom: 16, right: 16, child: _CornerMark(top: false, left: false)),
  ];
}

// ── Sekret Card ───────────────────────────────────────────────────────────────

class _SekretCard extends StatelessWidget {
  const _SekretCard({
    required this.hasFoto,
    required this.submitted,
    required this.onAmbilFoto,
    required this.onUlangFoto,
    required this.onSubmit,
    required this.onLihatRiwayat,
  });

  final bool hasFoto, submitted;
  final VoidCallback onAmbilFoto, onUlangFoto, onSubmit, onLihatRiwayat;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
        boxShadow: const [AppColors.hardShadow],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(children: [
            const Icon(Icons.home_work_outlined, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Absen Masuk Sekret', style: AppTypography.headlineSm),
            const Spacer(),
            GestureDetector(
              onTap: onLihatRiwayat,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                  border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.history, size: 14, color: AppColors.tertiary),
                  const SizedBox(width: 4),
                  Text('Riwayat', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: MyDivider(color: AppColors.borderSlate, height: 12),
        ),
        const SizedBox(height: 12),

        // Profil
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Ambil foto sebagai bukti keberadaan kamu di sekretariat.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
          ),
        ),
        const SizedBox(height: 16),

        // Area foto
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: submitted
              ? _FotoSubmitted()
              : hasFoto
                  ? _FotoPreview(onUlang: onUlangFoto)
                  : _FotoPlaceholder(onAmbil: onAmbilFoto),
        ),
        const SizedBox(height: 16),

        // Info waktu
        if (!submitted)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Icon(Icons.access_time, size: 14, color: AppColors.tertiary),
              const SizedBox(width: 6),
              Text(
                'Waktu akan dicatat otomatis saat submit',
                style: AppTypography.labelBold.copyWith(color: AppColors.tertiary),
              ),
            ]),
          ),
        if (!submitted) const SizedBox(height: 16),

        // Submit button
        if (!submitted)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: BrutalistButton(
              label: 'ABSEN MASUK SEKRET',
              icon: Icons.check_circle_outline,
              onPressed: hasFoto ? onSubmit : null,
            ),
          ),

        if (submitted)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: GestureDetector(
              onTap: onLihatRiwayat,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Lihat Riwayat Masuk Sekret',
                  style: AppTypography.labelBold.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  )),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
              ]),
            ),
          ),
      ]),
    );
  }
}

class _FotoPlaceholder extends StatelessWidget {
  const _FotoPlaceholder({required this.onAmbil});
  final VoidCallback onAmbil;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAmbil,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(
            color: AppColors.blackCharcoal,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.blackCharcoal, width: 2),
              boxShadow: const [AppColors.hardShadowSm],
            ),
            child: const Icon(Icons.camera_alt, size: 36, color: AppColors.onPrimaryContainer),
          ),
          const SizedBox(height: 12),
          Text('Tap untuk ambil foto',
            style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Pastikan sekretariat terlihat jelas',
            style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
        ]),
      ),
    );
  }
}

class _FotoPreview extends StatelessWidget {
  const _FotoPreview({required this.onUlang});
  final VoidCallback onUlang;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(color: AppColors.secondary, width: 2.5),
            boxShadow: const [AppColors.hardShadow],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Simulasi foto (gradient sebagai placeholder)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radius - 2),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D3436), Color(0xFF636E72)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.home_work, size: 48, color: Colors.white54),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text('foto_sekret_preview.jpg',
                    style: AppTypography.labelBold.copyWith(color: Colors.white70)),
                ),
              ]),
            ],
          ),
        ),
        // Checkmark overlay
        Positioned(
          top: 10, right: 10,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 16, color: Colors.white),
          ),
        ),
        // Ulang foto button
        Positioned(
          bottom: 10, right: 10,
          child: GestureDetector(
            onTap: onUlang,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                boxShadow: const [AppColors.hardShadowSm],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.refresh, size: 14),
                const SizedBox(width: 4),
                Text('Ulang', style: AppTypography.labelBold),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class _FotoSubmitted extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
        boxShadow: const [AppColors.hardShadowSm],
      ),
      child: Column(children: [
        const Icon(Icons.check_circle, size: 48, color: AppColors.secondary),
        const SizedBox(height: 10),
        Text('Absen Berhasil!',
          style: AppTypography.headlineSm.copyWith(color: AppColors.secondary)),
        const SizedBox(height: 4),
        Text(
          'Kehadiran di sekretariat\ntelah tercatat pada ${_nowTime()}',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSecondaryContainer),
        ),
      ]),
    );
  }

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h.$m WIB';
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.title});
  final String label, title;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: const [AppColors.hardShadowSm],
        ),
        alignment: Alignment.center,
        child: Text(label,
          style: AppTypography.labelBold.copyWith(color: AppColors.onPrimaryContainer)),
      ),
      const SizedBox(width: 10),
      Text(title, style: AppTypography.headlineMd.copyWith(fontWeight: FontWeight.w800)),
    ]);
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _CornerMark extends StatelessWidget {
  const _CornerMark({required this.top, required this.left});
  final bool top, left;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28, height: 28,
      child: CustomPaint(painter: _CornerPainter(top: top, left: left)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.top, required this.left});
  final bool top, left;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    canvas.drawLine(Offset(x, y), Offset(x + (left ? 1 : -1) * size.width * 0.6, y), p);
    canvas.drawLine(Offset(x, y), Offset(x, y + (top ? 1 : -1) * size.height * 0.6), p);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}

class _ActiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 8, height: 8,
          decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('Active', style: AppTypography.labelBold.copyWith(color: AppColors.onSecondaryContainer)),
      ]),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});
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

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon, required this.title,
    required this.subtitle, required this.status, required this.isGood,
  });
  final IconData icon;
  final String title, subtitle, status;
  final bool isGood;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
        ),
        child: Icon(icon, size: 20, color: AppColors.tertiary),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis),
        Text(subtitle, style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isGood ? AppColors.secondaryContainer : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
        ),
        child: Text(status, style: AppTypography.labelBold.copyWith(
          color: isGood ? AppColors.onSecondaryContainer : AppColors.tertiary)),
      ),
    ]);
  }
}
