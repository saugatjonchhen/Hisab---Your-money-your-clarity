import 'package:finance_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HisabLogo extends StatelessWidget {
  final double size;
  final bool showShadow;

  const HisabLogo({
    super.key,
    this.size = 120,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: CustomPaint(
        painter: _HisabLogoPainter(),
      ),
    );
  }
}

class _HisabLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw left half (purple gradient - income)
    final leftRect = Rect.fromCircle(center: center, radius: radius);
    final leftGradient = const LinearGradient(
      colors: [Color(0xFF10B981), Color(0xFF059669)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final leftPaint = Paint()
      ..shader = leftGradient.createShader(leftRect)
      ..style = PaintingStyle.fill;

    final leftPath = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..arcToPoint(
        Offset(center.dx, center.dy + radius),
        radius: Radius.circular(radius),
        clockwise: false,
      )
      ..lineTo(center.dx, center.dy - radius)
      ..close();

    canvas.drawPath(leftPath, leftPaint);

    // Draw right half (teal - expense)
    final rightPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    final rightPath = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..arcToPoint(
        Offset(center.dx, center.dy + radius),
        radius: Radius.circular(radius),
        clockwise: true,
      )
      ..lineTo(center.dx, center.dy - radius)
      ..close();

    canvas.drawPath(rightPath, rightPaint);

    // Draw "H" in negative space (white)
    final hPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // H dimensions (proportional to logo size)
    final hWidth = size.width * 0.45;
    final hHeight = size.height * 0.5;
    final strokeWidth = size.width * 0.12;
    final hLeft = center.dx - hWidth / 2;
    final hTop = center.dy - hHeight / 2;

    // Left vertical bar of H
    final leftBar = RRect.fromRectAndRadius(
      Rect.fromLTWH(hLeft, hTop, strokeWidth, hHeight),
      Radius.circular(strokeWidth / 2),
    );
    canvas.drawRRect(leftBar, hPaint);

    // Right vertical bar of H
    final rightBar = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        hLeft + hWidth - strokeWidth,
        hTop,
        strokeWidth,
        hHeight,
      ),
      Radius.circular(strokeWidth / 2),
    );
    canvas.drawRRect(rightBar, hPaint);

    // Horizontal bar of H (middle)
    final horizontalBar = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        hLeft,
        center.dy - strokeWidth / 2,
        hWidth,
        strokeWidth,
      ),
      Radius.circular(strokeWidth / 2),
    );
    canvas.drawRRect(horizontalBar, hPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
