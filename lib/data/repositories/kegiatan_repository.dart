import 'package:flutter/foundation.dart';
import '../models/kegiatan_model.dart';
import '../dummy/dummy_kegiatan.dart';

abstract class KegiatanRepository extends ChangeNotifier {
  List<KegiatanModel> get kegiatan;
  Future<void> addKegiatan(KegiatanModel item);
  Future<void> updateKegiatan(KegiatanModel item);
  void registerParticipant(String id);
  Future<void> deleteKegiatan(String id);
}

class DummyKegiatanRepository extends KegiatanRepository {
  final List<KegiatanModel> _kegiatan = List.from(dummyKegiatan);

  @override
  List<KegiatanModel> get kegiatan => List.unmodifiable(_kegiatan);

  @override
  Future<void> addKegiatan(KegiatanModel item) async {
    _kegiatan.insert(0, item);
    notifyListeners();
  }

  @override
  Future<void> updateKegiatan(KegiatanModel item) async {
    final idx = _kegiatan.indexWhere((k) => k.id == item.id);
    if (idx != -1) {
      _kegiatan[idx] = item;
      notifyListeners();
    }
  }

  @override
  void registerParticipant(String id) {
    final idx = _kegiatan.indexWhere((k) => k.id == id);
    if (idx != -1) {
      if (_kegiatan[idx].pesertaTerdaftar < _kegiatan[idx].kuota) {
        _kegiatan[idx] = _kegiatan[idx].copyWith(
          pesertaTerdaftar: _kegiatan[idx].pesertaTerdaftar + 1,
        );
        notifyListeners();
      }
    }
  }

  @override
  Future<void> deleteKegiatan(String id) async {
    _kegiatan.removeWhere((k) => k.id == id);
    notifyListeners();
  }
}

class ApiKegiatanRepository extends KegiatanRepository {
  List<KegiatanModel> _kegiatan = [];

  ApiKegiatanRepository() {
    _loadKegiatan();
  }

  Future<void> _loadKegiatan() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _kegiatan = List.from(dummyKegiatan);
    notifyListeners();
  }

  @override
  List<KegiatanModel> get kegiatan => List.unmodifiable(_kegiatan);

  @override
  Future<void> addKegiatan(KegiatanModel item) async {
    // POST /api/kegiatan
    _kegiatan.insert(0, item);
    notifyListeners();
  }

  @override
  Future<void> updateKegiatan(KegiatanModel item) async {
    // PUT /api/kegiatan/${item.id}
    final idx = _kegiatan.indexWhere((k) => k.id == item.id);
    if (idx != -1) {
      _kegiatan[idx] = item;
      notifyListeners();
    }
  }

  @override
  void registerParticipant(String id) {
    // POST /api/kegiatan/$id/register
    final idx = _kegiatan.indexWhere((k) => k.id == id);
    if (idx != -1) {
      if (_kegiatan[idx].pesertaTerdaftar < _kegiatan[idx].kuota) {
        _kegiatan[idx] = _kegiatan[idx].copyWith(
          pesertaTerdaftar: _kegiatan[idx].pesertaTerdaftar + 1,
        );
        notifyListeners();
      }
    }
  }

  @override
  Future<void> deleteKegiatan(String id) async {
    // DELETE /api/kegiatan/$id
    _kegiatan.removeWhere((k) => k.id == id);
    notifyListeners();
  }
}

