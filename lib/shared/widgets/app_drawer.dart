import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/session/app_session.dart';
import '../../data/repositories/member_repository.dart';
import 'my_divider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;

    return Drawer(
      width: 300,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgGray,
          border: Border(
            right: BorderSide(color: AppColors.blackCharcoal, width: 2.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackCharcoal,
              offset: Offset(6, 0),
              blurRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              _DrawerHeader(),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
                child: MyDivider(color: AppColors.blackCharcoal, height: 1),
              ),
              const SizedBox(height: 8),

              // ── Nav Items ─────────────────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.marginPage,
                    vertical: 4,
                  ),
                  children: [
                    _DrawerSection(label: 'UTAMA'),
                    _DrawerItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Beranda',
                      route: '/',
                      currentRoute: currentRoute,
                    ),
                    _DrawerItem(
                      icon: Icons.newspaper_outlined,
                      activeIcon: Icons.newspaper,
                      label: 'Berita',
                      route: '/berita',
                      currentRoute: currentRoute,
                    ),
                    _DrawerItem(
                      icon: Icons.event_note_outlined,
                      activeIcon: Icons.event_note,
                      label: 'Kegiatan',
                      route: '/kegiatan',
                      currentRoute: currentRoute,
                    ),
                    const SizedBox(height: 12),
                    _DrawerSection(label: 'FITUR'),
                    _DrawerItem(
                      icon: Icons.qr_code_scanner_outlined,
                      activeIcon: Icons.qr_code_scanner,
                      label: 'Absensi',
                      route: '/absensi',
                      currentRoute: currentRoute,
                    ),
                    _DrawerItem(
                      icon: Icons.account_balance_wallet_outlined,
                      activeIcon: Icons.account_balance_wallet,
                      label: 'Uang Khas',
                      route: '/uang-khas',
                      currentRoute: currentRoute,
                    ),
                    _DrawerItem(
                      icon: Icons.groups_outlined,
                      activeIcon: Icons.groups,
                      label: 'Anggota',
                      route: '/anggota',
                      currentRoute: currentRoute,
                    ),
                    _DrawerItem(
                      icon: Icons.workspace_premium_outlined,
                      activeIcon: Icons.workspace_premium,
                      label: 'Poin Keaktifan',
                      route: '/poin',
                      currentRoute: currentRoute,
                    ),
                    const SizedBox(height: 12),
                    _DrawerSection(label: 'LAINNYA'),
                    _DrawerItem(
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings,
                      label: 'Setelan',
                      route: '/menu',
                      currentRoute: currentRoute,
                    ),
                  ],
                ),
              ),

              // ── Footer / Logout ───────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.marginPage),
                child: MyDivider(color: AppColors.blackCharcoal, height: 1),
              ),
              _DrawerLogout(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final members = context.watch<MemberRepository>().members;
    final currentMember = members.isNotEmpty
        ? members.firstWhere(
            (m) => m.nama == AppSession.nama,
            orElse: () => members.first,
          )
        : null;

    final tier = currentMember?.tier ?? 'General';
    final poin = currentMember?.totalPoin ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginPage, AppSpacing.marginPage,
        AppSpacing.marginPage, 12,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Brand
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: AppColors.blackCharcoal, width: 2),
              boxShadow: const [AppColors.hardShadowSm],
            ),
            child: Text(
              'UKM POLICY',
              style: AppTypography.labelBold.copyWith(
                color: AppColors.onPrimaryContainer,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
                border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
              ),
              child: const Icon(Icons.close, size: 16, color: AppColors.onSurface),
            ),
          ),
        ]),
        const SizedBox(height: 20),

        // User avatar + info
        Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.blackCharcoal, width: 2.5),
              boxShadow: const [AppColors.hardShadowSm],
            ),
            child: AppSession.currentUser.avatarUrl != null &&
                    AppSession.currentUser.avatarUrl!.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: AppSession.currentUser.avatarUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        size: 30,
                        color: AppColors.tertiary,
                      ),
                    ),
                  )
                : const Icon(Icons.person, size: 30, color: AppColors.tertiary),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              AppSession.nama,
              style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              AppSession.jabatan,
              style: AppTypography.labelBold.copyWith(color: AppColors.tertiary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ])),
        ]),
        const SizedBox(height: 12),

        // Badges
        Row(children: [
          _Badge(
            icon: Icons.star,
            label: tier,
            color: AppColors.secondaryContainer,
            textColor: AppColors.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          _Badge(
            icon: Icons.monetization_on,
            label: '$poin Pts',
            color: AppColors.errorContainer,
            textColor: AppColors.error,
          ),
        ]),
      ]),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _DrawerSection extends StatelessWidget {
  const _DrawerSection({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        label,
        style: AppTypography.labelBold.copyWith(
          color: AppColors.tertiary,
          fontSize: 10,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.currentRoute,
  });

  final IconData icon, activeIcon;
  final String label, route, currentRoute;

  // Hanya 4 tab bottom nav yang pakai go(); sisanya push() agar back berfungsi
  static const _tabRoutes = {'/', '/kegiatan', '/fitur', '/menu'};

  bool get _isActive {
    if (route == '/') return currentRoute == '/';
    return currentRoute.startsWith(route);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
          if (_tabRoutes.contains(route)) {
            context.go(route);
          } else {
            context.push(route);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: _isActive
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(
              color: _isActive ? AppColors.blackCharcoal : AppColors.borderSlate,
              width: _isActive ? 2 : 1.5,
            ),
            boxShadow: _isActive ? const [AppColors.hardShadowSm] : null,
          ),
          child: Row(children: [
            Icon(
              _isActive ? activeIcon : icon,
              size: 20,
              color: _isActive
                  ? AppColors.onPrimaryContainer
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLg.copyWith(
                  fontWeight: _isActive ? FontWeight.w700 : FontWeight.w500,
                  color: _isActive
                      ? AppColors.onPrimaryContainer
                      : AppColors.onSurface,
                ),
              ),
            ),
            if (_isActive)
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.onPrimaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

// ── Logout ────────────────────────────────────────────────────────────────────

class _DrawerLogout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginPage, 12,
        AppSpacing.marginPage, 0,
      ),
      child: GestureDetector(
        onTap: () async {
          Navigator.of(context).pop();
          try {
            await Supabase.instance.client.auth.signOut();
            if (context.mounted) {
              context.go('/login');
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal keluar: $e',
                      style: AppTypography.bodyMd.copyWith(color: Colors.white)),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(AppSpacing.marginPage),
                ),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.errorContainer,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(color: AppColors.blackCharcoal, width: 2),
            boxShadow: const [AppColors.hardShadowSm],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.logout, size: 18, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'Keluar',
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Badge Helper ──────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
  });
  final IconData icon;
  final String label;
  final Color color, textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
        boxShadow: const [AppColors.hardShadowSm],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: textColor),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.labelBold.copyWith(color: textColor)),
      ]),
    );
  }
}
