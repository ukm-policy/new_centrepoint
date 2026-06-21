import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/uang_khas_model.dart';
import '../uang_khas_repository.dart';

class SupabaseUangKhasRepository extends UangKhasRepository {
  final _db = Supabase.instance.client;
  List<UangKhasBulanModel> _khasBulan = [];
  List<TransaksiKhasModel> _transaksi = [];

  SupabaseUangKhasRepository() {
    _loadUangKhas();
    _db
        .channel('public:uang_khas_bulan')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'uang_khas_bulan',
          callback: (payload) {
            _loadUangKhas();
          },
        )
        .subscribe();
    _db
        .channel('public:transaksi_khas')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'transaksi_khas',
          callback: (payload) {
            _loadUangKhas();
          },
        )
        .subscribe();
  }

  Future<void> _loadUangKhas() async {
    try {
      // 1. Fetch khasBulan records
      final khasData = await _db.from('uang_khas_bulan').select();
      _khasBulan = khasData.map<UangKhasBulanModel>((json) {
        final id = json['id'] as String;
        final memberId = json['member_id'] as String? ?? '';
        final bulan = json['bulan'] as String? ?? '';
        final tahun = json['tahun'] as int? ?? 2026;
        final nominal = json['nominal'] as int? ?? 10000;
        final statusStr = json['status'] as String? ?? 'belumBayar';
        final tanggalBayar = json['tanggal_bayar'] != null ? DateTime.tryParse(json['tanggal_bayar'] as String) : null;
        final buktiUrl = json['bukti_url'] as String?;
        final isVerified = json['is_verified'] as bool? ?? false;

        final status = StatusBayar.values.firstWhere(
          (e) => e.toString().split('.').last == statusStr,
          orElse: () => StatusBayar.belumBayar,
        );

        return UangKhasBulanModel(
          id: id,
          memberId: memberId,
          bulan: bulan,
          tahun: tahun,
          nominal: nominal,
          status: status,
          tanggalBayar: tanggalBayar,
          buktiUrl: buktiUrl,
          isVerified: isVerified,
        );
      }).toList();

      // 2. Fetch transaksi records
      final txData = await _db.from('transaksi_khas').select().order('tanggal', ascending: false);
      _transaksi = txData.map<TransaksiKhasModel>((json) {
        final id = json['id'] as String;
        final label = json['label'] as String? ?? '';
        final tanggal = DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now();
        final jumlah = json['jumlah'] as int? ?? 0;
        final isPemasukan = json['is_pemasukan'] as bool? ?? true;
        final isPending = json['is_pending'] as bool? ?? false;
        final keterangan = json['keterangan'] as String?;

        return TransaksiKhasModel(
          id: id,
          label: label,
          tanggal: tanggal,
          jumlah: jumlah,
          isPemasukan: isPemasukan,
          isPending: isPending,
          keterangan: keterangan,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading uang khas: $e');
    }
  }

  @override
  List<UangKhasBulanModel> get khasBulan => List.unmodifiable(_khasBulan);
  
  @override
  List<TransaksiKhasModel> get transaksi => List.unmodifiable(_transaksi);

  @override
  void payUangKhas(String memberId, String bulan, int tahun, int nominal, String buktiUrl) async {
    try {
      // 1. Insert/Upsert payment entry
      final khasRes = await _db.from('uang_khas_bulan').upsert({
        'member_id': memberId,
        'bulan': bulan,
        'tahun': tahun,
        'nominal': nominal,
        'status': 'pending',
        'tanggal_bayar': DateTime.now().toIso8601String(),
        'bukti_url': buktiUrl,
        'is_verified': false,
      }, onConflict: 'member_id, bulan, tahun').select().single();

      final kid = khasRes['id'] as String;

      // 2. Add pending transaction
      await _db.from('transaksi_khas').insert({
        'label': 'Pembayaran Iuran Kas ($bulan) — Pending',
        'tanggal': DateTime.now().toIso8601String().substring(0, 10),
        'jumlah': nominal,
        'is_pemasukan': true,
        'is_pending': true,
        'keterangan': 'Bukti Pembayaran Ref ID: $kid',
      });

      _loadUangKhas();
    } catch (e) {
      debugPrint('Error paying uang khas: $e');
    }
  }

  @override
  void addTransaksi(TransaksiKhasModel tx) async {
    try {
      final user = _db.auth.currentUser;
      await _db.from('transaksi_khas').insert({
        'label': tx.label,
        'tanggal': tx.tanggal.toIso8601String().substring(0, 10),
        'jumlah': tx.jumlah,
        'is_pemasukan': tx.isPemasukan,
        'is_pending': tx.isPending,
        'keterangan': tx.keterangan,
        'created_by': user?.id,
      });
      _loadUangKhas();
    } catch (e) {
      debugPrint('Error adding transaksi: $e');
    }
  }

  @override
  void verifyPayment(String id, String memberNama) async {
    try {
      final user = _db.auth.currentUser;
      // 1. Verify payment entry
      final khasData = await _db.from('uang_khas_bulan').update({
        'status': 'lunas',
        'is_verified': true,
        'verified_by': user?.id,
      }).eq('id', id).select().single();

      final bulan = khasData['bulan'] as String? ?? '';
      final nominal = khasData['nominal'] as int? ?? 10000;

      // 2. Update the pending transaction to complete
      final pendingTxs = await _db.from('transaksi_khas')
          .select()
          .eq('is_pending', true)
          .eq('jumlah', nominal)
          .like('keterangan', '%$id%');
      
      if (pendingTxs.isNotEmpty) {
        final txId = pendingTxs.first['id'] as String;
        await _db.from('transaksi_khas').update({
          'label': 'Iuran Bulanan ($bulan) — $memberNama',
          'is_pending': false,
        }).eq('id', txId);
      }

      _loadUangKhas();
    } catch (e) {
      debugPrint('Error verifying payment: $e');
    }
  }

  @override
  void rejectPayment(String id) async {
    try {
      // 1. Delete payment entry or set to belumBayar
      final khasData = await _db.from('uang_khas_bulan').update({
        'status': 'belumBayar',
        'is_verified': false,
        'bukti_url': null,
        'tanggal_bayar': null,
      }).eq('id', id).select().single();

      final nominal = khasData['nominal'] as int? ?? 10000;

      // 2. Remove pending transaction
      await _db.from('transaksi_khas')
          .delete()
          .eq('is_pending', true)
          .eq('jumlah', nominal)
          .like('keterangan', '%$id%');

      _loadUangKhas();
    } catch (e) {
      debugPrint('Error rejecting payment: $e');
    }
  }
}
