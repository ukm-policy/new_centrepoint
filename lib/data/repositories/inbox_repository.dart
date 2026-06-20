import 'package:flutter/foundation.dart';
import '../models/inbox_model.dart';
import '../dummy/dummy_inbox.dart';

abstract class InboxRepository extends ChangeNotifier {
  List<NotifModel> get notifications;
  List<PengumumanModel> get pengumuman;
  int get unreadCount;
  void markAsRead(String id);
  void markAllAsRead();
  void addPengumuman(PengumumanModel item);
  void addNotification(NotifModel item);
}

class DummyInboxRepository extends InboxRepository {
  final List<NotifModel> _notifications = List.from(dummyNotifications);
  final List<PengumumanModel> _pengumuman = List.from(dummyPengumuman);

  @override
  List<NotifModel> get notifications => List.unmodifiable(_notifications);
  
  @override
  List<PengumumanModel> get pengumuman => List.unmodifiable(_pengumuman);

  @override
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  @override
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  @override
  void addPengumuman(PengumumanModel item) {
    _pengumuman.insert(0, item);
    notifyListeners();
  }

  @override
  void addNotification(NotifModel item) {
    _notifications.insert(0, item);
    notifyListeners();
  }
}

class ApiInboxRepository extends InboxRepository {
  List<NotifModel> _notifications = [];
  List<PengumumanModel> _pengumuman = [];

  ApiInboxRepository() {
    _loadInbox();
  }

  Future<void> _loadInbox() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _notifications = List.from(dummyNotifications);
    _pengumuman = List.from(dummyPengumuman);
    notifyListeners();
  }

  @override
  List<NotifModel> get notifications => List.unmodifiable(_notifications);
  
  @override
  List<PengumumanModel> get pengumuman => List.unmodifiable(_pengumuman);

  @override
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  void markAsRead(String id) {
    // POST /api/inbox/$id/read
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  @override
  void markAllAsRead() {
    // POST /api/inbox/read-all
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  @override
  void addPengumuman(PengumumanModel item) {
    // POST /api/pengumuman
    _pengumuman.insert(0, item);
    notifyListeners();
  }

  @override
  void addNotification(NotifModel item) {
    // POST /api/notifications
    _notifications.insert(0, item);
    notifyListeners();
  }
}

