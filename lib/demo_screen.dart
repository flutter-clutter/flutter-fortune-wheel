import 'package:flutter/material.dart';

import 'widgets/fortune_wheel.dart';

class DemoScreen extends StatefulWidget {
  @override
  _DemoScreenState createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  FortuneWheelController<int> fortuneWheelController = FortuneWheelController();
  FortuneWheelChild? currentWheelChild;
  int currentBalance = 0;

  @override
  void initState() {
    fortuneWheelController.addListener(() {
      if (fortuneWheelController.value == null)
        return;

      setState(() {
        currentWheelChild = fortuneWheelController.value;
      });

      if (fortuneWheelController.isAnimating)
        return;

      if (fortuneWheelController.shouldStartAnimation)
        return;

      setState(() {
        currentBalance += fortuneWheelController.value!.value;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: currentBalance.isNegative ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(16)
                  ),
                  child: Text(
                    'Current balance: $currentBalance €',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18
                    ),
                  ),
                ),
                SizedBox(height: 24,),
                Divider(color: Colors.black87,),
                SizedBox(height: 16,),
                Container(
                  height: 80,
                  width: 80,
                  child: currentWheelChild != null ? currentWheelChild!.foreground : Container(),
                ),
                SizedBox(height: 16,),
                SizedBox(
                    width: 350,
                    height: 350,
                    child: FortuneWheel<int>(
                      controller: fortuneWheelController,
                      children: [
                        _createFortuneWheelChild(-50),
                        _createFortuneWheelChild(1000),
                        _createFortuneWheelChild(-50),
                        _createFortuneWheelChild(-500),
                        _createFortuneWheelChild(-100),
                      ],
                    )
                ),
                SizedBox(height: 24),
                ElevatedButton(
                    onPressed: () => fortuneWheelController.rotateTheWheel(),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('ROTATE', style: TextStyle(fontWeight: FontWeight.bold),),
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  FortuneWheelChild<int> _createFortuneWheelChild(int value) {
    Color color = value.isNegative ? Colors.red : Colors.green;
    String verb = value.isNegative ? 'Lose' : 'Win';
    int valueString = value.abs();

    return FortuneWheelChild(
        foreground: _getWheelContentCircle(color, '$verb\n$valueString €'),
        value: value
    );
  }

  Container _getWheelContentCircle(Color backgroundColor, String text) {
    return Container(
      width: 72,
      height: 72,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.white.withOpacity(0.8),
              width: 4
          )
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}