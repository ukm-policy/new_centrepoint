import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/my_divider.dart';

class MenuSetelanScreen extends StatelessWidget {
  const MenuSetelanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        backgroundColor: AppColors.bgGray,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Menu', style: AppTypography.headlineSm),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginPage, 8, AppSpacing.marginPage, AppSpacing.stackGap,
        ),
        children: [
          // User mini card
          Container(
            padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.blackCharcoal, width: 2),
              boxShadow: const [AppColors.hardShadow],
            ),
            child: Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.blackCharcoal, width: 2),
                  boxShadow: const [AppColors.hardShadowSm],
                ),
                child: const Icon(Icons.person, size: 30, color: AppColors.tertiary),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ahmad Ridhwan',
                  style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
                Text('Senior Policy Analyst',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                  border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                ),
                child: Text('Gold',
                  style: AppTypography.labelBold.copyWith(
                      color: AppColors.onSecondaryContainer)),
              ),
            ]),
          ),
          const SizedBox(height: AppSpacing.stackGap),

          // Menu groups
          _MenuGroup(title: 'Akun', items: [
            _MenuItem(
              icon: Icons.person_outline,
              label: 'Edit Profil',
              onTap: () => context.go('/anggota/me'),
            ),
            _MenuItem(
              icon: Icons.shield_outlined,
              label: 'Privasi & Keamanan',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: AppSpacing.stackGap),

          _MenuGroup(title: 'Aplikasi', items: [
            _MenuItem(
              icon: Icons.notifications_outlined,
              label: 'Notifikasi',
              onTap: () {},
              trailing: _NotifBadge(count: 3),
            ),
            _MenuItem(
              icon: Icons.language,
              label: 'Bahasa',
              onTap: () {},
              trailingText: 'Indonesia',
            ),
          ]),
          const SizedBox(height: AppSpacing.stackGap),

          _MenuGroup(title: 'Informasi', items: [
            _MenuItem(
              icon: Icons.info_outline,
              label: 'Tentang Aplikasi',
              onTap: () {},
              trailingText: 'v1.0.0',
            ),
            _MenuItem(
              icon: Icons.help_outline,
              label: 'Bantuan & FAQ',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.description_outlined,
              label: 'Syarat & Ketentuan',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: AppSpacing.stackGap),

          // Logout
          GestureDetector(
            onTap: () => context.go('/login'),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.blackCharcoal, width: 2),
                boxShadow: const [AppColors.hardShadow],
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.logout, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Text('Keluar',
                  style: AppTypography.headlineSm.copyWith(color: AppColors.error)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.title, required this.items});
  final String title;
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
        boxShadow: const [AppColors.hardShadow],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Text(title,
            style: AppTypography.labelBold.copyWith(color: AppColors.tertiary, letterSpacing: 1)),
        ),
        const MyDivider(color: AppColors.borderSlate, height: 1),
        ...List.generate(items.length, (i) {
          final item = items[i];
          return Column(children: [
            item,
            if (i < items.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: MyDivider(color: AppColors.borderSlate, height: 1),
              ),
          ]);
        }),
      ]),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.trailingText,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Icon(icon, size: 22, color: AppColors.onSurface),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: AppTypography.bodyLg)),
          ?trailing,
          if (trailingText != null)
            Text(trailingText!,
              style: AppTypography.labelBold.copyWith(color: AppColors.tertiary)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.tertiary),
        ]),
      ),
    );
  }
}

class _NotifBadge extends StatelessWidget {
  const _NotifBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
        border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
      ),
      child: Text('$count',
        style: AppTypography.labelBold.copyWith(color: AppColors.onPrimaryContainer)),
    );
  }
}
