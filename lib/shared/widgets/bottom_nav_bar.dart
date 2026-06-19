import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class FloatingBottomNavBar extends StatelessWidget {
  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAbsensiTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAbsensiTap;

  // 4 nav items, index 0-3
  static const _leftItems = [
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Beranda', index: 0),
    (icon: Icons.newspaper_outlined, activeIcon: Icons.newspaper, label: 'Berita', index: 1),
  ];
  static const _rightItems = [
    (icon: Icons.event_note_outlined, activeIcon: Icons.event_note, label: 'Kegiatan', index: 2),
    (icon: Icons.menu, activeIcon: Icons.menu, label: 'Menu', index: 3),
  ];

  @override
  Widget build(BuildContext context) {
    final sysBottom = MediaQuery.of(context).padding.bottom;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.marginPage + sysBottom),
        child: SizedBox(
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Pill container
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                    border: Border.all(color: AppColors.blackCharcoal, width: 2),
                    boxShadow: const [AppColors.hardShadow],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Left items
                      ..._leftItems.map((item) => _NavItem(
                        icon: item.icon,
                        activeIcon: item.activeIcon,
                        label: item.label,
                        isActive: currentIndex == item.index,
                        onTap: () => onTap(item.index),
                      )),

                      // Center gap for Absensi FAB
                      const SizedBox(width: 72),

                      // Right items
                      ..._rightItems.map((item) => _NavItem(
                        icon: item.icon,
                        activeIcon: item.activeIcon,
                        label: item.label,
                        isActive: currentIndex == item.index,
                        onTap: () => onTap(item.index),
                      )),
                    ],
                  ),
                ),
              ),

              // Absensi FAB — protrudes above the pill
              Positioned(
                bottom: 20,
                child: _AbsensiFab(onTap: onAbsensiTap),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Nav Item ─────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon, activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive
                  ? AppColors.onSecondaryContainer
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelBold.copyWith(
                fontSize: 10,
                color: isActive
                    ? AppColors.onSecondaryContainer
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Absensi FAB ───────────────────────────────────────────────────────────────

class _AbsensiFab extends StatefulWidget {
  const _AbsensiFab({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_AbsensiFab> createState() => _AbsensiFabState();
}

class _AbsensiFabState extends State<_AbsensiFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _pressed
            ? Matrix4.translationValues(3, 3, 0)
            : Matrix4.identity(),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.blackCharcoal, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackCharcoal,
              offset: _pressed ? const Offset(1, 1) : const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Icon(
          Icons.qr_code_scanner,
          color: AppColors.onPrimaryContainer,
          size: 28,
        ),
      ),
    );
  }
}
