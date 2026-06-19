import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class FloatingAppBar extends StatelessWidget {
  const FloatingAppBar({
    super.key,
    this.title = 'POLICY CENTREPOINT',
    this.showBack = false,
    this.onProfileTap,
    this.trailing,
  });

  final String title;
  final bool showBack;
  final VoidCallback? onProfileTap;
  final Widget? trailing;

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
                    onTap: () => Navigator.of(context).pop(),
                  )
                : _AppBarIconButton(
                    icon: Icons.menu,
                    onTap: () => Scaffold.of(context).openDrawer(),
                  ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            trailing ??
                _AppBarIconButton(
                  icon: Icons.account_circle_outlined,
                  onTap: onProfileTap,
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
