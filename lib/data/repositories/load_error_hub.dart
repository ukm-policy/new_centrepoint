import 'dart:async';

import 'package:flutter/foundation.dart';
import 'repository_load_state.dart';

/// Kumpulan repository yang pemuatan datanya sedang gagal.
/// Dipakai untuk menampilkan banner error global + tombol "Coba lagi".
class LoadErrorHub extends ChangeNotifier {
  LoadErrorHub._();
  static final LoadErrorHub instance = LoadErrorHub._();

  final Map<RepositoryLoadState, Object> _errors = {};

  bool get hasError => _errors.isNotEmpty;

  /// Error terakhir yang tercatat (untuk ditampilkan di banner).
  Object? get latestError => _errors.isEmpty ? null : _errors.values.last;

  void report(RepositoryLoadState repo, Object error) {
    _errors.remove(repo);
    _errors[repo] = error;
    _notifyLater();
  }

  void clear(RepositoryLoadState repo) {
    if (_errors.remove(repo) != null) _notifyLater();
  }

  /// Muat ulang semua repository yang gagal.
  Future<void> retryAll() async {
    final failed = _errors.keys.toList();
    await Future.wait(failed.map((repo) => repo.reload()));
  }

  // Bisa dipanggil saat widget tree terkunci (mis. dispose provider),
  // jadi notifikasi ditunda ke microtask berikutnya.
  void _notifyLater() => scheduleMicrotask(notifyListeners);
}
