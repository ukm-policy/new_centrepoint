import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/session/app_session.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/complete_profile_screen.dart';
import 'features/auth/screens/setup_password_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/pending_screen.dart';
import 'features/auth/screens/edit_profile_screen.dart';
import 'features/beranda/screens/beranda_screen.dart';
import 'features/berita/screens/list_berita_screen.dart';
import 'features/berita/screens/detail_berita_screen.dart';
import 'features/kegiatan/screens/list_kegiatan_screen.dart';
import 'features/kegiatan/screens/detail_kegiatan_screen.dart';
import 'features/kegiatan/screens/create_kegiatan_screen.dart';
import 'features/kegiatan/screens/riwayat_kegiatan_screen.dart';
import 'features/kegiatan/screens/detail_rapat_screen.dart';
import 'features/kegiatan/screens/create_rapat_screen.dart';
import 'features/anggota/screens/list_members_screen.dart';
import 'features/anggota/screens/detail_member_screen.dart';
import 'features/absensi/screens/absensi_screen.dart';
import 'features/absensi/screens/riwayat_sekret_screen.dart';
import 'features/uang_khas/screens/uang_khas_screen.dart';
import 'features/menu/screens/menu_setelan_screen.dart';
import 'features/menu/screens/notifikasi_settings_screen.dart';
import 'features/menu/screens/about_screen.dart';
import 'features/poin/screens/poin_screen.dart';
import 'features/fitur/screens/fitur_screen.dart';
import 'features/inbox/screens/inbox_screen.dart';
import 'features/admin/screens/admin_screen.dart';
import 'features/admin/screens/verifikasi_anggota_screen.dart';
import 'features/admin/screens/kelola_berita_screen.dart';
import 'features/admin/screens/buat_pengumuman_screen.dart';
import 'features/admin/screens/qr_generator_screen.dart';
import 'features/admin/screens/kelola_kegiatan_screen.dart';
import 'features/admin/screens/uang_khas_admin_screen.dart';
import 'features/admin/screens/verifikasi_khas_screen.dart';
import 'features/admin/screens/kelola_akun_screen.dart';
import 'features/admin/screens/kelola_poin_screen.dart';
import 'features/admin/screens/assign_jabatan_screen.dart';
import 'features/admin/screens/rekap_keuangan_screen.dart';
import 'features/admin/screens/kelola_periode_screen.dart';
import 'features/admin/screens/audit_log_screen.dart';
import 'features/fitur/screens/info_bidang_screen.dart';
import 'features/or/screens/or_screen.dart';
import 'features/or/screens/or_form_screen.dart';
import 'features/or/screens/or_status_screen.dart';
import 'features/or/screens/or_admin_screen.dart';
import 'features/or/screens/or_detail_screen.dart';
import 'features/or/screens/or_kelola_screen.dart';
import 'features/inbox/screens/detail_pengumuman_screen.dart';
import 'shared/widgets/bottom_nav_bar.dart';
import 'shared/widgets/app_drawer.dart';

final _router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final user = Supabase.instance.client.auth.currentUser;
    final path = state.uri.path;

    if (path == '/login' || path == '/register' || path == '/forgot-password') {
      if (user != null) {
        if (AppSession.status == 'pending') {
          return '/pending';
        }
        return '/';
      }
      return null;
    }

    if (user == null) {
      return '/login';
    }

    if (AppSession.status == 'pending' && path != '/pending' && path != '/lengkapi-profil') {
      return '/pending';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, _) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, _) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (_, _) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/pending',
      builder: (_, _) => const PendingScreen(),
    ),
    GoRoute(
      path: '/lengkapi-profil',
      builder: (_, _) => const CompleteProfileScreen(),
    ),
    GoRoute(
      path: '/setup-password',
      builder: (_, _) => const SetupPasswordScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/profil/edit',
          builder: (_, _) => const EditProfileScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (_, _) => const BerandaScreen(),
        ),
        GoRoute(
          path: '/berita',
          builder: (_, _) => const ListBeritaScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  DetailBeritaScreen(id: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: '/kegiatan',
          builder: (_, _) => const ListKegiatanScreen(),
          routes: [
            GoRoute(
              path: 'buat',
              builder: (_, _) => const CreateKegiatanScreen(),
            ),
            GoRoute(
              path: 'riwayat',
              builder: (_, _) => const RiwayatKegiatanScreen(),
            ),
            GoRoute(
              path: 'rapat',
              builder: (_, _) => const ListKegiatanScreen(),
              routes: [
                GoRoute(
                  path: 'buat',
                  builder: (_, _) => const CreateRapatScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (_, state) =>
                      DetailRapatScreen(id: state.pathParameters['id']!),
                ),
              ],
            ),
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  DetailKegiatanScreen(id: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: '/anggota',
          builder: (_, _) => const ListMembersScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  DetailMemberScreen(id: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: '/absensi',
          builder: (_, _) => const AbsensiScreen(),
          routes: [
            GoRoute(
              path: 'riwayat-sekret',
              builder: (_, _) => const RiwayatSekretScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/uang-khas',
          builder: (_, _) => const UangKhasScreen(),
        ),
        GoRoute(
          path: '/poin',
          builder: (_, _) => const PoinScreen(),
        ),
        GoRoute(
          path: '/fitur',
          builder: (_, _) => const FiturScreen(),
          routes: [
            GoRoute(
              path: 'bidang',
              builder: (_, _) => const InfoBidangScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/menu',
          builder: (_, _) => const MenuSetelanScreen(),
        ),
        GoRoute(
          path: '/menu/notifikasi',
          builder: (_, _) => const NotifikasiSettingsScreen(),
        ),
        GoRoute(
          path: '/menu/tentang',
          builder: (_, _) => const AboutScreen(),
        ),
        GoRoute(
          path: '/inbox',
          builder: (_, _) => const InboxScreen(),
          routes: [
            GoRoute(
              path: 'pengumuman/:id',
              builder: (_, state) =>
                  DetailPengumumanScreen(id: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: '/admin',
          builder: (_, _) => const AdminScreen(),
          routes: [
            GoRoute(
              path: 'verifikasi',
              builder: (_, _) => const VerifikasiAnggotaScreen(),
            ),
            GoRoute(
              path: 'berita',
              builder: (_, _) => const KelolaBeritaScreen(),
            ),
            GoRoute(
              path: 'pengumuman/buat',
              builder: (_, _) => const BuatPengumumanScreen(),
            ),
            GoRoute(
              path: 'qr-generator',
              builder: (_, _) => const QrGeneratorScreen(),
            ),
            GoRoute(
              path: 'kegiatan',
              builder: (_, _) => const KelolaKegiatanScreen(),
            ),
            GoRoute(
              path: 'uang-khas',
              builder: (_, _) => const UangKhasAdminScreen(),
              routes: [
                GoRoute(
                  path: 'verifikasi',
                  builder: (_, _) => const VerifikasiKhasScreen(),
                ),
              ],
            ),
            GoRoute(
              path: 'users',
              builder: (_, _) => const KelolaAkunScreen(),
            ),
            GoRoute(
              path: 'poin',
              builder: (_, _) => const KelolaPoinScreen(),
            ),
            GoRoute(
              path: 'periode/jabatan',
              builder: (_, _) => const AssignJabatanScreen(),
            ),
            GoRoute(
              path: 'keuangan',
              builder: (_, _) => const RekapKeuanganScreen(),
            ),
            GoRoute(
              path: 'periode',
              builder: (_, _) => const KelolaPeriodeScreen(),
            ),
            GoRoute(
              path: 'log',
              builder: (_, _) => const AuditLogScreen(),
            ),
            GoRoute(
              path: 'or',
              builder: (_, _) => const OrAdminScreen(),
              routes: [
                GoRoute(
                  path: 'kelola',
                  builder: (_, _) => const OrKelolaScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (_, state) =>
                      OrDetailScreen(id: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/or',
          builder: (_, _) => const OrScreen(),
          routes: [
            GoRoute(
              path: 'daftar',
              builder: (_, _) => const OrFormScreen(),
            ),
            GoRoute(
              path: 'status',
              builder: (_, state) => OrStatusScreen(nim: state.extra as String?),
            ),
          ],
        ),
      ],
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Centrepoint',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});
  final Widget child;

  static const _navRoutes = ['/', '/kegiatan', '/fitur', '/menu'];
  static const _mainRoutes = {'/', '/kegiatan', '/fitur', '/menu', '/absensi'};

  // Kembalikan index active (-1 = tidak ada yg active, misal Absensi)
  static int _navIndexOf(String path) {
    if (path == '/') return 0;
    if (path == '/kegiatan') return 1;
    if (path == '/fitur') return 2;
    if (path == '/menu') return 3;
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final showNav = _mainRoutes.contains(currentPath);
    final navIndex = _navIndexOf(currentPath);
    final navClearance = 96 + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFEFECEC),
      drawer: const AppDrawer(),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              bottom: showNav ? navClearance : 0,
              child: child,
            ),
            if (showNav)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: FloatingBottomNavBar(
                  currentIndex: navIndex,
                  onTap: (i) => context.go(_navRoutes[i]),
                  onAbsensiTap: () => context.push('/absensi'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
