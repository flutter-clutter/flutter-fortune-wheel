import 'package:flutter/widgets.dart';

class FortuneWheelChild<T> {
  FortuneWheelChild({
    required this.foreground,
    this.background,
    required this.value
  });

  final Widget foreground;
  final Color? background;
  final T value;
}