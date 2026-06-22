import 'package:flutter/foundation.dart';
import '../models/berita_model.dart';
import '../dummy/dummy_berita.dart';

abstract class BeritaRepository extends ChangeNotifier {
  List<BeritaModel> get berita;
  List<BeritaModel> get publishedBerita;
  Future<void> addBerita(BeritaModel item);
  Future<void> updateBerita(BeritaModel item);
  Future<void> deleteBerita(String id);
  Future<void> publishBerita(String id);
}

class DummyBeritaRepository extends BeritaRepository {
  final List<BeritaModel> _berita = List.from(dummyBerita);

  @override
  List<BeritaModel> get berita => List.unmodifiable(_berita);

  @override
  List<BeritaModel> get publishedBerita =>
      _berita.where((b) => !b.isDraft).toList();

  @override
  Future<void> addBerita(BeritaModel item) async {
    _berita.insert(0, item);
    notifyListeners();
  }

  @override
  Future<void> updateBerita(BeritaModel item) async {
    final idx = _berita.indexWhere((b) => b.id == item.id);
    if (idx != -1) {
      _berita[idx] = item;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteBerita(String id) async {
    _berita.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  @override
  Future<void> publishBerita(String id) async {
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
  Future<void> addBerita(BeritaModel item) async {
    // POST /api/berita
    _berita.insert(0, item);
    notifyListeners();
  }

  @override
  Future<void> updateBerita(BeritaModel item) async {
    // PUT /api/berita/${item.id}
    final idx = _berita.indexWhere((b) => b.id == item.id);
    if (idx != -1) {
      _berita[idx] = item;
      notifyListeners();
    }
  }

  @override
  Future<void> deleteBerita(String id) async {
    // DELETE /api/berita/$id
    _berita.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  @override
  Future<void> publishBerita(String id) async {
    // POST /api/berita/$id/publish
    final idx = _berita.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _berita[idx] = _berita[idx].copyWith(isDraft: false, tanggalPublish: DateTime.now());
      notifyListeners();
    }
  }
}

