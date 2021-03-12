import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../painters/wheel_outline_painter.dart';
import '../painters/wheel_slice_painter.dart';
import 'fortune_wheel_child.dart';
import '../controller/fortune_wheel_controller.dart';
import '../painters/triangle_painter.dart';

export 'fortune_wheel_child.dart';
export '../controller/fortune_wheel_controller.dart';

class FortuneWheel<T> extends StatefulWidget {
  FortuneWheel({
    @required this.controller,
    this.turnsPerSecond = 8,
    this.rotationTimeLowerBound = 2000,
    this.rotationTimeUpperBound = 4000,
    @required this.children
  }): assert(children != null && children.length > 1, 'List with at least two elements must be given');

  final FortuneWheelController controller;
  final List<FortuneWheelChild<T>> children;
  final int turnsPerSecond;
  final int rotationTimeLowerBound;
  final int rotationTimeUpperBound;

  @override
  _FortuneWheelState createState() => _FortuneWheelState();
}

class _FortuneWheelState extends State<FortuneWheel> with SingleTickerProviderStateMixin {
  FortuneWheelChild chosen;
  AnimationController _animationController;

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
      rotateDistance,
      curve: Curves.easeInOut
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double size = min(constraints.maxHeight, constraints.maxWidth);

          return SizedBox(
            width: size,
            height: size,
            child: _getStack(
              widget.children.map((e) => e.foreground).toList(),
              size
            ),
          );
        }
      ),
    );
  }

  Stack _getStack(List<Widget> items, double size) {
    double pieceWidth = items.length == 2 ? size : sin(pi / items.length) * size / 2;
    double pieceHeight = size / 2;

    List<Widget> pieces = [];

    items.asMap().forEach((index, element) {
      pieces.add(
        _getPiece(index, size, pieceWidth, pieceHeight)
      );
    });

    double fourthCircleAngle = pi / 2;
    double pieceAngle = pi * 2 / items.length;
    double indicatorSize = size / 10;
    Color indicatorColor = Colors.black;

    return Stack(
      children: [
        SizedBox(
          width: size / 6,
          height: size / 6,
          child: chosen == null ? Container() : chosen.foreground
        ),
        for (Widget piece in pieces)
          Transform.rotate(
            // TODO: Make first piece start on the top and icon appear in the center
            angle: (-fourthCircleAngle) - (pieceAngle / 2),
            child: piece,
          ),
        _getCircleOutline(size),
        _getCenterIndicatorCircle(indicatorColor, indicatorSize),
        _getCenterIndicatorTriangle(size, indicatorSize, indicatorColor),
      ],
    );
  }

  Positioned _getCenterIndicatorTriangle(double size, double indicatorSize, Color indicatorColor) {
    return Positioned(
      top: size / 2 - indicatorSize,
      left: size / 2 - (indicatorSize / 2),
      child: AnimatedBuilder(
        builder: (BuildContext context, Widget child) {
          return Transform.rotate(
            origin: Offset(0, indicatorSize / 2),
            angle: (_animationController.value * pi * 2) - (pi / (widget.children.length)),
            child: CustomPaint(
              painter: TrianglePainter(
                strokeColor: indicatorColor,
                strokeWidth: 10,
                paintingStyle: PaintingStyle.fill,
              ),
              size: Size(indicatorSize, indicatorSize)
            ),
          );
        },
        animation: _animationController,
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

  CustomPaint _getCircleOutline(double size) {
    return CustomPaint(
      painter: WheelOutlinePainter(),
      size: Size(size, size),
    );
  }

  Widget _getPiece(int index, double size, double pieceWidth, double pieceHeight) {
    double leftRotationOffset = (-pi / 2);
    double pieceAngle = (index / widget.children.length * pi * 2);
    double centerOffset = (pi / widget.children.length);

    return Stack(
      children: [
        Transform.rotate(
          angle: pieceAngle,
          alignment: Alignment.center,
          child: Stack(
            children: [
              Container(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: WheelSlicePainter(
                    divider: widget.children.length,
                    number: index,
                    color: widget.children[index].background
                  ),
                  size: Size(size, size),
                ),
              ),
            ],
          ),
        ),
        Transform.rotate(
          angle: leftRotationOffset + pieceAngle + centerOffset,
          alignment: Alignment.center,
          child: Stack(
            children: [
              Positioned(
                top: size / 2,
                left: size / 2 - pieceWidth / 2,
                child: Container(
                  padding: EdgeInsets.all(size / widget.children.length / 4),
                  //color: Colors.green.withOpacity(0.2),
                  height: pieceHeight,
                  width: pieceWidth,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Transform.rotate(
                      angle: -pieceAngle - leftRotationOffset * 2,
                      child: widget.children[index].foreground
                    )
                  ),
                )
              ),
            ],
          ),
        ),
      ],
    );
  }
}