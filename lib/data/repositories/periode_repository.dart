import 'package:flutter/foundation.dart';
import '../models/periode_model.dart';
import '../dummy/dummy_periode.dart';

abstract class PeriodeRepository extends ChangeNotifier {
  List<PeriodeModel> get periodes;
  PeriodeModel get activePeriode;
  Future<void> addPeriode(PeriodeModel item);
  Future<void> setActivePeriode(String id);
}

class DummyPeriodeRepository extends PeriodeRepository {
  final List<PeriodeModel> _periodes = List.from(dummyPeriode);

  @override
  List<PeriodeModel> get periodes => List.unmodifiable(_periodes);

  @override
  PeriodeModel get activePeriode => _periodes.firstWhere(
        (p) => p.isActive,
        orElse: () => _periodes.first,
      );

  @override
  Future<void> addPeriode(PeriodeModel item) async {
    _periodes.insert(0, item);
    notifyListeners();
  }

  @override
  Future<void> setActivePeriode(String id) async {
    for (int i = 0; i < _periodes.length; i++) {
      if (_periodes[i].id == id) {
        _periodes[i] = _periodes[i].copyWith(isActive: true);
      } else {
        _periodes[i] = _periodes[i].copyWith(isActive: false);
      }
    }
    notifyListeners();
  }
}

class ApiPeriodeRepository extends PeriodeRepository {
  List<PeriodeModel> _periodes = [];

  ApiPeriodeRepository() {
    _loadPeriodes();
  }

  Future<void> _loadPeriodes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _periodes = List.from(dummyPeriode);
    notifyListeners();
  }

  @override
  List<PeriodeModel> get periodes => List.unmodifiable(_periodes);

  @override
  PeriodeModel get activePeriode => _periodes.isEmpty
      ? PeriodeModel(
          id: 'default',
          nama: 'Default Periode',
          tanggalMulai: DateTime(2026, 1, 1),
          tanggalSelesai: DateTime(2026, 12, 31),
          isActive: true,
        )
      : _periodes.firstWhere(
          (p) => p.isActive,
          orElse: () => _periodes.first,
        );

  @override
  Future<void> addPeriode(PeriodeModel item) async {
    // POST /api/periodes
    _periodes.insert(0, item);
    notifyListeners();
  }

  @override
  Future<void> setActivePeriode(String id) async {
    // POST /api/periodes/$id/activate
    for (int i = 0; i < _periodes.length; i++) {
      if (_periodes[i].id == id) {
        _periodes[i] = _periodes[i].copyWith(isActive: true);
      } else {
        _periodes[i] = _periodes[i].copyWith(isActive: false);
      }
    }
    notifyListeners();
  }
}

