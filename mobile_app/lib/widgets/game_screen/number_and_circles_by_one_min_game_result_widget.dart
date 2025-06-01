import 'package:flutter/material.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/utils/functions.dart';

class NumberAndCirclesByOneMinGameResultWidget extends StatelessWidget {
  const NumberAndCirclesByOneMinGameResultWidget({
    super.key,
    required this.functions,
    required this.oneMinGameResult,
  });

  final Functions functions;
  final OneMinGameResult oneMinGameResult;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          functions
              .getNumberByGameResult(
                oneMinGameResult: oneMinGameResult,
              )
              .toString(),
          style: AppConfigs.boldTextStyle,
        ),
        ...List.generate(
          functions
              .getListOfColorsByGameResult(
                oneMinGameResult: oneMinGameResult,
              )
              .length,
          (innerIndex) {
            return Icon(
              Icons.circle,
              size: AppConfigs.listWheelItemExtentHeight,
              color: functions.getListOfColorsByGameResult(
                oneMinGameResult: oneMinGameResult,
              )[innerIndex],
            );
          },
        ),
      ],
    );
  }
}
