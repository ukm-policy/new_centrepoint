import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }

  static String get supabaseUrl => dotenv.get('SUPABASE_URL');
  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY');

  /// Deep link tujuan link email auth (reset password, konfirmasi email),
  /// mis. `io.supabase.centrepoint://login-callback/`. Harus didaftarkan di
  /// Supabase (Auth → URL Configuration → Redirect URLs) dan di
  /// AndroidManifest/Info.plist. Kosong = pakai Site URL dari Supabase.
  static String? get authRedirectUrl {
    final value = dotenv.maybeGet('AUTH_REDIRECT_URL');
    return value == null || value.isEmpty ? null : value;
  }
}
