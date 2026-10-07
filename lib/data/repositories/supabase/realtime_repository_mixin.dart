import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mengelola channel realtime milik sebuah repository dan membersihkannya
/// saat repository di-dispose (mis. ketika user logout / berganti akun).
mixin RealtimeRepositoryMixin on ChangeNotifier {
  final List<RealtimeChannel> _channels = [];
  bool _disposed = false;

  bool get isDisposed => _disposed;

  /// Panggil [onChange] setiap kali tabel [table] berubah.
  void listenTable(
    String table,
    VoidCallback onChange, {
    PostgresChangeEvent event = PostgresChangeEvent.all,
    PostgresChangeFilter? filter,
  }) {
    if (_disposed) return;
    final channel = Supabase.instance.client
        .channel('public:$table:${identityHashCode(this)}')
        .onPostgresChanges(
          event: event,
          schema: 'public',
          table: table,
          filter: filter,
          callback: (_) {
            if (!_disposed) onChange();
          },
        )
        .subscribe();
    _channels.add(channel);
  }

  @override
  void notifyListeners() {
    // Load async bisa selesai setelah repository di-dispose.
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final channel in _channels) {
      Supabase.instance.client.removeChannel(channel);
    }
    _channels.clear();
    super.dispose();
  }
}
