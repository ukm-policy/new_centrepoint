import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MyDivider extends StatelessWidget {
  const MyDivider({super.key, this.color, this.height = 16});

  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: CustomPaint(
          size: Size(double.infinity, 2),
          painter: _DashedLinePainter(color: color ?? AppColors.borderSlate),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double startX = 0;
    const dashWidth = 8.0;
    const dashSpace = 4.0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
