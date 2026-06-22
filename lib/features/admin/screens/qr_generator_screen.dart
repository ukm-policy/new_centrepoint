import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/brutalist_button.dart';
import '../../../shared/widgets/brutalist_card.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../data/repositories/kegiatan_repository.dart';
import '../../../data/repositories/qr_session_repository.dart';
import '../../../data/repositories/audit_log_repository.dart';
import '../../../data/repositories/absensi_repository.dart';
import '../../../data/models/qr_session_model.dart';
import '../../../data/models/absensi_model.dart' hide QrSessionModel;

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationCtrl = TextEditingController(text: '30');
  final GlobalKey _qrKey = GlobalKey();

  String? _selectedKegiatanId;
  QrSessionModel? _session;
  bool _loading = false;
  int _remainingSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final kegiatanRepo = context.read<KegiatanRepository>();
    if (kegiatanRepo.kegiatan.isNotEmpty) {
      _selectedKegiatanId = kegiatanRepo.kegiatan.first.id;
    }
    // Fetch QR sessions history on start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QrSessionRepository>().fetchSessions();
    });
  }

  @override
  void dispose() {
    _durationCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(DateTime expiredAt) {
    _timer?.cancel();
    _remainingSeconds = expiredAt.difference(DateTime.now()).inSeconds.clamp(0, double.maxFinite.toInt());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final secs = expiredAt.difference(DateTime.now()).inSeconds;
      if (secs <= 0) {
        _timer?.cancel();
        if (mounted) setState(() => _remainingSeconds = 0);
      } else {
        if (mounted) setState(() => _remainingSeconds = secs);
      }
    });
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKegiatanId == null) return;

    final repo = context.read<QrSessionRepository>();
    final now = DateTime.now();
    final hasActiveSession = repo.sessions.any((sess) =>
        sess.kegiatanId == _selectedKegiatanId &&
        sess.isActive &&
        now.isBefore(sess.expiredAt));

    if (hasActiveSession) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kegiatan ini masih memiliki QR yang aktif! Silakan nonaktifkan terlebih dahulu.',
            style: AppTypography.bodyMd.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.marginPage),
        ),
      );
      return;
    }

    final kegiatanList = context.read<KegiatanRepository>().kegiatan;
    final kegiatan = kegiatanList.firstWhere(
      (k) => k.id == _selectedKegiatanId,
      orElse: () => kegiatanList.first,
    );
    final mins = int.tryParse(_durationCtrl.text) ?? 30;

    setState(() => _loading = true);
    final session = await repo.createSession(
      kegiatanId: kegiatan.id,
      kegiatanJudul: kegiatan.judul,
      durationMinutes: mins,
    );

    if (!mounted) return;
    if (session != null) {
      setState(() {
        _session = session;
        _loading = false;
      });
      _startTimer(session.expiredAt);

      context.read<AuditLogRepository>().logAction(
        aksi: 'Membuat QR absensi untuk: ${kegiatan.judul} (${mins}m)',
        tipe: 'Kegiatan',
        entityId: session.id,
        entityType: 'qr_session',
      );
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat QR session.', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.marginPage),
        ),
      );
    }
  }

  void _selectSession(QrSessionModel session) {
    setState(() {
      _session = session;
    });
    _startTimer(session.expiredAt);
  }

  void _closeView() {
    _timer?.cancel();
    setState(() {
      _session = null;
      _remainingSeconds = 0;
    });
    context.read<QrSessionRepository>().fetchSessions();
  }

  void _deactivate() {
    _timer?.cancel();
    if (_session != null) {
      context.read<QrSessionRepository>().deactivateSession(_session!.id);
    }
    setState(() {
      _session = null;
      _remainingSeconds = 0;
    });
  }

  String _fmtDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final timeStr = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '${d.day} ${months[d.month - 1]} ${d.year} $timeStr';
  }

  String _formatTime(int totalSecs) {
    final hrs = totalSecs ~/ 3600;
    final mins = (totalSecs % 3600) ~/ 60;
    final secs = totalSecs % 60;
    return '${hrs > 0 ? '${hrs.toString().padLeft(2, '0')}:' : ''}${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _shareQr() async {
    try {
      final boundary = _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_${_session!.kegiatanJudul.replaceAll(' ', '_')}.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Scan QR Absensi Kegiatan: ${_session!.kegiatanJudul}',
      );
    } catch (e) {
      debugPrint('Error sharing QR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membagikan gambar QR: $e', style: AppTypography.bodyMd.copyWith(color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildScanList() {
    final absensiRepo = context.watch<AbsensiRepository>();
    final list = absensiRepo.absensi.where((a) =>
        a.kegiatanId == _session!.kegiatanId &&
        a.status == StatusAbsensi.hadir).toList();

    list.sort((a, b) {
      if (a.waktuScan == null && b.waktuScan == null) return 0;
      if (a.waktuScan == null) return 1;
      if (b.waktuScan == null) return -1;
      return b.waktuScan!.compareTo(a.waktuScan!);
    });

    return BrutalistCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SUDAH ABSEN',
                style: AppTypography.labelBold.copyWith(color: AppColors.tertiary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                ),
                child: Text(
                  '${list.length} ORANG',
                  style: AppTypography.labelBold.copyWith(fontSize: 10, color: AppColors.onPrimaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const MyDivider(color: AppColors.borderSlate),
          const SizedBox(height: 12),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Belum ada yang melakukan scan.',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                final scanTimeStr = item.waktuScan != null
                    ? '${item.waktuScan!.hour.toString().padLeft(2, '0')}:${item.waktuScan!.minute.toString().padLeft(2, '0')}'
                    : '--:--';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.memberNama,
                          style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        scanTimeStr,
                        style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final sessionRepo = context.watch<QrSessionRepository>();
    final sessions = sessionRepo.sessions;

    if (sessionRepo.isLoading && sessions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
        ),
        child: Center(
          child: Text(
            'Belum ada histori QR yang di-generate.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final sess = sessions[index];
        final now = DateTime.now();
        final expired = now.isAfter(sess.expiredAt) || !sess.isActive;
        
        final diff = sess.expiredAt.difference(now);
        final remainingStr = diff.isNegative
            ? 'Expired'
            : '${diff.inMinutes}m ${diff.inSeconds % 60}s tersisa';

        final statusColor = expired ? AppColors.surfaceContainerHigh : AppColors.success;
        final statusText = expired ? 'EXPIRED' : 'AKTIF';
        final statusTextColor = expired ? AppColors.tertiary : Colors.white;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BrutalistCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: AppColors.surfaceContainerLowest,
            onTap: () => _selectSession(sess),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sess.kegiatanJudul,
                        style: AppTypography.labelBold.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expired ? 'Dibuat pada ${_fmtDate(sess.createdAt)}' : remainingStr,
                        style: AppTypography.bodyMd.copyWith(
                          fontSize: 12,
                          color: expired ? AppColors.tertiary : AppColors.primary,
                          fontWeight: expired ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                  ),
                  child: Text(
                    statusText,
                    style: AppTypography.labelBold.copyWith(
                      color: statusTextColor,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final kegiatanList = context.watch<KegiatanRepository>().kegiatan;

    if (kegiatanList.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bgGray,
        body: Center(child: Text('Tidak ada kegiatan tersedia.', style: AppTypography.bodyMd)),
      );
    }

    final isExpired = _remainingSeconds <= 0 && _session != null;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginPage, vertical: 8),
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
                Text('Generator QR', style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.marginPage),
          child: _session == null
              ? Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BrutalistCard(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppColors.surfaceContainerLowest,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PILIH KEGIATAN', style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _selectedKegiatanId,
                              onChanged: (v) => setState(() => _selectedKegiatanId = v),
                              style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                              items: kegiatanList.map((k) => DropdownMenuItem(
                                value: k.id,
                                child: Text(
                                  k.judul,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
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
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : BrutalistButton(
                              label: 'GENERATE QR ABSENSI',
                              icon: Icons.qr_code_2_outlined,
                              onPressed: _generate,
                            ),
                      const SizedBox(height: 32),
                      Text(
                        'HISTORI GENERATE QR',
                        style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 12),
                      _buildHistoryList(),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BrutalistCard(
                      padding: const EdgeInsets.all(24),
                      backgroundColor: AppColors.surfaceContainerLowest,
                      child: Column(
                        children: [
                          Text(
                            _session!.kegiatanJudul.toUpperCase(),
                            style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Scan QR ini untuk melakukan presensi kehadiran.',
                            style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          // Real QR Code wrapped in RepaintBoundary for sharing
                          RepaintBoundary(
                            key: _qrKey,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                border: Border.all(color: AppColors.blackCharcoal, width: 2),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _session!.kegiatanJudul.toUpperCase(),
                                    style: AppTypography.headlineSm.copyWith(
                                        color: Colors.black, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  isExpired
                                      ? SizedBox(
                                          width: 200,
                                          height: 200,
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.qr_code_2, size: 48, color: Colors.grey),
                                                const SizedBox(height: 8),
                                                Text('QR KADALUARSA', style: AppTypography.labelBold.copyWith(color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        )
                                      : QrImageView(
                                          data: _session!.id,
                                          version: QrVersions.auto,
                                          size: 200,
                                          backgroundColor: Colors.white,
                                        ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'SCAN UNTUK PRESENSI',
                                    style: AppTypography.labelBold.copyWith(color: Colors.black54, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const MyDivider(color: AppColors.borderSlate),
                          const SizedBox(height: 16),

                          // Countdown
                          Text(
                            'SISA WAKTU BERLAKU',
                            style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, letterSpacing: 0.8),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isExpired ? 'KADALUARSA' : _formatTime(_remainingSeconds),
                            style: AppTypography.displayLgMobile.copyWith(
                              color: isExpired ? AppColors.error : (_remainingSeconds < 60 ? AppColors.error : AppColors.primary),
                              fontWeight: FontWeight.w900,
                            ),
                          ),

                          if (!isExpired) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                border: Border.all(color: AppColors.borderSlate, width: 1),
                              ),
                              child: Text(
                                'Berakhir: ${_session!.expiredAt.hour.toString().padLeft(2,'0')}:${_session!.expiredAt.minute.toString().padLeft(2,'0')}',
                                style: AppTypography.labelBold.copyWith(fontSize: 10, color: AppColors.tertiary),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Scan list (Attendee scan list)
                    _buildScanList(),
                    const SizedBox(height: 24),

                    if (!isExpired && _session!.isActive) ...[
                      BrutalistButton(
                        label: 'BAGIKAN GAMBAR QR',
                        icon: Icons.share,
                        onPressed: _shareQr,
                      ),
                      const SizedBox(height: 12),
                    ],

                    BrutalistButton(
                      label: 'KEMBALI KE FORM',
                      variant: BrutalistButtonVariant.primary,
                      icon: Icons.arrow_back,
                      onPressed: _closeView,
                    ),
                    if (!isExpired && _session!.isActive) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _deactivate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                            border: Border.all(color: AppColors.blackCharcoal, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.blackCharcoal,
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'NONAKTIFKAN QR',
                                style: AppTypography.headlineSm.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.block,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

}
