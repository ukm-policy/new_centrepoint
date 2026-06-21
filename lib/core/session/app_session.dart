import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../data/models/user_model.dart';

class AppSession {
  AppSession._();

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
  static String get email => supabaseUser?.email ?? '';
  static String get nama => supabaseUser?.userMetadata?['nama'] as String? ?? 'Pengguna';
  static String get nim => supabaseUser?.userMetadata?['nim'] as String? ?? '';
  static String get noHp => supabaseUser?.userMetadata?['no_hp'] as String? ?? '';
  static String get prodi => supabaseUser?.userMetadata?['prodi'] as String? ?? '';
  static String get angkatan => supabaseUser?.userMetadata?['angkatan'] as String? ?? '';

  static int get level =>
      (_claims['level'] as int?) ??
      (supabaseUser?.userMetadata?['level'] as int?) ??
      0;
  static String get kodeRole =>
      (_claims['kode_role'] as String?) ??
      (supabaseUser?.userMetadata?['kode_role'] as String?) ??
      'user_public';
  static String get bidang =>
      (_claims['bidang'] as String?) ??
      (supabaseUser?.userMetadata?['bidang'] as String?) ??
      '';
  static String get status =>
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

  static bool get isAdmin => level >= 4;

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
      avatarUrl: supabaseUser?.userMetadata?['avatar_url'] as String?,
      isVerified: status == 'active',
      createdAt: DateTime.tryParse(supabaseUser?.createdAt ?? '') ?? DateTime.now(),
    );
  }
}
