import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/beranda/screens/beranda_screen.dart';
import 'features/berita/screens/list_berita_screen.dart';
import 'features/berita/screens/detail_berita_screen.dart';
import 'features/kegiatan/screens/list_kegiatan_screen.dart';
import 'features/kegiatan/screens/detail_kegiatan_screen.dart';
import 'features/anggota/screens/list_members_screen.dart';
import 'features/anggota/screens/detail_member_screen.dart';
import 'features/absensi/screens/absensi_screen.dart';
import 'features/absensi/screens/riwayat_sekret_screen.dart';
import 'features/uang_khas/screens/uang_khas_screen.dart';
import 'features/menu/screens/menu_setelan_screen.dart';
import 'features/poin/screens/poin_screen.dart';
import 'features/inbox/screens/inbox_screen.dart';
import 'features/inbox/screens/detail_pengumuman_screen.dart';
import 'shared/widgets/bottom_nav_bar.dart';
import 'shared/widgets/app_drawer.dart';

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, _) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
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
          path: '/menu',
          builder: (_, _) => const MenuSetelanScreen(),
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
      ],
    ),
  ],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Policy Centrepoint',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});
  final Widget child;

  static const _navRoutes = ['/', '/berita', '/kegiatan', '/menu'];
  static const _mainRoutes = {'/', '/berita', '/kegiatan', '/menu', '/absensi'};

  // Kembalikan index active (-1 = tidak ada yg active, misal Absensi)
  static int _navIndexOf(String path) {
    if (path == '/') return 0;
    if (path == '/berita') return 1;
    if (path == '/kegiatan') return 2;
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
