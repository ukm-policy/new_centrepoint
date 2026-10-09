import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/session/app_session.dart';
import '../../../shared/widgets/floating_app_bar.dart';
import '../../../shared/widgets/my_divider.dart';
import '../../../core/errors/app_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../core/env/env.dart';
import '../../../data/repositories/inbox_repository.dart';
import '../../../shared/utils/feedback.dart';

class MenuSetelanScreen extends StatelessWidget {
  const MenuSetelanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: FloatingAppBar(title: 'Menu')),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginPage, AppSpacing.stackGap,
            AppSpacing.marginPage, AppSpacing.stackGap,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
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
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(AppSession.nama,
                      style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.w800)),
                    Text(AppSession.jabatan,
                      style: AppTypography.bodyMd.copyWith(color: AppColors.tertiary)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                      border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                    ),
                    child: Text('Lv. ${AppSession.level}',
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
                  onTap: () => context.push('/profil/edit'),
                ),
                _MenuItem(
                  icon: Icons.workspace_premium_outlined,
                  label: 'Poin Keaktifan',
                  onTap: () => context.push('/poin'),
                ),
                _MenuItem(
                  icon: Icons.shield_outlined,
                  label: 'Privasi & Keamanan',
                  onTap: () => _showPrivasiSheet(context),
                ),
              ]),
              const SizedBox(height: AppSpacing.stackGap),

              _MenuGroup(title: 'Aplikasi', items: [
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifikasi',
                  onTap: () => context.push('/menu/notifikasi'),
                  trailing: const _NotifBadge(),
                ),
                const _MenuItem(
                  icon: Icons.language,
                  label: 'Bahasa',
                  trailingText: 'Indonesia',
                ),
              ]),
              const SizedBox(height: AppSpacing.stackGap),

              _MenuGroup(title: 'Informasi', items: [
                _MenuItem(
                  icon: Icons.info_outline,
                  label: 'Tentang Aplikasi',
                  onTap: () => context.push('/menu/tentang'),
                  trailingText: 'v1.0.0',
                ),
                _MenuItem(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Kebijakan Privasi',
                  onTap: () => context.push('/menu/privasi'),
                ),
              ]),
              const SizedBox(height: AppSpacing.stackGap),

              // Logout
              GestureDetector(
                onTap: () async {
                  try {
                    await Supabase.instance.client.auth.signOut();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal keluar: ${friendlyError(e)}',
                              style: AppTypography.bodyMd.copyWith(color: Colors.white)),
                          backgroundColor: AppColors.error,
                          margin: const EdgeInsets.all(AppSpacing.marginPage),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
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
            ]),
          ),
        ),
      ],
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
    this.onTap,
    this.trailing,
    this.trailingText,
  });
  final IconData icon;
  final String label;

  /// Null = item informasi saja (tanpa panah).
  final VoidCallback? onTap;
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
          if (onTap != null) ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.tertiary),
          ],
        ]),
      ),
    );
  }
}

class _NotifBadge extends StatelessWidget {
  const _NotifBadge();

  @override
  Widget build(BuildContext context) {
    final count = context.select<InboxRepository, int>((r) => r.unreadCount);
    if (count == 0) return const SizedBox.shrink();
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

void _showPrivasiSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Container(
      margin: const EdgeInsets.all(AppSpacing.marginPage),
      padding: const EdgeInsets.all(AppSpacing.innerPadding + 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.blackCharcoal, width: 2),
        boxShadow: const [AppColors.hardShadow],
      ),
      child: SafeArea(
        top: false,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Privasi & Keamanan', style: AppTypography.headlineSm),
          const SizedBox(height: 8),
          const MyDivider(color: AppColors.borderSlate),
          _MenuItem(
            icon: Icons.lock_reset,
            label: 'Ubah Password',
            onTap: () {
              Navigator.pop(sheetContext);
              final email = AppSession.email;
              runWithFeedback(
                context,
                () => Supabase.instance.client.auth.resetPasswordForEmail(
                  email,
                  redirectTo: kIsWeb ? null : Env.authRedirectUrl,
                ),
                success: 'Link ubah password telah dikirim ke $email',
                errorPrefix: 'Gagal mengirim link',
              );
            },
          ),
          _MenuItem(
            icon: Icons.privacy_tip_outlined,
            label: 'Kebijakan Privasi',
            onTap: () {
              Navigator.pop(sheetContext);
              context.push('/menu/privasi');
            },
          ),
        ]),
      ),
    ),
  );
}

