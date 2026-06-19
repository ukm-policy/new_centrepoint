import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

enum BrutalistButtonVariant { primary, secondary }

class BrutalistButton extends StatefulWidget {
  const BrutalistButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BrutalistButtonVariant.primary,
    this.icon,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final BrutalistButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;

  @override
  State<BrutalistButton> createState() => _BrutalistButtonState();
}

class _BrutalistButtonState extends State<BrutalistButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.variant == BrutalistButtonVariant.primary;

    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _pressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _pressed
            ? Matrix4.translationValues(3.0, 3.0, 0)
            : Matrix4.identity(),
        width: widget.fullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryContainer : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackCharcoal,
              offset: _pressed ? const Offset(1, 1) : const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.label,
              style: AppTypography.headlineSm.copyWith(
                color: isPrimary ? AppColors.onPrimaryContainer : AppColors.blackCharcoal,
              ),
            ),
            if (widget.icon != null) ...[
              const SizedBox(width: 8),
              Icon(
                widget.icon,
                color: isPrimary ? AppColors.onPrimaryContainer : AppColors.blackCharcoal,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
