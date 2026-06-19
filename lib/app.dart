import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/beranda/screens/beranda_screen.dart';
import 'features/berita/screens/list_berita_screen.dart';
import 'features/berita/screens/detail_berita_screen.dart';
import 'features/kegiatan/screens/list_kegiatan_screen.dart';
import 'features/kegiatan/screens/detail_kegiatan_screen.dart';
import 'features/kegiatan/screens/riwayat_kegiatan_screen.dart';
import 'features/anggota/screens/list_members_screen.dart';
import 'features/anggota/screens/detail_member_screen.dart';
import 'features/absensi/screens/absensi_screen.dart';
import 'features/absensi/screens/riwayat_sekret_screen.dart';
import 'features/uang_khas/screens/uang_khas_screen.dart';
import 'features/menu/screens/menu_setelan_screen.dart';
import 'shared/widgets/bottom_nav_bar.dart';

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
              path: 'riwayat',
              builder: (_, _) => const RiwayatKegiatanScreen(),
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
          path: '/menu',
          builder: (_, _) => const MenuSetelanScreen(),
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

class _AppShell extends StatefulWidget {
  const _AppShell({required this.child});
  final Widget child;

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _navIndex = 0;

  // Index 0=Beranda, 1=Berita, 2=Kegiatan, 3=Menu
  static const _navRoutes = ['/', '/berita', '/kegiatan', '/menu'];

  void _onNavTap(int index) {
    if (_navIndex == index) return;
    setState(() => _navIndex = index);
    context.go(_navRoutes[index]);
  }

  void _onAbsensiTap() => context.go('/absensi');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFECEC),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              bottom: 96 + MediaQuery.of(context).padding.bottom,
              child: widget.child,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingBottomNavBar(
                currentIndex: _navIndex,
                onTap: _onNavTap,
                onAbsensiTap: _onAbsensiTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
