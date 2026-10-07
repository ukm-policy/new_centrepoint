import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../data/models/user_model.dart';

class AppSession {
  AppSession._();

  static Map<String, dynamic>? _cachedProfile;

  static void setProfile(Map<String, dynamic>? profile) {
    _cachedProfile = profile;
  }

  static User? get supabaseUser => Supabase.instance.client.auth.currentUser;

  static Map<String, dynamic> get _claims {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) return {};
    try {
      final decoded = JwtDecoder.decode(token);
      return decoded;
    } catch (_) {
      return {};
    }
  }

  static String get id => supabaseUser?.id ?? '';
  static String get email =>
      _cachedProfile?['email'] as String? ?? supabaseUser?.email ?? '';
  static String get nama =>
      _cachedProfile?['nama'] as String? ??
      supabaseUser?.userMetadata?['nama'] as String? ??
      'Pengguna';
  static String get nim =>
      _cachedProfile?['nim'] as String? ??
      supabaseUser?.userMetadata?['nim'] as String? ??
      '';
  static String get noHp =>
      _cachedProfile?['no_hp'] as String? ??
      supabaseUser?.userMetadata?['no_hp'] as String? ??
      '';
  static String get prodi =>
      _cachedProfile?['prodi'] as String? ??
      supabaseUser?.userMetadata?['prodi'] as String? ??
      '';
  static String get angkatan =>
      _cachedProfile?['angkatan'] as String? ??
      supabaseUser?.userMetadata?['angkatan'] as String? ??
      '';

  static int get level =>
      (_cachedProfile?['level'] as int?) ??
      (_claims['level'] as int?) ??
      (supabaseUser?.userMetadata?['level'] as int?) ??
      0;
  static String get kodeRole =>
      (_cachedProfile?['kode_role'] as String?) ??
      (_claims['kode_role'] as String?) ??
      (supabaseUser?.userMetadata?['kode_role'] as String?) ??
      'user_public';
  static String get bidang =>
      (_cachedProfile?['bidang'] as String?) ??
      (_claims['bidang'] as String?) ??
      (supabaseUser?.userMetadata?['bidang'] as String?) ??
      '';
  static String get status =>
      (_cachedProfile?['status'] as String?) ??
      (_claims['status'] as String?) ??
      (supabaseUser?.userMetadata?['status'] as String?) ??
      'pending';

  static String get role {
    if (level >= 5) return 'ketua';
    if (level >= 3) return 'staff';
    if (level >= 1) return 'anggota';
    return 'demisioner';
  }

  static String get jabatan {
    switch (kodeRole) {
      case 'ketua_umum':
        return 'Ketua Umum';
      case 'sekretaris_umum':
        return 'Sekretaris Umum';
      case 'bendahara_umum':
        return 'Bendahara Umum';
      default:
        if (kodeRole.startsWith('ketua_bidang_')) {
          return 'Ketua Bidang';
        }
        return 'Anggota';
    }
  }

  static bool get isAdmin =>
      (_cachedProfile?['is_admin'] as bool?) ??
      (_claims['is_admin'] as bool?) ??
      (supabaseUser?.userMetadata?['is_admin'] as bool?) ??
      false;

  static UserModel get currentUser {
    return UserModel(
      id: id,
      nama: nama,
      email: email,
      nim: nim,
      noHp: noHp,
      prodi: prodi,
      angkatan: angkatan,
      role: role,
      bidang: bidang.isNotEmpty ? bidang : null,
      jabatan: jabatan,
      avatarUrl:
          _cachedProfile?['avatar_url'] as String? ??
          supabaseUser?.userMetadata?['avatar_url'] as String?,
      isVerified: status == 'active',
      createdAt:
          DateTime.tryParse(supabaseUser?.createdAt ?? '') ?? DateTime.now(),
      isAdmin: isAdmin,
    );
  }
}
