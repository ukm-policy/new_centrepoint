import 'package:flutter/foundation.dart';
import '../models/absensi_model.dart';
import '../dummy/dummy_absensi.dart';

abstract class AbsensiRepository extends ChangeNotifier {
  List<AbsensiModel> get absensi;
  List<QrSessionModel> get qrSessions;
  void recordAttendance(AbsensiModel record);
  void scanQr(String qrContent, String memberId, String memberNama);
  void createQrSession(QrSessionModel session);
  void deactivateQrSession(String id);
}

class DummyAbsensiRepository extends AbsensiRepository {
  final List<AbsensiModel> _absensi = List.from(dummyAbsensi);
  final List<QrSessionModel> _qrSessions = List.from(dummyQrSessions);

  @override
  List<AbsensiModel> get absensi => List.unmodifiable(_absensi);
  
  @override
  List<QrSessionModel> get qrSessions => List.unmodifiable(_qrSessions);

  @override
  void recordAttendance(AbsensiModel record) {
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
  void scanQr(String qrContent, String memberId, String memberNama) {
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
  void createQrSession(QrSessionModel session) {
    _qrSessions.insert(0, session);
    notifyListeners();
  }

  @override
  void deactivateQrSession(String id) {
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
  void recordAttendance(AbsensiModel record) {
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
  void scanQr(String qrContent, String memberId, String memberNama) {
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
  void createQrSession(QrSessionModel session) {
    // POST /api/absensi/qr-session
    _qrSessions.insert(0, session);
    notifyListeners();
  }

  @override
  void deactivateQrSession(String id) {
    // POST /api/absensi/qr-session/$id/deactivate
    final idx = _qrSessions.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _qrSessions[idx] = _qrSessions[idx].copyWith(isActive: false);
      notifyListeners();
    }
  }
}

