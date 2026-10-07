import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'realtime_repository_mixin.dart';
import '../../../core/errors/app_exception.dart';
import '../../models/absensi_model.dart';
import '../absensi_repository.dart';

final _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

class SupabaseAbsensiRepository extends AbsensiRepository with RealtimeRepositoryMixin {
  final _db = Supabase.instance.client;
  List<AbsensiModel> _absensi = [];
  List<QrSessionModel> _qrSessions = [];

  SupabaseAbsensiRepository() {
    reload();
    // Setup subscription
    listenTable('absensi', reload);
    listenTable('qr_session', reload);
  }

  @override
  Future<void> reload() => trackLoad(_loadAbsensi);

  Future<void> _loadAbsensi() async {
    try {
      // 1. Fetch kegiatan and rapat map for titles
      final kegData = await _db.from('kegiatan').select('id, judul');
      final rapData = await _db.from('rapat').select('id, judul');
      final Map<String, String> titles = {};
      for (final k in kegData) {
        titles[k['id'] as String] = k['judul'] as String? ?? '';
      }
      for (final r in rapData) {
        titles[r['id'] as String] = r['judul'] as String? ?? '';
      }

      // 2. Fetch absensi records
      final data = await _db.from('absensi').select('*, profiles(nama)');
      _absensi = data.map<AbsensiModel>((json) {
        final id = json['id'] as String;
        final memberId = json['member_id'] as String? ?? '';
        final profile = json['profiles'] as Map<String, dynamic>?;
        final memberNama = profile?['nama'] as String? ?? 'Anggota';
        final kegiatanId = json['kegiatan_id'] as String? ?? '';
        final tipe = json['tipe_kegiatan'] as String? ?? 'kegiatan';
        final statusStr = json['status'] as String? ?? 'belumAbsen';
        final waktuScan = json['waktu_scan'] != null ? DateTime.tryParse(json['waktu_scan'] as String) : null;
        final keterangan = json['keterangan'] as String?;
        final fotoUrl = json['foto_url'] as String?;

        final status = StatusAbsensi.values.firstWhere(
          (e) => e.toString().split('.').last == statusStr,
          orElse: () => StatusAbsensi.belumAbsen,
        );

        return AbsensiModel(
          id: id,
          memberId: memberId,
          memberNama: memberNama,
          kegiatanId: kegiatanId,
          kegiatanJudul: tipe == 'sekret'
              ? 'Absen Sekretariat'
              : titles[kegiatanId] ?? 'Kegiatan / Rapat',
          tipeKegiatan: tipe,
          status: status,
          waktuScan: waktuScan,
          keterangan: keterangan,
          fotoUrl: fotoUrl,
        );
      }).toList();

      // 3. Fetch QR Sessions
      final qrData = await _db.from('qr_session').select().order('created_at', ascending: false);
      _qrSessions = qrData.map<QrSessionModel>((json) {
        final id = json['id'] as String;
        final kid = json['kegiatan_id'] as String? ?? '';
        final title = json['kegiatan_judul'] as String? ?? '';
        final tgl = DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now();
        final exp = DateTime.tryParse(json['expired_at'] ?? '') ?? DateTime.now();
        final active = json['is_active'] as bool? ?? false;

        return QrSessionModel(
          id: id,
          kegiatanId: kid,
          kegiatanJudul: title,
          tanggal: tgl,
          expiredAt: exp,
          isActive: active && exp.isAfter(DateTime.now()),
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading absensi: $e');
      rethrow;
    }
  }

  @override
  List<AbsensiModel> get absensi => List.unmodifiable(_absensi);
  
  @override
  List<QrSessionModel> get qrSessions => List.unmodifiable(_qrSessions);

  @override
  Future<void> recordAttendance(AbsensiModel record) async {
    try {
      await _db.from('absensi').upsert({
        'member_id': record.memberId,
        'kegiatan_id': record.kegiatanId,
        'tipe_kegiatan': record.tipeKegiatan,
        'status': record.status.toString().split('.').last,
        'waktu_scan': record.waktuScan?.toIso8601String(),
        'keterangan': record.keterangan,
      }, onConflict: 'member_id, kegiatan_id, tipe_kegiatan');
      reload();
    } catch (e) {
      debugPrint('Error recording attendance: $e');
      rethrow;
    }
  }

  @override
  Future<void> scanQr(String qrContent, String memberId, String memberNama) async {
    try {
      final sessionId = qrContent.trim();
      if (!_uuidPattern.hasMatch(sessionId)) {
        throw const AppException('QR Code tidak dikenali. Pastikan Anda memindai QR absensi resmi.');
      }

      // Find valid active session
      final sessionData = await _db.from('qr_session').select().eq('id', sessionId).maybeSingle();
      if (sessionData == null) {
        throw const AppException('Sesi absensi tidak ditemukan.');
      }

      final isActive = sessionData['is_active'] as bool? ?? false;
      final exp = DateTime.tryParse(sessionData['expired_at'] ?? '') ?? DateTime.now();
      if (!isActive || !exp.isAfter(DateTime.now())) {
        throw const AppException('QR Code sudah kedaluwarsa atau dinonaktifkan.');
      }

      final kid = sessionData['kegiatan_id'] as String?;
      if (kid == null) {
        throw const AppException('Sesi absensi tidak terhubung ke kegiatan.');
      }
      final tipe = sessionData['tipe_kegiatan'] as String? ?? 'kegiatan';

      await _db.from('absensi').upsert({
        'member_id': memberId,
        'kegiatan_id': kid,
        'tipe_kegiatan': tipe,
        'status': 'hadir',
        'waktu_scan': DateTime.now().toIso8601String(),
      }, onConflict: 'member_id, kegiatan_id, tipe_kegiatan');

      reload();
    } catch (e) {
      debugPrint('Error scanning QR: $e');
      rethrow;
    }
  }

  @override
  Future<void> createQrSession(QrSessionModel session) async {
    try {
      final user = _db.auth.currentUser;
      await _db.from('qr_session').insert({
        'id': session.id,
        'kegiatan_id': session.kegiatanId,
        'kegiatan_judul': session.kegiatanJudul,
        'tanggal': session.tanggal.toIso8601String().substring(0, 10),
        'expired_at': session.expiredAt.toIso8601String(),
        'is_active': session.isActive,
        'created_by': user?.id,
      });
      reload();
    } catch (e) {
      debugPrint('Error creating QR session: $e');
      rethrow;
    }
  }

  @override
  Future<void> deactivateQrSession(String id) async {
    try {
      await _db.from('qr_session').update({
        'is_active': false,
      }).eq('id', id);
      reload();
    } catch (e) {
      debugPrint('Error deactivating QR session: $e');
      rethrow;
    }
  }

  static const _sekretBucket = 'absensi_sekret';

  @override
  Future<void> absenSekret(Uint8List fotoBytes, String fileExt) async {
    try {
      final user = _db.auth.currentUser;
      if (user == null) {
        throw const AppException('Sesi berakhir. Silakan login kembali.');
      }
      final ext = fileExt.toLowerCase();
      final now = DateTime.now();
      final path = '${user.id}/${now.millisecondsSinceEpoch}.$ext';

      await _db.storage.from(_sekretBucket).uploadBinary(
            path,
            fotoBytes,
            fileOptions: FileOptions(contentType: 'image/${ext == 'jpg' ? 'jpeg' : ext}'),
          );

      await _db.from('absensi').insert({
        'member_id': user.id,
        'kegiatan_id': null,
        'tipe_kegiatan': 'sekret',
        'status': 'hadir',
        'waktu_scan': now.toIso8601String(),
        'foto_url': path,
      });
      reload();
    } on StorageException catch (e) {
      debugPrint('Error absen sekret (storage): $e');
      if (e.statusCode == '404' || e.message.toLowerCase().contains('bucket not found')) {
        throw const AppException(
          'Penyimpanan foto sekret belum disiapkan. Hubungi admin untuk menjalankan migrasi absensi_sekret.',
        );
      }
      rethrow;
    } on PostgrestException catch (e) {
      debugPrint('Error absen sekret: $e');
      if (e.code == '42703' || e.code == 'PGRST204' || e.code == '23502') {
        throw const AppException(
          'Database belum mendukung absen sekret. Hubungi admin untuk menjalankan migrasi absensi_sekret.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<String?> fotoSekretUrl(String path) async {
    if (path.startsWith('http')) return path;
    return _db.storage.from(_sekretBucket).createSignedUrl(path, 60 * 60);
  }
}
