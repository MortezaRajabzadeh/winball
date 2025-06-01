import 'package:flutter/material.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/utils/functions.dart';

class OneMinGameTimerValueNotifierWidget extends StatelessWidget {
  const OneMinGameTimerValueNotifierWidget({
    super.key,
    required this.currentGameTimerValueNotifier,
    required this.functions,
  });

  final ValueNotifier<int> currentGameTimerValueNotifier;
  final Functions functions;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: currentGameTimerValueNotifier,
      builder: (context, remainsTimer, _) {
        return Text(
          functions.convertSecondsToHoursAndMinutes(
            seconds: remainsTimer,
          ),
          style: remainsTimer <= 15
              ? AppConfigs.timerRedTextStyle
              : AppConfigs.timerWhiteTextStyle,
        );
      },
    );
  }
}
