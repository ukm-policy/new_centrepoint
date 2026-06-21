import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/rapat_model.dart';
import '../rapat_repository.dart';

class SupabaseRapatRepository extends RapatRepository {
  final _db = Supabase.instance.client;
  List<RapatModel> _rapat = [];

  SupabaseRapatRepository() {
    _loadRapat();
    _db
        .channel('public:rapat')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'rapat',
          callback: (payload) {
            _loadRapat();
          },
        )
        .subscribe();
  }

  Future<void> _loadRapat() async {
    try {
      final data = await _db.from('rapat').select(
        '*, agenda_rapat(*), rapat_peserta(*)'
      ).order('tanggal', ascending: false);

      _rapat = data.map<RapatModel>((json) {
        final id = json['id'] as String;
        final judul = json['judul'] as String? ?? '';
        final tipeStr = json['tipe'] as String? ?? 'RapatTipe.rapatUmumAcara';
        final statusStr = json['status'] as String? ?? 'RapatStatus.terjadwal';
        final tanggal = DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now();
        final waktu = json['waktu'] as String? ?? '';
        final lokasi = json['lokasi'] as String? ?? '';
        final notulensi = json['notulensi'] as String?;
        final kegiatanId = json['kegiatan_id'] as String?;
        final namaSie = json['nama_sie'] as String?;
        final namaBidang = json['nama_bidang'] as String?;
        final denganKetuaBidang = json['dengan_ketua_bidang'] as bool? ?? false;

        final tipe = RapatTipe.values.firstWhere(
          (e) => e.toString() == tipeStr,
          orElse: () => RapatTipe.rapatUmumAcara,
        );
        final status = RapatStatus.values.firstWhere(
          (e) => e.toString() == statusStr,
          orElse: () => RapatStatus.terjadwal,
        );

        final List<AgendaModel> agendas = [];
        final agendaList = json['agenda_rapat'] as List?;
        if (agendaList != null) {
          final sorted = List.from(agendaList)
            ..sort((a, b) => (a['urutan'] as int? ?? 0).compareTo(b['urutan'] as int? ?? 0));
          for (final a in sorted) {
            agendas.add(AgendaModel(
              judul: a['judul'] as String? ?? '',
              keterangan: a['keterangan'] as String?,
            ));
          }
        }

        final List<String> pesertaIds = [];
        final pesertaList = json['rapat_peserta'] as List?;
        if (pesertaList != null) {
          for (final p in pesertaList) {
            pesertaIds.add(p['member_id'] as String);
          }
        }

        return RapatModel(
          id: id,
          judul: judul,
          tipe: tipe,
          status: status,
          tanggal: tanggal,
          waktu: waktu,
          lokasi: lokasi,
          agenda: agendas,
          pesertaIds: pesertaIds,
          notulensi: notulensi,
          kegiatanId: kegiatanId,
          namaSie: namaSie,
          namaBidang: namaBidang,
          denganKetuaBidang: denganKetuaBidang,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading rapat: $e');
    }
  }

  @override
  List<RapatModel> get rapat => List.unmodifiable(_rapat);

  @override
  void addRapat(RapatModel item) async {
    try {
      final user = _db.auth.currentUser;
      // 1. Insert rapat
      final res = await _db.from('rapat').insert({
        'judul': item.judul,
        'tipe': item.tipe.toString(),
        'status': item.status.toString(),
        'tanggal': item.tanggal.toIso8601String().substring(0, 10),
        'waktu': item.waktu,
        'lokasi': item.lokasi,
        'notulensi': item.notulensi,
        'kegiatan_id': item.kegiatanId,
        'nama_sie': item.namaSie,
        'nama_bidang': item.namaBidang,
        'dengan_ketua_bidang': item.denganKetuaBidang,
        'created_by': user?.id,
      }).select().single();

      final rid = res['id'] as String;

      // 2. Insert agenda_rapat
      for (int i = 0; i < item.agenda.length; i++) {
        final a = item.agenda[i];
        await _db.from('agenda_rapat').insert({
          'rapat_id': rid,
          'judul': a.judul,
          'keterangan': a.keterangan,
          'urutan': i,
        });
      }

      // 3. Insert rapat_peserta
      for (final pid in item.pesertaIds) {
        await _db.from('rapat_peserta').insert({
          'rapat_id': rid,
          'member_id': pid,
        });
      }

      _loadRapat();
    } catch (e) {
      debugPrint('Error adding rapat: $e');
    }
  }

  @override
  void updateRapat(RapatModel item) async {
    try {
      // 1. Update core fields
      await _db.from('rapat').update({
        'judul': item.judul,
        'tipe': item.tipe.toString(),
        'status': item.status.toString(),
        'tanggal': item.tanggal.toIso8601String().substring(0, 10),
        'waktu': item.waktu,
        'lokasi': item.lokasi,
        'notulensi': item.notulensi,
        'kegiatan_id': item.kegiatanId,
        'nama_sie': item.namaSie,
        'nama_bidang': item.namaBidang,
        'dengan_ketua_bidang': item.denganKetuaBidang,
      }).eq('id', item.id);

      // 2. Refresh agenda (Delete & re-insert)
      await _db.from('agenda_rapat').delete().eq('rapat_id', item.id);
      for (int i = 0; i < item.agenda.length; i++) {
        final a = item.agenda[i];
        await _db.from('agenda_rapat').insert({
          'rapat_id': item.id,
          'judul': a.judul,
          'keterangan': a.keterangan,
          'urutan': i,
        });
      }

      // 3. Refresh participants (Delete & re-insert)
      await _db.from('rapat_peserta').delete().eq('rapat_id', item.id);
      for (final pid in item.pesertaIds) {
        await _db.from('rapat_peserta').insert({
          'rapat_id': item.id,
          'member_id': pid,
        });
      }

      _loadRapat();
    } catch (e) {
      debugPrint('Error updating rapat: $e');
    }
  }

  @override
  void updateNotulensi(String id, String notulensi) async {
    try {
      await _db.from('rapat').update({
        'notulensi': notulensi,
        'status': RapatStatus.selesai.toString(),
      }).eq('id', id);
      _loadRapat();
    } catch (e) {
      debugPrint('Error updating notulensi: $e');
    }
  }
}
