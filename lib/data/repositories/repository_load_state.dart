import 'package:flutter/foundation.dart';
import 'load_error_hub.dart';

/// Status pemuatan data sebuah repository: sedang memuat, error terakhir,
/// dan cara memuat ulang.
mixin RepositoryLoadState on ChangeNotifier {
  int _pendingLoads = 0;
  Object? _loadError;
  bool _loadStateDisposed = false;

  /// true selama ada proses muat data yang berjalan.
  bool get isLoading => _pendingLoads > 0;

  /// Error dari pemuatan terakhir (null = berhasil).
  Object? get loadError => _loadError;

  /// Muat ulang data dari sumbernya.
  Future<void> reload() async {}

  /// Jalankan [load] sambil mencatat status loading & error.
  /// Tidak pernah melempar error — error disimpan di [loadError] dan
  /// dilaporkan ke [LoadErrorHub].
  @protected
  Future<void> trackLoad(Future<void> Function() load) async {
    _pendingLoads++;
    notifyListeners();
    try {
      await load();
      _loadError = null;
      LoadErrorHub.instance.clear(this);
    } catch (e) {
      debugPrint('Load error ($runtimeType): $e');
      _loadError = e;
      if (!_loadStateDisposed) LoadErrorHub.instance.report(this, e);
    } finally {
      _pendingLoads--;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _loadStateDisposed = true;
    LoadErrorHub.instance.clear(this);
    super.dispose();
  }
}
