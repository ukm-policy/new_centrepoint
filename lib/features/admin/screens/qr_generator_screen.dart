import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../kegiatan/kegiatan_models.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationCtrl = TextEditingController(text: '30');

  String? _selectedKegiatanId;
  bool _generated = false;
  int _countdown = 1800; // 30 minutes in seconds

  @override
  void initState() {
    super.initState();
    if (kKegiatanList.isNotEmpty) {
      _selectedKegiatanId = kKegiatanList.first.id;
    }
  }

  @override
  void dispose() {
    _durationCtrl.dispose();
    super.dispose();
  }

  void _generate() {
    if (!_formKey.currentState!.validate()) return;
    final mins = int.tryParse(_durationCtrl.text) ?? 30;
    setState(() {
      _countdown = mins * 60;
      _generated = true;
    });
  }

  String _formatTime(int totalSecs) {
    final hrs = totalSecs ~/ 3600;
    final mins = (totalSecs % 3600) ~/ 60;
    final secs = totalSecs % 60;
    return '${hrs > 0 ? '${hrs.toString().padLeft(2, '0')}:' : ''}${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final activeKegiatan = kKegiatanList.firstWhere(
      (k) => k.id == _selectedKegiatanId,
      orElse: () => kKegiatanList.first,
    );

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
                Text(
                  'Generator QR',
                  style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginPage),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!_generated) ...[
                  // Configuration form
                  BrutalistCard(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: AppColors.surfaceContainerLowest,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PILIH KEGIATAN', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedKegiatanId,
                          onChanged: (v) => setState(() => _selectedKegiatanId = v),
                          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          items: kKegiatanList.map((k) => DropdownMenuItem(
                            value: k.id,
                            child: Text(k.title, overflow: TextOverflow.ellipsis),
                          )).toList(),
                        ),
                        const SizedBox(height: AppSpacing.stackGap),

                        Text('MASA BERLAKU QR (MENIT)', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _durationCtrl,
                          keyboardType: TextInputType.number,
                          style: AppTypography.bodyMd,
                          decoration: const InputDecoration(hintText: 'Contoh: 30'),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Masa berlaku wajib diisi';
                            final val = int.tryParse(v);
                            if (val == null || val <= 0) return 'Masa berlaku tidak valid';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  BrutalistButton(
                    label: 'GENERATE QR ABSENSI',
                    icon: Icons.qr_code_2_outlined,
                    onPressed: _generate,
                  ),
                ] else ...[
                  // QR display
                  BrutalistCard(
                    padding: const EdgeInsets.all(24),
                    backgroundColor: AppColors.surfaceContainerLowest,
                    child: Column(
                      children: [
                        Text(
                          activeKegiatan.title.toUpperCase(),
                          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scan QR ini untuk melakukan presensi kehadiran.',
                          style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        
                        // Fake QR Code
                        BrutalistCard(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          padding: const EdgeInsets.all(12),
                          backgroundColor: Colors.white,
                          child: Container(
                            width: 200,
                            height: 200,
                            color: Colors.white,
                            child: CustomPaint(
                              painter: _FakeQrPainter(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const MyDivider(color: AppColors.borderSlate),
                        const SizedBox(height: 16),
                        
                        // Countdown
                        Text('SISA WAKTU BERLAKU', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, letterSpacing: 0.8)),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(_countdown),
                          style: AppTypography.displayLgMobile.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  BrutalistButton(
                    label: 'BAGIKAN GAMBAR QR',
                    icon: Icons.share_outlined,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gambar QR berhasil dibagikan!', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
                          backgroundColor: AppColors.blackCharcoal,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(AppSpacing.marginPage),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  BrutalistButton(
                    label: 'BUAT QR BARU',
                    variant: BrutalistButtonVariant.secondary,
                    icon: Icons.refresh_outlined,
                    onPressed: () => setState(() => _generated = false),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FakeQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.blackCharcoal
      ..style = PaintingStyle.fill;

    // Draw the 3 finder patterns (corners)
    _drawFinderPattern(canvas, const Offset(15, 15), 40, paint);
    _drawFinderPattern(canvas, Offset(size.width - 55, 15), 40, paint);
    _drawFinderPattern(canvas, Offset(15, size.height - 55), 40, paint);

    // Draw some random blocks to simulate QR contents
    final r = size.width / 20;
    final points = [
      (6, 6), (7, 6), (8, 6), (12, 6), (13, 6),
      (6, 7), (10, 7), (11, 7), (13, 7),
      (8, 8), (9, 8), (12, 8), (14, 8),
      (5, 9), (7, 9), (10, 9), (11, 9), (12, 9),
      (6, 10), (8, 10), (13, 10), (14, 10),
      (10, 11), (11, 11), (12, 11), (15, 11),
      (5, 12), (6, 12), (9, 12), (13, 12),
      (7, 13), (8, 13), (12, 13), (14, 13),
      (10, 14), (11, 14), (13, 14), (15, 14),
    ];

    for (final p in points) {
      canvas.drawRect(
        Rect.fromLTWH(p.$1 * r, p.$2 * r, r, r),
        paint,
      );
    }
  }

  void _drawFinderPattern(Canvas canvas, Offset offset, double size, Paint paint) {
    final oldStyle = paint.style;

    // Outer box
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 6;
    canvas.drawRect(Rect.fromLTWH(offset.dx, offset.dy, size, size), paint);

    // Inner block
    paint.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(offset.dx + 10, offset.dy + 10, size - 20, size - 20), paint);

    paint.style = oldStyle;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
