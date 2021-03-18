import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fortune_wheel/painters/triangle_painter.dart';

class WheelResultIndicator extends StatelessWidget {
  WheelResultIndicator({
    required this.wheelSize,
    required this.animationController,
    required this.childCount
  });

  final double wheelSize;
  final AnimationController animationController;
  final int childCount;

  @override
  Widget build(BuildContext context) {

    double indicatorSize = wheelSize / 10;
    Color indicatorColor = Colors.black;

    return Stack(
      children: [
        _getCenterIndicatorCircle(indicatorColor, indicatorSize),
        _getCenterIndicatorTriangle(wheelSize, indicatorSize, indicatorColor),
      ],
    );
  }

  Positioned _getCenterIndicatorTriangle(double wheelSize, double indicatorSize, Color indicatorColor) {
    return Positioned(
      top: wheelSize / 2 - indicatorSize,
      left: wheelSize / 2 - (indicatorSize / 2),
      child: AnimatedBuilder(
        builder: (BuildContext context, Widget? child) {
          return Transform.rotate(
            origin: Offset(0, indicatorSize / 2),
            angle: (animationController.value * pi * 2) - (pi / (childCount)),
            child: CustomPaint(
              painter: TrianglePainter(
                fillColor: indicatorColor,
              ),
              size: Size(indicatorSize, indicatorSize)
            ),
          );
        },
        animation: animationController,
      ),
    );
  }

  Center _getCenterIndicatorCircle(Color indicatorColor, double indicatorSize) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: indicatorColor,
        ),
        width: indicatorSize,
        height: indicatorSize,
      )
    );
  }
}