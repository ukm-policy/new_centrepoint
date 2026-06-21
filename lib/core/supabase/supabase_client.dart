import 'package:supabase_flutter/supabase_flutter.dart';
import '../env/env.dart';

class SupabaseClientHelper {
  static Future<void> init() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
