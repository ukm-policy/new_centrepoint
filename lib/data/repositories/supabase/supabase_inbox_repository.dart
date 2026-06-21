import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/inbox_model.dart';
import '../inbox_repository.dart';

class SupabaseInboxRepository extends InboxRepository {
  final _db = Supabase.instance.client;
  List<NotifModel> _notifications = [];
  List<PengumumanModel> _pengumuman = [];

  SupabaseInboxRepository() {
    _loadInbox();
    // Subscribe to realtime notifikasi and pengumuman
    final uid = _db.auth.currentUser?.id;
    if (uid != null) {
      _db
          .channel('public:notifikasi')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'notifikasi',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: uid,
            ),
            callback: (payload) {
              _loadInbox();
            },
          )
          .subscribe();
    }
    _db
        .channel('public:pengumuman')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'pengumuman',
          callback: (payload) {
            _loadInbox();
          },
        )
        .subscribe();
  }

  Future<void> _loadInbox() async {
    try {
      final uid = _db.auth.currentUser?.id;
      if (uid != null) {
        final notifData = await _db.from('notifikasi').select().eq('user_id', uid).order('waktu', ascending: false);
        _notifications = notifData.map<NotifModel>((json) {
          final id = json['id'] as String;
          final tipeStr = json['tipe'] as String? ?? 'sistem';
          final judul = json['judul'] as String? ?? '';
          final isi = json['isi'] as String? ?? '';
          final waktu = DateTime.tryParse(json['waktu'] ?? '') ?? DateTime.now();
          final isRead = json['is_read'] as bool? ?? false;
          final route = json['route'] as String?;

          final tipe = TipeNotif.values.firstWhere(
            (e) => e.toString().split('.').last == tipeStr,
            orElse: () => TipeNotif.sistem,
          );

          return NotifModel(
            id: id,
            tipe: tipe,
            judul: judul,
            isi: isi,
            waktu: waktu,
            isRead: isRead,
            route: route,
          );
        }).toList();
      }

      final pgData = await _db.from('pengumuman').select().order('tanggal', ascending: false);
      _pengumuman = pgData.map<PengumumanModel>((json) {
        final id = json['id'] as String;
        final kategori = json['kategori'] as String? ?? 'KEGIATAN';
        final judul = json['judul'] as String? ?? '';
        final ringkasan = json['ringkasan'] as String? ?? '';
        final List<String> konten = List<String>.from(json['konten'] as List? ?? []);
        final tanggal = DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now();
        final isNew = json['is_new'] as bool? ?? false;
        final actionLabel = json['action_label'] as String?;
        final actionRoute = json['action_route'] as String?;

        return PengumumanModel(
          id: id,
          kategori: kategori,
          judul: judul,
          ringkasan: ringkasan,
          konten: konten,
          tanggal: tanggal,
          isNew: isNew,
          actionLabel: actionLabel,
          actionRoute: actionRoute,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading inbox: $e');
    }
  }

  @override
  List<NotifModel> get notifications => List.unmodifiable(_notifications);
  
  @override
  List<PengumumanModel> get pengumuman => List.unmodifiable(_pengumuman);

  @override
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  void markAsRead(String id) async {
    try {
      await _db.from('notifikasi').update({'is_read': true}).eq('id', id);
      _loadInbox();
    } catch (e) {
      debugPrint('Error marking notif as read: $e');
    }
  }

  @override
  void markAllAsRead() async {
    try {
      final uid = _db.auth.currentUser?.id;
      if (uid == null) return;
      await _db.from('notifikasi').update({'is_read': true}).eq('user_id', uid);
      _loadInbox();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  @override
  void addPengumuman(PengumumanModel item) async {
    try {
      final user = _db.auth.currentUser;
      await _db.from('pengumuman').insert({
        'kategori': item.kategori,
        'judul': item.judul,
        'ringkasan': item.ringkasan,
        'konten': item.konten,
        'tanggal': item.tanggal.toIso8601String(),
        'is_new': item.isNew,
        'action_label': item.actionLabel,
        'action_route': item.actionRoute,
        'created_by': user?.id,
      });
      _loadInbox();
    } catch (e) {
      debugPrint('Error adding pengumuman: $e');
    }
  }

  @override
  void addNotification(NotifModel item) async {
    try {
      final uid = _db.auth.currentUser?.id;
      if (uid == null) return;
      await _db.from('notifikasi').insert({
        'user_id': uid,
        'tipe': item.tipe.toString().split('.').last,
        'judul': item.judul,
        'isi': item.isi,
        'waktu': item.waktu.toIso8601String(),
        'is_read': item.isRead,
        'route': item.route,
      });
      _loadInbox();
    } catch (e) {
      debugPrint('Error adding notification: $e');
    }
  }
}
