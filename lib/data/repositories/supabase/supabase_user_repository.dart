import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'realtime_repository_mixin.dart';
import 'kepengurusan_utils.dart';
import '../../models/user_model.dart';
import '../user_repository.dart';

class SupabaseUserRepository extends UserRepository with RealtimeRepositoryMixin {
  final _db = Supabase.instance.client;
  List<UserModel> _users = [];

  SupabaseUserRepository() {
    reload();
    // Realtime subscription to profiles table
    listenTable('profiles', reload);
  }

  @override
  Future<void> reload() => trackLoad(_loadUsers);

  Future<void> _loadUsers() async {
    try {
      final data = await selectProfilesWithJabatan(_db);
      
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
        final isAdmin = json['is_admin'] as bool? ?? false;

        String role = 'anggota';
        String? bidang;
        String? jabatan;

        final kepList = json['kepengurusan'] as List?;
        {
          final jab = pickJabatan(kepList);
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
          isAdmin: isAdmin,
        );
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading users: $e');
      rethrow;
    }
  }

  @override
  List<UserModel> get users => List.unmodifiable(_users);

  @override
  Future<void> addUser(UserModel user) async {
    // Adding user is handled by Supabase Auth sign up.
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await _db.from('profiles').update({
        'nama': user.nama,
        'nim': user.nim,
        'no_hp': user.noHp,
        'prodi': user.prodi,
        'angkatan': user.angkatan,
        'avatar_url': user.avatarUrl,
        'status': user.isVerified ? 'active' : 'pending',
        'is_admin': user.isAdmin,
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
              'avatar_url': user.avatarUrl,
            },
          ),
        );
      }

      reload();
    } catch (e) {
      debugPrint('Error updating user: $e');
      rethrow;
    }
  }

  @override
  Future<void> verifyUser(String id) async {
    try {
      await _db.from('profiles').update({
        'status': 'active',
      }).eq('id', id);
      reload();
    } catch (e) {
      debugPrint('Error verifying user: $e');
      rethrow;
    }
  }
}
