import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fortune_wheel/widgets/wheel_result_indicator.dart';
import 'package:fortune_wheel/widgets/wheel_slice.dart';
import '../painters/wheel_outline_painter.dart';
import 'fortune_wheel_child.dart';
import '../controller/fortune_wheel_controller.dart';

export 'fortune_wheel_child.dart';
export '../controller/fortune_wheel_controller.dart';

class FortuneWheel<T> extends StatefulWidget {
  FortuneWheel({
    required this.controller,
    this.turnsPerSecond = 8,
    this.rotationTimeLowerBound = 2000,
    this.rotationTimeUpperBound = 4000,
    required this.children
  }): assert(children.length > 1, 'List with at least two elements must be given');

  final FortuneWheelController<T> controller;
  final List<FortuneWheelChild<T>> children;
  final int turnsPerSecond;
  final int rotationTimeLowerBound;
  final int rotationTimeUpperBound;

  @override
  _FortuneWheelState createState() => _FortuneWheelState();
}

class _FortuneWheelState extends State<FortuneWheel> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late double size;

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _initiateAnimation();
    _initiateControllerSubscription();
    super.initState();
  }

  void _initiateAnimation() {
    _animationController = new AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: double.infinity
    );

    _animationController.value =  (0.5 / (widget.children.length));

    _animationController.addListener(() {
      widget.controller.setValue(
        widget.children[
          ((widget.children.length) * (_animationController.value % 1)).floor()
        ]
      );

      if (_animationController.isCompleted) {
        widget.controller.animationFinished();
      }
    });
  }

  void _initiateControllerSubscription() {
    widget.controller.addListener(() {
      if (!widget.controller.shouldStartAnimation || widget.controller.isAnimating)
        return;
    
      _startAnimation();
    });
  }

  void _startAnimation() {
    widget.controller.animationStarted();
        
    int milliseconds = Random().nextInt(widget.rotationTimeLowerBound) + (widget.rotationTimeUpperBound - widget.rotationTimeLowerBound);
    double rotateDistance = milliseconds / 1000 * widget.turnsPerSecond;
        
    _animationController.value = _animationController.value % 1;
        
    _animationController.duration = Duration(milliseconds: milliseconds.toInt());
        
    _animationController.animateTo(
      _animationController.value + rotateDistance,
      curve: Curves.easeInOut
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          size = min(constraints.maxHeight, constraints.maxWidth);

          return SizedBox(
            width: size,
            height: size,
            child: _getWheelContent(),
          );
        }
      ),
    );
  }

  Stack _getWheelContent() {
    return Stack(
      children: [
        _getSlices(),
        _getCircleOutline(),
        _getIndicator()
      ],
    );
  }

  WheelResultIndicator _getIndicator() => WheelResultIndicator(
    wheelSize: size,
    animationController: _animationController,
    childCount: widget.children.length
  );

  Widget _getSlices() {
    double fourthCircleAngle = pi / 2;
    double pieceAngle = pi * 2 / widget.children.length;

    return Stack(
      children: [
        for (int index = 0; index < widget.children.length; index++)
          Transform.rotate(
            angle: (-fourthCircleAngle) - (pieceAngle / 2),
            child: WheelSlice(
              index: index, size: size, fortuneWheelChildren: widget.children
            ),
          ),
      ],
    );
  }

  CustomPaint _getCircleOutline() {
    return CustomPaint(
      painter: WheelOutlinePainter(),
      size: Size(size, size),
    );
  }
}