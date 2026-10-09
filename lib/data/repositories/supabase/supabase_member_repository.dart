import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'realtime_repository_mixin.dart';
import 'kepengurusan_utils.dart';
import '../../models/member_model.dart';
import '../member_repository.dart';
import '../../models/jabatan_model.dart';

class SupabaseMemberRepository extends MemberRepository with RealtimeRepositoryMixin {
  final _db = Supabase.instance.client;
  List<MemberModel> _members = [];

  SupabaseMemberRepository() {
    reload();
    // Realtime subscriptions
    listenTable('profiles', reload);
  }

  @override
  Future<void> reload() => trackLoad(_loadMembers);

  Future<void> _loadMembers() async {
    try {
      // 1. Fetch profiles and kepengurusan
      final data = await selectProfilesWithJabatan(_db);

      // 2. Fetch point sums for all users
      final pointsData = await _db.from('poin_entry').select('member_id, poin');
      final Map<String, int> userPoints = {};
      for (final p in pointsData) {
        final uid = p['member_id'] as String;
        final pts = p['poin'] as int? ?? 0;
        userPoints[uid] = (userPoints[uid] ?? 0) + pts;
      }

      // 3. Fetch attendance count for all users
      final absensiData = await _db.from('absensi').select('member_id, status, tipe_kegiatan');
      final Map<String, int> totalEvents = {};
      final Map<String, int> presentEvents = {};
      for (final a in absensiData) {
        // Absen sekret bukan kegiatan; tidak dihitung ke tingkat kehadiran.
        if (a['tipe_kegiatan'] == 'sekret') continue;
        final uid = a['member_id'] as String;
        final status = a['status'] as String? ?? 'belumAbsen';
        totalEvents[uid] = (totalEvents[uid] ?? 0) + 1;
        if (status == 'hadir') {
          presentEvents[uid] = (presentEvents[uid] ?? 0) + 1;
        }
      }

      _members = data.map<MemberModel>((json) {
        final id = json['id'] as String;
        final nama = json['nama'] as String? ?? '';
        final email = json['email'] as String? ?? '';
        final nim = json['nim'] as String? ?? '';
        final noHp = json['no_hp'] as String? ?? '';
        final prodi = json['prodi'] as String? ?? '';
        final angkatan = json['angkatan'] as String? ?? '';
        final avatarUrl = json['avatar_url'] as String?;
        final status = json['status'] as String? ?? 'pending';
        final isAdmin = json['is_admin'] as bool? ?? false;
        
        final totalPoin = userPoints[id] ?? 0;
        final kCount = totalEvents[id] ?? 0;
        final pCount = presentEvents[id] ?? 0;
        final kehadiranRate = kCount > 0 ? pCount / kCount : 1.0;

        String role = 'anggota';
        String? bidang;
        String? jabatan;
        int level = 2;

        final kepList = json['kepengurusan'] as List?;
        {
          final jab = pickJabatan(kepList);
          if (jab != null) {
            jabatan = jab['nama'] as String?;
            final lvl = jab['level_akses'] as int? ?? 1;
            level = lvl;
            if (lvl >= 5) {
              role = 'ketua';
            } else if (lvl >= 3) {
              role = 'staff';
            } else {
              role = 'anggota';
            }
            final bid = jab['bidang'] as Map<String, dynamic>?;
            if (bid != null) {
              bidang = bid['nama'] as String?;
            }
          }
        }

        String tier = 'Member';
        if (totalPoin >= 1200) {
          tier = 'Gold';
        } else if (totalPoin >= 800) {
          tier = 'Silver';
        } else if (totalPoin >= 400) {
          tier = 'Bronze';
        }

        return MemberModel(
          id: id,
          nama: nama,
          nim: nim,
          email: email,
          noHp: noHp,
          prodi: prodi,
          angkatan: angkatan,
          role: role,
          bidang: bidang,
          jabatan: jabatan,
          tier: tier,
          totalPoin: totalPoin,
          kegiatanCount: kCount,
          kehadiranRate: kehadiranRate,
          isActive: status == 'active',
          avatarUrl: avatarUrl,
          status: status == 'active' ? 'Aktif' : (status == 'suspended' ? 'Suspended' : 'Pending'),
          level: level,
          isAdmin: isAdmin,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading members: $e');
      rethrow;
    }
  }

  @override
  List<MemberModel> get members => List.unmodifiable(_members);

  @override
  Future<void> addMember(MemberModel member) async {
    // Handled by Auth SignUp
  }

  @override
  Future<void> updateMember(MemberModel member) async {
    try {
      await _db.from('profiles').update({
        'nama': member.nama,
        'nim': member.nim,
        'no_hp': member.noHp,
        'prodi': member.prodi,
        'angkatan': member.angkatan,
        'avatar_url': member.avatarUrl,
        'status': member.status == 'Aktif' ? 'active' : (member.status == 'Suspended' ? 'suspended' : 'pending'),
        'is_admin': member.isAdmin,
      }).eq('id', member.id);
      await reload();
    } catch (e) {
      debugPrint('Error updating member: $e');
      rethrow;
    }
  }

  @override
  Future<void> updatePoin(String id, int poinChange) async {
    try {
      final user = _members.firstWhere((m) => m.id == id);
      await _db.from('poin_entry').insert({
        'member_id': id,
        'member_nama': user.nama,
        'label': 'Penyesuaian Poin oleh Admin',
        'tipe': poinChange >= 0 ? 'bonus' : 'penalti',
        'poin': poinChange,
        'tanggal': DateTime.now().toIso8601String().substring(0, 10),
      });
      await reload();
    } catch (e) {
      debugPrint('Error updating points: $e');
      rethrow;
    }
  }

  @override
  Future<void> verifyMember(String id) async {
    try {
      await _db.from('profiles').update({
        'status': 'active',
      }).eq('id', id);
      await reload();
    } catch (e) {
      debugPrint('Error verifying member: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateStatusAndLevel(String id, {required String status, required int level, bool? isAdmin}) async {
    try {
      final dbStatus = status == 'Aktif' ? 'active' : (status == 'Suspended' ? 'suspended' : 'pending');
      final Map<String, dynamic> updates = {
        'status': dbStatus,
      };
      if (isAdmin != null) {
        updates['is_admin'] = isAdmin;
      }
      await _db.from('profiles').update(updates).eq('id', id);
      // Level akses berasal dari jabatan (lihat setJabatan / Assign Jabatan),
      // jadi [level] tidak diubah di sini.
      await reload();
    } catch (e) {
      debugPrint('Error updating status and level: $e');
      rethrow;
    }
  }

  @override
  Future<List<JabatanModel>> fetchJabatan() async {
    final data = await _db
        .from('jabatan')
        .select('id, nama, level_akses, kode_role, bidang(nama)')
        .order('level_akses', ascending: false)
        .order('nama');
    return data.map<JabatanModel>(JabatanModel.fromJson).toList();
  }

  @override
  Future<Map<String, int>> fetchKepengurusan(String periodeId) async {
    final data = await _db
        .from('kepengurusan')
        .select('user_id, jabatan_id')
        .eq('periode_id', periodeId);
    return {
      for (final row in data)
        row['user_id'] as String: (row['jabatan_id'] as num).toInt(),
    };
  }

  @override
  Future<void> setJabatan(String userId, String periodeId, int? jabatanId) async {
    try {
      // Satu anggota = satu jabatan per periode.
      await _db
          .from('kepengurusan')
          .delete()
          .eq('user_id', userId)
          .eq('periode_id', periodeId);
      if (jabatanId != null) {
        await _db.from('kepengurusan').insert({
          'user_id': userId,
          'jabatan_id': jabatanId,
          'periode_id': periodeId,
        });
      }
    } catch (e) {
      debugPrint('Error setting jabatan: $e');
      rethrow;
    }
  }
}
