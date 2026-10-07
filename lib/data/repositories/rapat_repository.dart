import 'package:flutter/foundation.dart';
import 'repository_load_state.dart';
import '../models/rapat_model.dart';
import '../dummy/dummy_rapat.dart';

abstract class RapatRepository extends ChangeNotifier with RepositoryLoadState {
  List<RapatModel> get rapat;
  Future<void> addRapat(RapatModel item);
  Future<void> updateRapat(RapatModel item);
  Future<void> updateNotulensi(String id, String notulensi);
}

class DummyRapatRepository extends RapatRepository {
  final List<RapatModel> _rapat = List.from(dummyRapat);

  @override
  List<RapatModel> get rapat => List.unmodifiable(_rapat);

  @override
  Future<void> addRapat(RapatModel item) async {
    _rapat.insert(0, item);
    notifyListeners();
  }

  @override
  Future<void> updateRapat(RapatModel item) async {
    final idx = _rapat.indexWhere((r) => r.id == item.id);
    if (idx != -1) {
      _rapat[idx] = item;
      notifyListeners();
    }
  }

  @override
  Future<void> updateNotulensi(String id, String notulensi) async {
    final idx = _rapat.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _rapat[idx] = _rapat[idx].copyWith(
        notulensi: notulensi,
        status: RapatStatus.selesai,
      );
      notifyListeners();
    }
  }
}

class ApiRapatRepository extends RapatRepository {
  List<RapatModel> _rapat = [];

  ApiRapatRepository() {
    _loadRapat();
  }

  Future<void> _loadRapat() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _rapat = List.from(dummyRapat);
    notifyListeners();
  }

  @override
  List<RapatModel> get rapat => List.unmodifiable(_rapat);

  @override
  Future<void> addRapat(RapatModel item) async {
    // POST /api/rapat
    _rapat.insert(0, item);
    notifyListeners();
  }

  @override
  Future<void> updateRapat(RapatModel item) async {
    // PUT /api/rapat/${item.id}
    final idx = _rapat.indexWhere((r) => r.id == item.id);
    if (idx != -1) {
      _rapat[idx] = item;
      notifyListeners();
    }
  }

  @override
  Future<void> updateNotulensi(String id, String notulensi) async {
    // POST /api/rapat/$id/notulensi
    final idx = _rapat.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _rapat[idx] = _rapat[idx].copyWith(
        notulensi: notulensi,
        status: RapatStatus.selesai,
      );
      notifyListeners();
    }
  }
}

