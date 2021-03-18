import 'package:flutter/material.dart';

class WheelOutlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint strokePaint = Paint();

    double strokeWidth = size.width / 25;

    strokePaint.color = Colors.white.withOpacity(0.33);
    strokePaint.strokeWidth = strokeWidth;
    strokePaint.style = PaintingStyle.stroke;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      (size.height / 2) - strokeWidth / 2,
      strokePaint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}