import 'package:flutter/widgets.dart';
import 'package:fortune_wheel/widgets/fortune_wheel.dart';

class FortuneWheelController extends ChangeNotifier {
  FortuneWheelChild value;

  bool isAnimating = false;
  bool shouldStartAnimation = false;
  
  void rotateTheWheel() {
    shouldStartAnimation = true;
    notifyListeners();
  }

  void animationStarted() {
    shouldStartAnimation = false;
    isAnimating = true;
  }

  void setValue(FortuneWheelChild fortuneWheelChild) {
    value = fortuneWheelChild;
    notifyListeners();
  }

  void animationFinished() {
    isAnimating = false;
    shouldStartAnimation = false;
    notifyListeners();
  }
}