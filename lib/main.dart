import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/env/env.dart';
import 'core/session/session_controller.dart';
import 'core/supabase/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Env.init();
  } catch (e) {
    debugPrint('Env init error: $e');
  }

  try {
    await SupabaseClientHelper.init();
    SessionController.instance.start();
  } catch (e) {
    debugPrint('SupabaseClientHelper init error: $e');
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(const App());
}
