import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';
import '../user_repository.dart';

class SupabaseUserRepository extends UserRepository {
  final _db = Supabase.instance.client;
  List<UserModel> _users = [];

  SupabaseUserRepository() {
    _loadUsers();
    // Realtime subscription to profiles table
    _db
        .channel('public:profiles')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'profiles',
          callback: (payload) {
            _loadUsers();
          },
        )
        .subscribe();
  }

  Future<void> _loadUsers() async {
    try {
      final data = await _db.from('profiles').select(
        '*, kepengurusan(jabatan(nama, level_akses, kode_role, bidang(nama)))'
      );
      
      _users = data.map<UserModel>((json) {
        final id = json['id'] as String;
        final nama = json['nama'] as String? ?? '';
        final email = json['email'] as String? ?? '';
        final nim = json['nim'] as String? ?? '';
        final noHp = json['no_hp'] as String? ?? '';
        final prodi = json['prodi'] as String? ?? '';
        final angkatan = json['angkatan'] as String? ?? '';
        final avatarUrl = json['avatar_url'] as String?;
        final status = json['status'] as String? ?? 'pending';
        final isVerified = status == 'active';
        final createdAt = DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now();

        String role = 'anggota';
        String? bidang;
        String? jabatan;

        final kepList = json['kepengurusan'] as List?;
        if (kepList != null && kepList.isNotEmpty) {
          final firstKep = kepList.first as Map<String, dynamic>?;
          final jab = firstKep?['jabatan'] as Map<String, dynamic>?;
          if (jab != null) {
            jabatan = jab['nama'] as String?;
            final lvl = jab['level_akses'] as int? ?? 1;
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

        return UserModel(
          id: id,
          nama: nama,
          email: email,
          nim: nim,
          noHp: noHp,
          prodi: prodi,
          angkatan: angkatan,
          role: role,
          bidang: bidang,
          jabatan: jabatan,
          avatarUrl: avatarUrl,
          isVerified: isVerified,
          createdAt: createdAt,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
  }

  @override
  List<UserModel> get users => List.unmodifiable(_users);

  @override
  void addUser(UserModel user) {
    // Adding user is handled by Supabase Auth sign up.
  }

  @override
  void updateUser(UserModel user) async {
    try {
      await _db.from('profiles').update({
        'nama': user.nama,
        'nim': user.nim,
        'no_hp': user.noHp,
        'prodi': user.prodi,
        'angkatan': user.angkatan,
        'avatar_url': user.avatarUrl,
        'status': user.isVerified ? 'active' : 'pending',
      }).eq('id', user.id);

      // If updating self, also update auth metadata to keep session in sync
      if (user.id == _db.auth.currentUser?.id) {
        await _db.auth.updateUser(
          UserAttributes(
            data: {
              'nama': user.nama,
              'nim': user.nim,
              'no_hp': user.noHp,
              'prodi': user.prodi,
              'angkatan': user.angkatan,
              'status': user.isVerified ? 'active' : 'pending',
              'avatar_url': user.avatarUrl,
            },
          ),
        );
      }

      _loadUsers();
    } catch (e) {
      debugPrint('Error updating user: $e');
    }
  }

  @override
  void verifyUser(String id) async {
    try {
      await _db.from('profiles').update({
        'status': 'active',
      }).eq('id', id);
      _loadUsers();
    } catch (e) {
      debugPrint('Error verifying user: $e');
    }
  }
}
