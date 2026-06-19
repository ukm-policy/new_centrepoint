import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class BrutalistCard extends StatefulWidget {
  const BrutalistCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;

  @override
  State<BrutalistCard> createState() => _BrutalistCardState();
}

class _BrutalistCardState extends State<BrutalistCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ??
        BorderRadius.circular(AppSpacing.radiusLg);

    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _pressed
            ? Matrix4.translationValues(3.0, 3.0, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppColors.surfaceContainerLowest,
          borderRadius: radius,
          border: Border.all(color: AppColors.blackCharcoal, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackCharcoal,
              offset: _pressed ? const Offset(1, 1) : const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: widget.padding != null
              ? Padding(padding: widget.padding!, child: widget.child)
              : widget.child,
        ),
      ),
    );
  }
}
