import 'package:flutter/foundation.dart';
import '../models/uang_khas_model.dart';
import '../models/rekap_model.dart';
import '../dummy/dummy_uang_khas.dart';

abstract class UangKhasRepository extends ChangeNotifier {
  List<UangKhasBulanModel> get khasBulan;
  List<TransaksiKhasModel> get transaksi;
  Future<void> payUangKhas(String memberId, String bulan, int tahun, int nominal, String buktiUrl);
  Future<void> addTransaksi(TransaksiKhasModel tx);
  Future<void> verifyPayment(String id, String memberNama);
  Future<void> rejectPayment(String id);
  Future<List<RekapBidangModel>> getRekapKeuangan(int tahun, int semester);
}

class DummyUangKhasRepository extends UangKhasRepository {
  final List<UangKhasBulanModel> _khasBulan = List.from(dummyUangKhasBulan);
  final List<TransaksiKhasModel> _transaksi = List.from(dummyTransaksiKhas);

  @override
  List<UangKhasBulanModel> get khasBulan => List.unmodifiable(_khasBulan);
  
  @override
  List<TransaksiKhasModel> get transaksi => List.unmodifiable(_transaksi);

  @override
  Future<void> payUangKhas(String memberId, String bulan, int tahun, int nominal, String buktiUrl) async {
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
  Future<void> addTransaksi(TransaksiKhasModel tx) async {
    _transaksi.insert(0, tx);
    notifyListeners();
  }

  @override
  Future<void> verifyPayment(String id, String memberNama) async {
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
  Future<void> rejectPayment(String id) async {
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

  @override
  Future<List<RekapBidangModel>> getRekapKeuangan(int tahun, int semester) async {
    return [
      RekapBidangModel(bidang: 'Umum', jumlahAnggota: 5, target: 500000, terkumpul: 450000),
    ];
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
  Future<void> payUangKhas(String memberId, String bulan, int tahun, int nominal, String buktiUrl) async {
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
  Future<void> addTransaksi(TransaksiKhasModel tx) async {
    // POST /api/khas/transaksi
    _transaksi.insert(0, tx);
    notifyListeners();
  }

  @override
  Future<void> verifyPayment(String id, String memberNama) async {
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
  Future<void> rejectPayment(String id) async {
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

  @override
  Future<List<RekapBidangModel>> getRekapKeuangan(int tahun, int semester) async {
    return [
      RekapBidangModel(bidang: 'Umum', jumlahAnggota: 5, target: 500000, terkumpul: 450000),
    ];
  }
}

