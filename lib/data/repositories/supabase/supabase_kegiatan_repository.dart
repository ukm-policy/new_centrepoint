import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/kegiatan_model.dart';
import '../kegiatan_repository.dart';

class SupabaseKegiatanRepository extends KegiatanRepository {
  final _db = Supabase.instance.client;
  List<KegiatanModel> _kegiatan = [];

  SupabaseKegiatanRepository() {
    _loadKegiatan();
    _db
        .channel('public:kegiatan')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'kegiatan',
          callback: (payload) {
            _loadKegiatan();
          },
        )
        .subscribe();
  }

  Future<void> _loadKegiatan() async {
    try {
      // 1. Fetch kegiatan
      final data = await _db.from('kegiatan').select(
        '*, panitia_inti(*), sie(*, sie_anggota(*))'
      ).order('tanggal', ascending: false);

      _kegiatan = data.map<KegiatanModel>((json) {
        final id = json['id'] as String;
        final judul = json['judul'] as String? ?? '';
        final deskripsi = json['deskripsi'] as String? ?? '';
        final tanggal = DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now();
        final waktu = json['waktu'] as String? ?? '';
        final lokasi = json['lokasi'] as String? ?? '';
        final status = json['status'] as String? ?? 'Akan Datang';
        final kuota = json['kuota'] as int? ?? 0;
        final pesertaTerdaftar = json['peserta_terdaftar'] as int? ?? 0;
        final periodeId = json['periode_id'] as String? ?? '';

        PanitiaModel? ketuaPelaksana;
        PanitiaModel? sekretarisPelaksana;
        PanitiaModel? bendaharaPelaksana;

        final panitiaList = json['panitia_inti'] as List?;
        if (panitiaList != null) {
          for (final p in panitiaList) {
            final peran = p['peran'] as String;
            final model = PanitiaModel(
              memberId: p['member_id'] as String? ?? '',
              nama: p['nama'] as String? ?? '',
              nim: p['nim'] as String? ?? '',
            );
            if (peran == 'ketua') {
              ketuaPelaksana = model;
            } else if (peran == 'sekretaris') {
              sekretarisPelaksana = model;
            } else if (peran == 'bendahara') {
              bendaharaPelaksana = model;
            }
          }
        }

        final List<SieModel> sies = [];
        final sieList = json['sie'] as List?;
        if (sieList != null) {
          for (final s in sieList) {
            final namaSie = s['nama_sie'] as String? ?? '';
            final anggotaList = s['sie_anggota'] as List?;
            PanitiaModel? ketuaSie;
            final List<PanitiaModel> anggotaSie = [];
            if (anggotaList != null) {
              for (final a in anggotaList) {
                final isKetua = a['is_ketua'] as bool? ?? false;
                final model = PanitiaModel(
                  memberId: a['member_id'] as String? ?? '',
                  nama: a['nama'] as String? ?? '',
                  nim: a['nim'] as String? ?? '',
                );
                if (isKetua) {
                  ketuaSie = model;
                } else {
                  anggotaSie.add(model);
                }
              }
            }
            sies.add(SieModel(
              namaSie: namaSie,
              ketua: ketuaSie,
              anggota: anggotaSie,
            ));
          }
        }

        return KegiatanModel(
          id: id,
          judul: judul,
          deskripsi: deskripsi,
          tanggal: tanggal,
          waktu: waktu,
          lokasi: lokasi,
          status: status,
          kuota: kuota,
          pesertaTerdaftar: pesertaTerdaftar,
          ketuaPelaksana: ketuaPelaksana,
          sekretarisPelaksana: sekretarisPelaksana,
          bendaharaPelaksana: bendaharaPelaksana,
          sie: sies,
          periodeId: periodeId,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading kegiatan: $e');
    }
  }

  @override
  List<KegiatanModel> get kegiatan => List.unmodifiable(_kegiatan);

  @override
  void addKegiatan(KegiatanModel item) async {
    try {
      final user = _db.auth.currentUser;
      // 1. Insert kegiatan
      final res = await _db.from('kegiatan').insert({
        'judul': item.judul,
        'deskripsi': item.deskripsi,
        'tanggal': item.tanggal.toIso8601String().substring(0, 10),
        'waktu': item.waktu,
        'lokasi': item.lokasi,
        'status': item.status,
        'kuota': item.kuota,
        'peserta_terdaftar': item.pesertaTerdaftar,
        'periode_id': item.periodeId.isNotEmpty ? item.periodeId : null,
        'created_by': user?.id,
      }).select().single();

      final kid = res['id'] as String;

      // 2. Insert panitia_inti
      if (item.ketuaPelaksana != null) {
        await _db.from('panitia_inti').insert({
          'kegiatan_id': kid,
          'peran': 'ketua',
          'member_id': item.ketuaPelaksana!.memberId,
          'nama': item.ketuaPelaksana!.nama,
          'nim': item.ketuaPelaksana!.nim,
        });
      }
      if (item.sekretarisPelaksana != null) {
        await _db.from('panitia_inti').insert({
          'kegiatan_id': kid,
          'peran': 'sekretaris',
          'member_id': item.sekretarisPelaksana!.memberId,
          'nama': item.sekretarisPelaksana!.nama,
          'nim': item.sekretarisPelaksana!.nim,
        });
      }
      if (item.bendaharaPelaksana != null) {
        await _db.from('panitia_inti').insert({
          'kegiatan_id': kid,
          'peran': 'bendahara',
          'member_id': item.bendaharaPelaksana!.memberId,
          'nama': item.bendaharaPelaksana!.nama,
          'nim': item.bendaharaPelaksana!.nim,
        });
      }

      // 3. Insert sie and anggota
      for (final s in item.sie) {
        final sieRes = await _db.from('sie').insert({
          'kegiatan_id': kid,
          'nama_sie': s.namaSie,
        }).select().single();
        final sid = sieRes['id'] as String;

        if (s.ketua != null) {
          await _db.from('sie_anggota').insert({
            'sie_id': sid,
            'member_id': s.ketua!.memberId,
            'nama': s.ketua!.nama,
            'nim': s.ketua!.nim,
            'is_ketua': true,
          });
        }
        for (final a in s.anggota) {
          await _db.from('sie_anggota').insert({
            'sie_id': sid,
            'member_id': a.memberId,
            'nama': a.nama,
            'nim': a.nim,
            'is_ketua': false,
          });
        }
      }

      _loadKegiatan();
    } catch (e) {
      debugPrint('Error adding kegiatan: $e');
    }
  }

  @override
  void updateKegiatan(KegiatanModel item) async {
    try {
      // 1. Update kegiatan core fields
      await _db.from('kegiatan').update({
        'judul': item.judul,
        'deskripsi': item.deskripsi,
        'tanggal': item.tanggal.toIso8601String().substring(0, 10),
        'waktu': item.waktu,
        'lokasi': item.lokasi,
        'status': item.status,
        'kuota': item.kuota,
        'peserta_terdaftar': item.pesertaTerdaftar,
      }).eq('id', item.id);

      // 2. Refresh panitia inti (Delete & re-insert)
      await _db.from('panitia_inti').delete().eq('kegiatan_id', item.id);
      if (item.ketuaPelaksana != null) {
        await _db.from('panitia_inti').insert({
          'kegiatan_id': item.id,
          'peran': 'ketua',
          'member_id': item.ketuaPelaksana!.memberId,
          'nama': item.ketuaPelaksana!.nama,
          'nim': item.ketuaPelaksana!.nim,
        });
      }
      if (item.sekretarisPelaksana != null) {
        await _db.from('panitia_inti').insert({
          'kegiatan_id': item.id,
          'peran': 'sekretaris',
          'member_id': item.sekretarisPelaksana!.memberId,
          'nama': item.sekretarisPelaksana!.nama,
          'nim': item.sekretarisPelaksana!.nim,
        });
      }
      if (item.bendaharaPelaksana != null) {
        await _db.from('panitia_inti').insert({
          'kegiatan_id': item.id,
          'peran': 'bendahara',
          'member_id': item.bendaharaPelaksana!.memberId,
          'nama': item.bendaharaPelaksana!.nama,
          'nim': item.bendaharaPelaksana!.nim,
        });
      }

      // 3. Refresh sie & sie_anggota
      await _db.from('sie').delete().eq('kegiatan_id', item.id);
      for (final s in item.sie) {
        final sieRes = await _db.from('sie').insert({
          'kegiatan_id': item.id,
          'nama_sie': s.namaSie,
        }).select().single();
        final sid = sieRes['id'] as String;

        if (s.ketua != null) {
          await _db.from('sie_anggota').insert({
            'sie_id': sid,
            'member_id': s.ketua!.memberId,
            'nama': s.ketua!.nama,
            'nim': s.ketua!.nim,
            'is_ketua': true,
          });
        }
        for (final a in s.anggota) {
          await _db.from('sie_anggota').insert({
            'sie_id': sid,
            'member_id': a.memberId,
            'nama': a.nama,
            'nim': a.nim,
            'is_ketua': false,
          });
        }
      }

      _loadKegiatan();
    } catch (e) {
      debugPrint('Error updating kegiatan: $e');
    }
  }

  @override
  void registerParticipant(String id) async {
    try {
      final user = _db.auth.currentUser;
      if (user == null) return;

      final k = _kegiatan.firstWhere((item) => item.id == id);
      if (k.pesertaTerdaftar < k.kuota) {
        // Increment registered participant count
        await _db.from('kegiatan').update({
          'peserta_terdaftar': k.pesertaTerdaftar + 1,
        }).eq('id', id);

        // Insert into absensi record as 'belumAbsen' to register
        await _db.from('absensi').insert({
          'member_id': user.id,
          'kegiatan_id': id,
          'tipe_kegiatan': 'kegiatan',
          'status': 'belumAbsen',
        });

        _loadKegiatan();
      }
    } catch (e) {
      debugPrint('Error registering participant: $e');
    }
  }

  @override
  void deleteKegiatan(String id) async {
    try {
      await _db.from('kegiatan').delete().eq('id', id);
      _loadKegiatan();
    } catch (e) {
      debugPrint('Error deleting kegiatan: $e');
    }
  }
}
