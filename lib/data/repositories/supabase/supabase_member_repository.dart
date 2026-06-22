import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/member_model.dart';
import '../member_repository.dart';

class SupabaseMemberRepository extends MemberRepository {
  final _db = Supabase.instance.client;
  List<MemberModel> _members = [];

  SupabaseMemberRepository() {
    _loadMembers();
    // Realtime subscriptions
    _db
        .channel('public:profiles-member')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'profiles',
          callback: (payload) {
            _loadMembers();
          },
        )
        .subscribe();
  }

  Future<void> _loadMembers() async {
    try {
      // 1. Fetch profiles and kepengurusan
      final data = await _db.from('profiles').select(
        '*, kepengurusan(jabatan(nama, level_akses, kode_role, bidang(nama)))'
      );

      // 2. Fetch point sums for all users
      final pointsData = await _db.from('poin_entry').select('member_id, poin');
      final Map<String, int> userPoints = {};
      for (final p in pointsData) {
        final uid = p['member_id'] as String;
        final pts = p['poin'] as int? ?? 0;
        userPoints[uid] = (userPoints[uid] ?? 0) + pts;
      }

      // 3. Fetch attendance count for all users
      final absensiData = await _db.from('absensi').select('member_id, status');
      final Map<String, int> totalEvents = {};
      final Map<String, int> presentEvents = {};
      for (final a in absensiData) {
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
        if (kepList != null && kepList.isNotEmpty) {
          final firstKep = kepList.first as Map<String, dynamic>?;
          final jab = firstKep?['jabatan'] as Map<String, dynamic>?;
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
      await _loadMembers();
    } catch (e) {
      debugPrint('Error updating member: $e');
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
      await _loadMembers();
    } catch (e) {
      debugPrint('Error updating points: $e');
    }
  }

  @override
  Future<void> assignRoleAndJabatan(String id, {required String role, String? bidang, String? jabatan}) async {
    try {
      // 1. Get jabatan details from DB matching the inputs
      final jabData = await _db.from('jabatan').select().eq('kode_role', role).maybeSingle();
      if (jabData == null) return;
      final jid = jabData['id'] as int;

      // 2. Get active period
      final periodData = await _db.from('periode').select().eq('is_aktif', true).maybeSingle();
      if (periodData == null) return;
      final pid = periodData['id'] as String;

      // 3. Update or Insert kepengurusan mapping
      await _db.from('kepengurusan').upsert({
        'user_id': id,
        'jabatan_id': jid,
        'periode_id': pid,
      }, onConflict: 'user_id, jabatan_id, periode_id');
      
      await _loadMembers();
    } catch (e) {
      debugPrint('Error assigning role: $e');
    }
  }

  @override
  Future<void> verifyMember(String id) async {
    try {
      await _db.from('profiles').update({
        'status': 'active',
      }).eq('id', id);
      await _loadMembers();
    } catch (e) {
      debugPrint('Error verifying member: $e');
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

      // Find a jabatan matching the level
      final jabData = await _db.from('jabatan').select().eq('level_akses', level).limit(1).maybeSingle();
      if (jabData != null) {
        final jid = jabData['id'] as int;
        
        final periodData = await _db.from('periode').select().eq('is_aktif', true).maybeSingle();
        if (periodData != null) {
          final pid = periodData['id'] as String;
          await _db.from('kepengurusan').upsert({
            'user_id': id,
            'jabatan_id': jid,
            'periode_id': pid,
          }, onConflict: 'user_id, jabatan_id, periode_id');
        }
      }
      await _loadMembers();
    } catch (e) {
      debugPrint('Error updating status and level: $e');
    }
  }
}
