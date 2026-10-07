import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/member_repository.dart';
import '../../data/repositories/berita_repository.dart';
import '../../data/repositories/kegiatan_repository.dart';
import '../../data/repositories/rapat_repository.dart';
import '../../data/repositories/absensi_repository.dart';
import '../../data/repositories/poin_repository.dart';
import '../../data/repositories/uang_khas_repository.dart';
import '../../data/repositories/inbox_repository.dart';
import '../../data/repositories/or_repository.dart';
import '../../data/repositories/periode_repository.dart';
import '../../data/repositories/supabase/supabase_user_repository.dart';
import '../../data/repositories/supabase/supabase_member_repository.dart';
import '../../data/repositories/supabase/supabase_berita_repository.dart';
import '../../data/repositories/supabase/supabase_kegiatan_repository.dart';
import '../../data/repositories/supabase/supabase_rapat_repository.dart';
import '../../data/repositories/supabase/supabase_absensi_repository.dart';
import '../../data/repositories/supabase/supabase_poin_repository.dart';
import '../../data/repositories/supabase/supabase_uang_khas_repository.dart';
import '../../data/repositories/supabase/supabase_inbox_repository.dart';
import '../../data/repositories/supabase/supabase_or_repository.dart';
import '../../data/repositories/supabase/supabase_periode_repository.dart';
import '../../data/repositories/qr_session_repository.dart';
import '../../data/repositories/audit_log_repository.dart';
import '../../data/repositories/supabase/supabase_qr_session_repository.dart';
import '../../data/repositories/supabase/supabase_audit_log_repository.dart';

/// Semua repository data aplikasi.
///
/// Dipasang di atas Navigator dan diberi key berdasarkan user id, sehingga
/// setiap kali user login/logout/berganti akun semua repository dibuat ulang
/// (data user lama tidak tersisa dan channel realtime lama ditutup).
class RepositoryProviders extends StatelessWidget {
  const RepositoryProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
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
        ChangeNotifierProvider<QrSessionRepository>(
          create: (_) => SupabaseQrSessionRepository(),
        ),
        ChangeNotifierProvider<AuditLogRepository>(
          create: (_) => SupabaseAuditLogRepository(),
        ),
      ],
      child: child,
    );
  }
}
