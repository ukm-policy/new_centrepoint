import 'package:flutter/foundation.dart';
import '../models/rapat_model.dart';
import '../dummy/dummy_rapat.dart';

abstract class RapatRepository extends ChangeNotifier {
  List<RapatModel> get rapat;
  void addRapat(RapatModel item);
  void updateRapat(RapatModel item);
  void updateNotulensi(String id, String notulensi);
}

class DummyRapatRepository extends RapatRepository {
  final List<RapatModel> _rapat = List.from(dummyRapat);

  @override
  List<RapatModel> get rapat => List.unmodifiable(_rapat);

  @override
  void addRapat(RapatModel item) {
    _rapat.insert(0, item);
    notifyListeners();
  }

  @override
  void updateRapat(RapatModel item) {
    final idx = _rapat.indexWhere((r) => r.id == item.id);
    if (idx != -1) {
      _rapat[idx] = item;
      notifyListeners();
    }
  }

  @override
  void updateNotulensi(String id, String notulensi) {
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
  void addRapat(RapatModel item) {
    // POST /api/rapat
    _rapat.insert(0, item);
    notifyListeners();
  }

  @override
  void updateRapat(RapatModel item) {
    // PUT /api/rapat/${item.id}
    final idx = _rapat.indexWhere((r) => r.id == item.id);
    if (idx != -1) {
      _rapat[idx] = item;
      notifyListeners();
    }
  }

  @override
  void updateNotulensi(String id, String notulensi) {
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

