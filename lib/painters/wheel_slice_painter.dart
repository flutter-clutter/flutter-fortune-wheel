import 'package:flutter/material.dart';
import 'dart:math';

class WheelSlicePainter extends CustomPainter {
  WheelSlicePainter({
    required this.divider,
    required this.number,
    required this.color
  });

  final int divider;
  final int number;
  final Color? color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint fillPaint = Paint()..color = color != null ? color! : Color.lerp(Colors.red, Colors.orange, number / (divider -1))!;
    Paint strokePaint = Paint();

    final double angleWidth = pi * 2 / divider;

    strokePaint.color = Colors.white.withOpacity(0.2);
    strokePaint.strokeWidth = 2;
    strokePaint.style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        height: size.height,
        width: size.width,
      ),
      0,
      angleWidth,
      true,
      fillPaint,
    );


    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        height: size.height,
        width: size.width,
      ),
      0,
      angleWidth,
      true,
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}