import 'package:flutter/foundation.dart';
import '../models/audit_log_model.dart';

abstract class AuditLogRepository extends ChangeNotifier {
  List<AuditLogModel> get logs;
  bool get isLoading;
  Future<void> logAction({
    required String aksi,
    required String tipe,
    String? entityId,
    String? entityType,
    Map<String, dynamic>? metadata,
  });
}
