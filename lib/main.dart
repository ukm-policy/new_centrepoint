import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/env/env.dart';
import 'core/supabase/supabase_client.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/member_repository.dart';
import 'data/repositories/berita_repository.dart';
import 'data/repositories/kegiatan_repository.dart';
import 'data/repositories/rapat_repository.dart';
import 'data/repositories/absensi_repository.dart';
import 'data/repositories/poin_repository.dart';
import 'data/repositories/uang_khas_repository.dart';
import 'data/repositories/inbox_repository.dart';
import 'data/repositories/or_repository.dart';
import 'data/repositories/periode_repository.dart';
import 'data/repositories/supabase/supabase_user_repository.dart';
import 'data/repositories/supabase/supabase_member_repository.dart';
import 'data/repositories/supabase/supabase_berita_repository.dart';
import 'data/repositories/supabase/supabase_kegiatan_repository.dart';
import 'data/repositories/supabase/supabase_rapat_repository.dart';
import 'data/repositories/supabase/supabase_absensi_repository.dart';
import 'data/repositories/supabase/supabase_poin_repository.dart';
import 'data/repositories/supabase/supabase_uang_khas_repository.dart';
import 'data/repositories/supabase/supabase_inbox_repository.dart';
import 'data/repositories/supabase/supabase_or_repository.dart';
import 'data/repositories/supabase/supabase_periode_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.init();
  await SupabaseClientHelper.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserRepository>(
          create: (_) => SupabaseUserRepository(),
        ),
        ChangeNotifierProvider<MemberRepository>(
          create: (_) => SupabaseMemberRepository(),
        ),
        ChangeNotifierProvider<BeritaRepository>(
          create: (_) => SupabaseBeritaRepository(),
        ),
        ChangeNotifierProvider<KegiatanRepository>(
          create: (_) => SupabaseKegiatanRepository(),
        ),
        ChangeNotifierProvider<RapatRepository>(
          create: (_) => SupabaseRapatRepository(),
        ),
        ChangeNotifierProvider<AbsensiRepository>(
          create: (_) => SupabaseAbsensiRepository(),
        ),
        ChangeNotifierProvider<PoinRepository>(
          create: (_) => SupabasePoinRepository(),
        ),
        ChangeNotifierProvider<UangKhasRepository>(
          create: (_) => SupabaseUangKhasRepository(),
        ),
        ChangeNotifierProvider<InboxRepository>(
          create: (_) => SupabaseInboxRepository(),
        ),
        ChangeNotifierProvider<ORRepository>(
          create: (_) => SupabaseORRepository(),
        ),
        ChangeNotifierProvider<PeriodeRepository>(
          create: (_) => SupabasePeriodeRepository(),
        ),
      ],
      child: const App(),
    ),
  );
}
