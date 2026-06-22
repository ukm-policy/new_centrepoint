import 'package:flutter/foundation.dart';
import '../models/qr_session_model.dart';

abstract class QrSessionRepository extends ChangeNotifier {
  QrSessionModel? get activeSession;
  bool get isLoading;
  List<QrSessionModel> get sessions;
  Future<List<QrSessionModel>> fetchSessions();
  Future<QrSessionModel?> createSession({
    required String kegiatanId,
    required String kegiatanJudul,
    required int durationMinutes,
  });
  Future<void> deactivateSession(String id);
}
