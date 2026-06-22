import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/periode_model.dart';
import '../periode_repository.dart';

class SupabasePeriodeRepository extends PeriodeRepository {
  final _db = Supabase.instance.client;
  List<PeriodeModel> _periodes = [];

  SupabasePeriodeRepository() {
    _loadPeriodes();
    _db
        .channel('public:periode')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'periode',
          callback: (payload) {
            _loadPeriodes();
          },
        )
        .subscribe();
  }

  Future<void> _loadPeriodes() async {
    try {
      final data = await _db.from('periode').select().order('tahun_mulai', ascending: false);
      _periodes = data.map<PeriodeModel>((json) {
        final id = json['id'] as String;
        final nama = json['nama'] as String? ?? 'Periode';
        final tMulai = json['tahun_mulai'] as int? ?? DateTime.now().year;
        final tSelesai = json['tahun_selesai'] as int? ?? DateTime.now().year;
        final isAktif = json['is_aktif'] as bool? ?? false;

        return PeriodeModel(
          id: id,
          nama: nama,
          tanggalMulai: DateTime(tMulai, 1, 1),
          tanggalSelesai: DateTime(tSelesai, 12, 31),
          isActive: isAktif,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading periodes: $e');
    }
  }

  @override
  List<PeriodeModel> get periodes => List.unmodifiable(_periodes);

  @override
  PeriodeModel get activePeriode => _periodes.isEmpty
      ? PeriodeModel(
          id: 'default',
          nama: 'Default Periode',
          tanggalMulai: DateTime(DateTime.now().year, 1, 1),
          tanggalSelesai: DateTime(DateTime.now().year, 12, 31),
          isActive: true,
        )
      : _periodes.firstWhere(
          (p) => p.isActive,
          orElse: () => _periodes.first,
        );

  @override
  Future<void> addPeriode(PeriodeModel item) async {
    try {
      await _db.from('periode').insert({
        'nama': item.nama,
        'tahun_mulai': item.tanggalMulai.year,
        'tahun_selesai': item.tanggalSelesai.year,
        'is_aktif': item.isActive,
      });
      await _loadPeriodes();
    } catch (e) {
      debugPrint('Error adding periode: $e');
    }
  }

  @override
  Future<void> setActivePeriode(String id) async {
    try {
      // Set all to false, then target to true in a transaction / multiple calls
      await _db.from('periode').update({'is_aktif': false});
      await _db.from('periode').update({'is_aktif': true}).eq('id', id);
      await _loadPeriodes();
    } catch (e) {
      debugPrint('Error setting active periode: $e');
    }
  }
}
