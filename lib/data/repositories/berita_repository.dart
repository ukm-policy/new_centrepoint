import 'package:flutter/foundation.dart';
import '../models/berita_model.dart';
import '../dummy/dummy_berita.dart';

abstract class BeritaRepository extends ChangeNotifier {
  List<BeritaModel> get berita;
  List<BeritaModel> get publishedBerita;
  void addBerita(BeritaModel item);
  void updateBerita(BeritaModel item);
  void deleteBerita(String id);
  void publishBerita(String id);
}

class DummyBeritaRepository extends BeritaRepository {
  final List<BeritaModel> _berita = List.from(dummyBerita);

  @override
  List<BeritaModel> get berita => List.unmodifiable(_berita);

  @override
  List<BeritaModel> get publishedBerita =>
      _berita.where((b) => !b.isDraft).toList();

  @override
  void addBerita(BeritaModel item) {
    _berita.insert(0, item);
    notifyListeners();
  }

  @override
  void updateBerita(BeritaModel item) {
    final idx = _berita.indexWhere((b) => b.id == item.id);
    if (idx != -1) {
      _berita[idx] = item;
      notifyListeners();
    }
  }

  @override
  void deleteBerita(String id) {
    _berita.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  @override
  void publishBerita(String id) {
    final idx = _berita.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _berita[idx] = _berita[idx].copyWith(isDraft: false, tanggalPublish: DateTime.now());
      notifyListeners();
    }
  }
}

class ApiBeritaRepository extends BeritaRepository {
  List<BeritaModel> _berita = [];

  ApiBeritaRepository() {
    _loadBerita();
  }

  Future<void> _loadBerita() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _berita = List.from(dummyBerita);
    notifyListeners();
  }

  @override
  List<BeritaModel> get berita => List.unmodifiable(_berita);

  @override
  List<BeritaModel> get publishedBerita =>
      _berita.where((b) => !b.isDraft).toList();

  @override
  void addBerita(BeritaModel item) {
    // POST /api/berita
    _berita.insert(0, item);
    notifyListeners();
  }

  @override
  void updateBerita(BeritaModel item) {
    // PUT /api/berita/${item.id}
    final idx = _berita.indexWhere((b) => b.id == item.id);
    if (idx != -1) {
      _berita[idx] = item;
      notifyListeners();
    }
  }

  @override
  void deleteBerita(String id) {
    // DELETE /api/berita/$id
    _berita.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  @override
  void publishBerita(String id) {
    // POST /api/berita/$id/publish
    final idx = _berita.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _berita[idx] = _berita[idx].copyWith(isDraft: false, tanggalPublish: DateTime.now());
      notifyListeners();
    }
  }
}

