import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/qr_session_model.dart';
import '../qr_session_repository.dart';

class SupabaseQrSessionRepository extends QrSessionRepository {
  final _db = Supabase.instance.client;
  QrSessionModel? _activeSession;
  List<QrSessionModel> _sessions = [];
  bool _isLoading = false;

  @override
  QrSessionModel? get activeSession => _activeSession;

  @override
  List<QrSessionModel> get sessions => _sessions;

  @override
  bool get isLoading => _isLoading;

  @override
  Future<List<QrSessionModel>> fetchSessions() async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _db
          .from('qr_session')
          .select()
          .order('created_at', ascending: false);
      _sessions = res.map<QrSessionModel>((json) => QrSessionModel.fromJson(json)).toList();
      return _sessions;
    } catch (e) {
      debugPrint('Error fetching QR sessions: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<QrSessionModel?> createSession({
    required String kegiatanId,
    required String kegiatanJudul,
    required int durationMinutes,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final uid = _db.auth.currentUser?.id;
      final now = DateTime.now();
      final expiredAt = now.add(Duration(minutes: durationMinutes));

      final res = await _db.from('qr_session').insert({
        'kegiatan_id': kegiatanId,
        'kegiatan_judul': kegiatanJudul,
        'tanggal': now.toIso8601String().substring(0, 10),
        'expired_at': expiredAt.toIso8601String(),
        'created_by': uid,
        'tipe_kegiatan': 'kegiatan',
        'is_active': true,
      }).select().single();

      _activeSession = QrSessionModel.fromJson(res);
      
      // Refresh list in background
      _db.from('qr_session')
          .select()
          .order('created_at', ascending: false)
          .then((data) {
            _sessions = data.map<QrSessionModel>((json) => QrSessionModel.fromJson(json)).toList();
            notifyListeners();
          });

      return _activeSession;
    } catch (e) {
      debugPrint('Error creating QR session: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  Future<void> deactivateSession(String id) async {
    try {
      await _db.from('qr_session').update({'is_active': false}).eq('id', id);
      if (_activeSession?.id == id) {
        _activeSession = null;
      }
      
      // Update in local sessions list
      final idx = _sessions.indexWhere((s) => s.id == id);
      if (idx != -1) {
        final item = _sessions[idx];
        _sessions[idx] = QrSessionModel(
          id: item.id,
          kegiatanId: item.kegiatanId,
          kegiatanJudul: item.kegiatanJudul,
          tanggal: item.tanggal,
          expiredAt: item.expiredAt,
          createdBy: item.createdBy,
          tipeKegiatan: item.tipeKegiatan,
          isActive: false,
          createdAt: item.createdAt,
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error deactivating QR session: $e');
    }
  }
}
