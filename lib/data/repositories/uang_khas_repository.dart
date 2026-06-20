import 'package:flutter/foundation.dart';
import '../models/uang_khas_model.dart';
import '../dummy/dummy_uang_khas.dart';

abstract class UangKhasRepository extends ChangeNotifier {
  List<UangKhasBulanModel> get khasBulan;
  List<TransaksiKhasModel> get transaksi;
  void payUangKhas(String memberId, String bulan, int tahun, int nominal, String buktiUrl);
  void addTransaksi(TransaksiKhasModel tx);
  void verifyPayment(String id, String memberNama);
  void rejectPayment(String id);
}

class DummyUangKhasRepository extends UangKhasRepository {
  final List<UangKhasBulanModel> _khasBulan = List.from(dummyUangKhasBulan);
  final List<TransaksiKhasModel> _transaksi = List.from(dummyTransaksiKhas);

  @override
  List<UangKhasBulanModel> get khasBulan => List.unmodifiable(_khasBulan);
  
  @override
  List<TransaksiKhasModel> get transaksi => List.unmodifiable(_transaksi);

  @override
  void payUangKhas(String memberId, String bulan, int tahun, int nominal, String buktiUrl) {
    final newRecord = UangKhasBulanModel(
      id: 'k-${DateTime.now().millisecondsSinceEpoch}',
      memberId: memberId,
      bulan: bulan,
      tahun: tahun,
      nominal: nominal,
      status: StatusBayar.pending,
      tanggalBayar: DateTime.now(),
      buktiUrl: buktiUrl,
      isVerified: false,
    );
    _khasBulan.add(newRecord);

    final newTx = TransaksiKhasModel(
      id: 't-${DateTime.now().millisecondsSinceEpoch}',
      label: 'Pembayaran Iuran Kas ($bulan) — Pending',
      tanggal: DateTime.now(),
      jumlah: nominal,
      isPemasukan: true,
      isPending: true,
    );
    _transaksi.insert(0, newTx);
    notifyListeners();
  }

  @override
  void addTransaksi(TransaksiKhasModel tx) {
    _transaksi.insert(0, tx);
    notifyListeners();
  }

  @override
  void verifyPayment(String id, String memberNama) {
    final idx = _khasBulan.indexWhere((k) => k.id == id);
    if (idx != -1) {
      final oldRecord = _khasBulan[idx];
      _khasBulan[idx] = oldRecord.copyWith(
        status: StatusBayar.lunas,
        isVerified: true,
      );

      final txIdx = _transaksi.indexWhere((t) => t.isPending && t.jumlah == oldRecord.nominal);
      if (txIdx != -1) {
        _transaksi[txIdx] = _transaksi[txIdx].copyWith(
          label: 'Iuran Bulanan (${oldRecord.bulan}) — $memberNama',
          isPending: false,
        );
      }
      notifyListeners();
    }
  }

  @override
  void rejectPayment(String id) {
    final idx = _khasBulan.indexWhere((k) => k.id == id);
    if (idx != -1) {
      _khasBulan[idx] = _khasBulan[idx].copyWith(
        status: StatusBayar.belumBayar,
        isVerified: false,
      );
      _transaksi.removeWhere((t) => t.isPending && t.jumlah == _khasBulan[idx].nominal);
      notifyListeners();
    }
  }
}

class ApiUangKhasRepository extends UangKhasRepository {
  List<UangKhasBulanModel> _khasBulan = [];
  List<TransaksiKhasModel> _transaksi = [];

  ApiUangKhasRepository() {
    _loadUangKhas();
  }

  Future<void> _loadUangKhas() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _khasBulan = List.from(dummyUangKhasBulan);
    _transaksi = List.from(dummyTransaksiKhas);
    notifyListeners();
  }

  @override
  List<UangKhasBulanModel> get khasBulan => List.unmodifiable(_khasBulan);
  
  @override
  List<TransaksiKhasModel> get transaksi => List.unmodifiable(_transaksi);

  @override
  void payUangKhas(String memberId, String bulan, int tahun, int nominal, String buktiUrl) {
    // POST /api/khas/pay
    final newRecord = UangKhasBulanModel(
      id: 'k-${DateTime.now().millisecondsSinceEpoch}',
      memberId: memberId,
      bulan: bulan,
      tahun: tahun,
      nominal: nominal,
      status: StatusBayar.pending,
      tanggalBayar: DateTime.now(),
      buktiUrl: buktiUrl,
      isVerified: false,
    );
    _khasBulan.add(newRecord);

    final newTx = TransaksiKhasModel(
      id: 't-${DateTime.now().millisecondsSinceEpoch}',
      label: 'Pembayaran Iuran Kas ($bulan) — Pending',
      tanggal: DateTime.now(),
      jumlah: nominal,
      isPemasukan: true,
      isPending: true,
    );
    _transaksi.insert(0, newTx);
    notifyListeners();
  }

  @override
  void addTransaksi(TransaksiKhasModel tx) {
    // POST /api/khas/transaksi
    _transaksi.insert(0, tx);
    notifyListeners();
  }

  @override
  void verifyPayment(String id, String memberNama) {
    // POST /api/khas/verify/$id
    final idx = _khasBulan.indexWhere((k) => k.id == id);
    if (idx != -1) {
      final oldRecord = _khasBulan[idx];
      _khasBulan[idx] = oldRecord.copyWith(
        status: StatusBayar.lunas,
        isVerified: true,
      );

      final txIdx = _transaksi.indexWhere((t) => t.isPending && t.jumlah == oldRecord.nominal);
      if (txIdx != -1) {
        _transaksi[txIdx] = _transaksi[txIdx].copyWith(
          label: 'Iuran Bulanan (${oldRecord.bulan}) — $memberNama',
          isPending: false,
        );
      }
      notifyListeners();
    }
  }

  @override
  void rejectPayment(String id) {
    // POST /api/khas/reject/$id
    final idx = _khasBulan.indexWhere((k) => k.id == id);
    if (idx != -1) {
      _khasBulan[idx] = _khasBulan[idx].copyWith(
        status: StatusBayar.belumBayar,
        isVerified: false,
      );
      _transaksi.removeWhere((t) => t.isPending && t.jumlah == _khasBulan[idx].nominal);
      notifyListeners();
    }
  }
}

