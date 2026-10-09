import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_session.dart';
import '../../data/repositories/supabase/kepengurusan_utils.dart';

/// Sumber kebenaran status login + profil user yang sedang aktif.
///
/// - Memuat baris `profiles` (beserta jabatan dari `kepengurusan`) setiap kali
///   user berganti, lalu menyimpannya ke [AppSession].
/// - Membersihkan cache saat logout.
/// - Dipakai sebagai `refreshListenable` GoRouter sehingga redirect berjalan
///   otomatis saat sesi berubah.
class SessionController extends ChangeNotifier {
  SessionController._();
  static final SessionController instance = SessionController._();

  StreamSubscription<AuthState>? _authSub;
  String? _userId;
  bool _profileLoaded = false;

  /// ID user yang sedang login (null = belum login).
  String? get userId => _userId;

  /// true setelah profil user selesai dimuat (berhasil maupun gagal).
  bool get profileLoaded => _profileLoaded;

  bool _passwordRecovery = false;

  /// true ketika user masuk lewat link reset password dan harus membuat
  /// password baru.
  bool get passwordRecovery => _passwordRecovery;

  void finishPasswordRecovery() {
    if (!_passwordRecovery) return;
    _passwordRecovery = false;
    notifyListeners();
  }

  void start() {
    final auth = Supabase.instance.client.auth;
    _authSub?.cancel();
    _authSub = auth.onAuthStateChange.listen(
      (state) {
        if (state.event == AuthChangeEvent.passwordRecovery) {
          _passwordRecovery = true;
          notifyListeners();
        }
        _handleUser(state.session?.user);
      },
      onError: (Object e) => debugPrint('Auth state error: $e'),
    );
    _handleUser(auth.currentUser);
  }

  Future<void> _handleUser(User? user) async {
    if (user == null) {
      _passwordRecovery = false;
      if (_userId == null && !_profileLoaded) return;
      _userId = null;
      _profileLoaded = false;
      AppSession.setProfile(null);
      notifyListeners();
      return;
    }

    // Token refresh / user updated untuk user yang sama: tidak perlu reload.
    if (user.id == _userId) return;

    _userId = user.id;
    _profileLoaded = false;
    AppSession.setProfile(null);
    notifyListeners();
    await reloadProfile();
  }

  /// Ambil ulang profil user aktif dari database (mis. setelah edit profil
  /// atau saat cek status verifikasi).
  Future<void> reloadProfile() async {
    final uid = _userId;
    if (uid == null) return;

    final profile = await _fetchProfile(uid);
    // User berganti selama fetch berlangsung — abaikan hasil lama.
    if (uid != _userId) return;

    AppSession.setProfile(profile);
    _profileLoaded = true;
    notifyListeners();
  }

  static const _profileSelects = [
    '*, $kepengurusanEmbed',
    '*, $kepengurusanEmbedBasic',
    '*',
  ];

  Future<Map<String, dynamic>?> _fetchProfile(String uid) async {
    final db = Supabase.instance.client;
    for (final select in _profileSelects) {
      try {
        final data = await db
            .from('profiles')
            .select(select)
            .eq('id', uid)
            .maybeSingle();
        if (data == null) return null;
        return _withJabatan(data);
      } catch (e) {
        debugPrint('Gagal memuat profil ($select): $e');
      }
    }
    return null;
  }

  /// Ratakan jabatan aktif (level tertinggi, utamakan periode aktif) ke
  /// key `level`, `kode_role`, dan `bidang` agar terbaca oleh [AppSession].
  static Map<String, dynamic> _withJabatan(Map<String, dynamic> data) {
    final profile = Map<String, dynamic>.from(data);
    final kepList = profile.remove('kepengurusan') as List?;

    final best = pickJabatan(kepList);

    if (best != null) {
      profile['level'] ??= (best['level_akses'] as num?)?.toInt();
      profile['kode_role'] ??= best['kode_role'];
      profile['bidang'] ??= (best['bidang'] as Map<String, dynamic>?)?['nama'];
    }
    return profile;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
