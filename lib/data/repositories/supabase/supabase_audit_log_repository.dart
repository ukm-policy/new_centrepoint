import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/audit_log_model.dart';
import '../audit_log_repository.dart';

class SupabaseAuditLogRepository extends AuditLogRepository {
  final _db = Supabase.instance.client;
  List<AuditLogModel> _logs = [];
  bool _isLoading = false;
  String? _adminId;
  String _adminNama = 'Admin';

  SupabaseAuditLogRepository() {
    _init();
  }

  Future<void> _init() async {
    final uid = _db.auth.currentUser?.id;
    if (uid != null) {
      _adminId = uid;
      try {
        final profile = await _db.from('profiles').select('nama').eq('id', uid).single();
        _adminNama = profile['nama'] as String? ?? 'Admin';
      } catch (_) {}
    }
    await _loadLogs();
    _db
        .channel('public:audit_log')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'audit_log',
          callback: (_) => _loadLogs(),
        )
        .subscribe();
  }

  Future<void> _loadLogs() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _db
          .from('audit_log')
          .select()
          .order('created_at', ascending: false)
          .limit(200);
      _logs = data.map<AuditLogModel>((json) => AuditLogModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading audit logs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  List<AuditLogModel> get logs => List.unmodifiable(_logs);

  @override
  bool get isLoading => _isLoading;

  @override
  Future<void> logAction({
    required String aksi,
    required String tipe,
    String? entityId,
    String? entityType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _db.from('audit_log').insert({
        'admin_id': _adminId,
        'admin_nama': _adminNama,
        'aksi': aksi,
        'tipe': tipe,
        'entity_id': entityId,
        'entity_type': entityType,
        'metadata': metadata,
      });
    } catch (e) {
      debugPrint('Error logging action: $e');
    }
  }
}
