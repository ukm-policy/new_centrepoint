import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/absensi_model.dart';
import '../absensi_repository.dart';

class SupabaseAbsensiRepository extends AbsensiRepository {
  final _db = Supabase.instance.client;
  List<AbsensiModel> _absensi = [];
  List<QrSessionModel> _qrSessions = [];

  SupabaseAbsensiRepository() {
    _loadAbsensi();
    // Setup subscription
    _db
        .channel('public:absensi')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'absensi',
          callback: (payload) {
            _loadAbsensi();
          },
        )
        .subscribe();
    _db
        .channel('public:qr_session')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'qr_session',
          callback: (payload) {
            _loadAbsensi();
          },
        )
        .subscribe();
  }

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

        final status = StatusAbsensi.values.firstWhere(
          (e) => e.toString().split('.').last == statusStr,
          orElse: () => StatusAbsensi.belumAbsen,
        );

        return AbsensiModel(
          id: id,
          memberId: memberId,
          memberNama: memberNama,
          kegiatanId: kegiatanId,
          kegiatanJudul: titles[kegiatanId] ?? 'Kegiatan / Rapat',
          tipeKegiatan: tipe,
          status: status,
          waktuScan: waktuScan,
          keterangan: keterangan,
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
    }
  }

  @override
  List<AbsensiModel> get absensi => List.unmodifiable(_absensi);
  
  @override
  List<QrSessionModel> get qrSessions => List.unmodifiable(_qrSessions);

  @override
  void recordAttendance(AbsensiModel record) async {
    try {
      await _db.from('absensi').upsert({
        'member_id': record.memberId,
        'kegiatan_id': record.kegiatanId,
        'tipe_kegiatan': record.tipeKegiatan,
        'status': record.status.toString().split('.').last,
        'waktu_scan': record.waktuScan?.toIso8601String(),
        'keterangan': record.keterangan,
      }, onConflict: 'member_id, kegiatan_id, tipe_kegiatan');
      _loadAbsensi();
    } catch (e) {
      debugPrint('Error recording attendance: $e');
    }
  }

  @override
  void scanQr(String qrContent, String memberId, String memberNama) async {
    try {
      // Find valid active session
      final sessionData = await _db.from('qr_session').select().eq('id', qrContent).maybeSingle();
      if (sessionData == null) return;

      final isActive = sessionData['is_active'] as bool? ?? false;
      final exp = DateTime.tryParse(sessionData['expired_at'] ?? '') ?? DateTime.now();

      if (isActive && exp.isAfter(DateTime.now())) {
        final kid = sessionData['kegiatan_id'] as String;
        final tipe = sessionData['tipe_kegiatan'] as String? ?? 'kegiatan';

        await _db.from('absensi').upsert({
          'member_id': memberId,
          'kegiatan_id': kid,
          'tipe_kegiatan': tipe,
          'status': 'hadir',
          'waktu_scan': DateTime.now().toIso8601String(),
        }, onConflict: 'member_id, kegiatan_id, tipe_kegiatan');

        _loadAbsensi();
      }
    } catch (e) {
      debugPrint('Error scanning QR: $e');
    }
  }

  @override
  void createQrSession(QrSessionModel session) async {
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
      _loadAbsensi();
    } catch (e) {
      debugPrint('Error creating QR session: $e');
    }
  }

  @override
  void deactivateQrSession(String id) async {
    try {
      await _db.from('qr_session').update({
        'is_active': false,
      }).eq('id', id);
      _loadAbsensi();
    } catch (e) {
      debugPrint('Error deactivating QR session: $e');
    }
  }
}
