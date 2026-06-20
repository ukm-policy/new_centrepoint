import 'package:flutter/foundation.dart';
import '../models/kegiatan_model.dart';
import '../dummy/dummy_kegiatan.dart';

abstract class KegiatanRepository extends ChangeNotifier {
  List<KegiatanModel> get kegiatan;
  void addKegiatan(KegiatanModel item);
  void updateKegiatan(KegiatanModel item);
  void registerParticipant(String id);
  void deleteKegiatan(String id);
}

class DummyKegiatanRepository extends KegiatanRepository {
  final List<KegiatanModel> _kegiatan = List.from(dummyKegiatan);

  @override
  List<KegiatanModel> get kegiatan => List.unmodifiable(_kegiatan);

  @override
  void addKegiatan(KegiatanModel item) {
    _kegiatan.insert(0, item);
    notifyListeners();
  }

  @override
  void updateKegiatan(KegiatanModel item) {
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
  void deleteKegiatan(String id) {
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
  void addKegiatan(KegiatanModel item) {
    // POST /api/kegiatan
    _kegiatan.insert(0, item);
    notifyListeners();
  }

  @override
  void updateKegiatan(KegiatanModel item) {
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
  void deleteKegiatan(String id) {
    // DELETE /api/kegiatan/$id
    _kegiatan.removeWhere((k) => k.id == id);
    notifyListeners();
  }
}

