import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/repositories/inbox_repository.dart';
import 'package:provider/provider.dart';

class FloatingAppBar extends StatelessWidget {
  const FloatingAppBar({
    super.key,
    this.title = 'CENTREPOINT',
    this.showBack = false,
    this.trailing,
    this.inboxCount,
  });

  final String title;
  final bool showBack;
  final Widget? trailing;
  /// Jumlah badge inbox. Null = ambil otomatis dari [InboxRepository].
  final int? inboxCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginPage,
        AppSpacing.marginPage,
        AppSpacing.marginPage,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.appbarPadding,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: const [AppColors.hardShadow],
        ),
        child: Row(
          children: [
            showBack
                ? _AppBarIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => context.canPop() ? context.pop() : context.go('/'),
                  )
                : _AppBarIconButton(
                    icon: Icons.menu,
                    onTap: () => Scaffold.of(context).openDrawer(),
                  ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            trailing ??
                _InboxBell(
                  count: inboxCount ??
                      context.select<InboxRepository, int>((r) => r.unreadCount),
                  onTap: () => context.push('/inbox'),
                ),
          ],
        ),
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radius * 4),
        ),
        child: Icon(icon, color: AppColors.onSurfaceVariant, size: 24),
      ),
    );
  }
}

class _InboxBell extends StatelessWidget {
  const _InboxBell({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.mail_outline,
                color: AppColors.onSurfaceVariant, size: 24),
            if (count > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: AppColors.onPrimaryContainer,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Header standar untuk halaman turunan yang memakai [Scaffold] sendiri:
/// tampilan sama dengan [FloatingAppBar] (tombol kembali + judul), dengan
/// [badgeCount] opsional di sisi kanan menggantikan ikon inbox.
class PageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PageAppBar({super.key, required this.title, this.badgeCount, this.trailing});

  final String title;
  final int? badgeCount;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(84);

  @override
  Widget build(BuildContext context) {
    Widget? right = trailing;
    if (right == null && badgeCount != null) {
      right = Padding(
        padding: const EdgeInsets.all(8),
        child: badgeCount! > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.blackCharcoal, width: 1.5),
                ),
                child: Text(
                  '$badgeCount',
                  style: AppTypography.labelBold.copyWith(color: AppColors.onPrimaryContainer),
                ),
              )
            : const SizedBox(width: 24),
      );
    }
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingAppBar(title: title, showBack: true, trailing: right),
      ),
    );
  }
}
