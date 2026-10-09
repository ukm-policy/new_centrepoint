import 'package:flutter/foundation.dart';
import 'repository_load_state.dart';
import '../../core/errors/app_exception.dart';
import '../models/absensi_model.dart';
import '../dummy/dummy_absensi.dart';

abstract class AbsensiRepository extends ChangeNotifier with RepositoryLoadState {
  List<AbsensiModel> get absensi;
  List<QrSessionModel> get qrSessions;
  Future<void> recordAttendance(AbsensiModel record);
  Future<void> scanQr(String qrContent, String memberId, String memberNama);
  Future<void> createQrSession(QrSessionModel session);
  Future<void> deactivateQrSession(String id);

  /// Absen masuk sekretariat dengan foto bukti.
  Future<void> absenSekret(Uint8List fotoBytes, String fileExt) async =>
      throw const AppException('Absen sekret belum didukung.');

  /// URL sementara untuk menampilkan foto absen sekret (bucket privat).
  Future<String?> fotoSekretUrl(String path) async => null;
}

class DummyAbsensiRepository extends AbsensiRepository {
  final List<AbsensiModel> _absensi = List.from(dummyAbsensi);
  final List<QrSessionModel> _qrSessions = List.from(dummyQrSessions);

  @override
  List<AbsensiModel> get absensi => List.unmodifiable(_absensi);
  
  @override
  List<QrSessionModel> get qrSessions => List.unmodifiable(_qrSessions);

  @override
  Future<void> recordAttendance(AbsensiModel record) async {
    final idx = _absensi.indexWhere(
        (a) => a.memberId == record.memberId && a.kegiatanId == record.kegiatanId);
    if (idx != -1) {
      _absensi[idx] = record;
    } else {
      _absensi.add(record);
    }
    notifyListeners();
  }

  @override
  Future<void> scanQr(String qrContent, String memberId, String memberNama) async {
    final sessionIdx = _qrSessions.indexWhere((s) => s.id == qrContent && s.isActive);
    if (sessionIdx != -1) {
      final session = _qrSessions[sessionIdx];
      final record = AbsensiModel(
        id: 'a-${DateTime.now().millisecondsSinceEpoch}',
        memberId: memberId,
        memberNama: memberNama,
        kegiatanId: session.kegiatanId,
        kegiatanJudul: session.kegiatanJudul,
        tipeKegiatan: 'kegiatan',
        status: StatusAbsensi.hadir,
        waktuScan: DateTime.now(),
      );
      recordAttendance(record);
    }
  }

  @override
  Future<void> createQrSession(QrSessionModel session) async {
    _qrSessions.insert(0, session);
    notifyListeners();
  }

  @override
  Future<void> deactivateQrSession(String id) async {
    final idx = _qrSessions.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _qrSessions[idx] = _qrSessions[idx].copyWith(isActive: false);
      notifyListeners();
    }
  }
}

class ApiAbsensiRepository extends AbsensiRepository {
  List<AbsensiModel> _absensi = [];
  List<QrSessionModel> _qrSessions = [];

  ApiAbsensiRepository() {
    _loadAbsensi();
  }

  Future<void> _loadAbsensi() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _absensi = List.from(dummyAbsensi);
    _qrSessions = List.from(dummyQrSessions);
    notifyListeners();
  }

  @override
  List<AbsensiModel> get absensi => List.unmodifiable(_absensi);
  
  @override
  List<QrSessionModel> get qrSessions => List.unmodifiable(_qrSessions);

  @override
  Future<void> recordAttendance(AbsensiModel record) async {
    // POST /api/absensi
    final idx = _absensi.indexWhere(
        (a) => a.memberId == record.memberId && a.kegiatanId == record.kegiatanId);
    if (idx != -1) {
      _absensi[idx] = record;
    } else {
      _absensi.add(record);
    }
    notifyListeners();
  }

  @override
  Future<void> scanQr(String qrContent, String memberId, String memberNama) async {
    // POST /api/absensi/scan-qr
    final sessionIdx = _qrSessions.indexWhere((s) => s.id == qrContent && s.isActive);
    if (sessionIdx != -1) {
      final session = _qrSessions[sessionIdx];
      final record = AbsensiModel(
        id: 'a-${DateTime.now().millisecondsSinceEpoch}',
        memberId: memberId,
        memberNama: memberNama,
        kegiatanId: session.kegiatanId,
        kegiatanJudul: session.kegiatanJudul,
        tipeKegiatan: 'kegiatan',
        status: StatusAbsensi.hadir,
        waktuScan: DateTime.now(),
      );
      recordAttendance(record);
    }
  }

  @override
  Future<void> createQrSession(QrSessionModel session) async {
    // POST /api/absensi/qr-session
    _qrSessions.insert(0, session);
    notifyListeners();
  }

  @override
  Future<void> deactivateQrSession(String id) async {
    // POST /api/absensi/qr-session/$id/deactivate
    final idx = _qrSessions.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _qrSessions[idx] = _qrSessions[idx].copyWith(isActive: false);
      notifyListeners();
    }
  }
}

