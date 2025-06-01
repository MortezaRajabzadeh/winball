import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:user_bet_repository/user_bet_repository.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/utils/functions.dart';

class GameRecordsItemTileWidget extends StatelessWidget {
  const GameRecordsItemTileWidget({
    super.key,
    required this.userBet,
    required this.functions,
    required this.userBetOptions,
    required this.oneMinGameResult,
  });

  final UserBetModel userBet;
  final Functions functions;
  final List<UserBetOptions> userBetOptions;
  final OneMinGameResult oneMinGameResult;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppConfigs.appShadowColor,
      child: Padding(
        padding: const EdgeInsets.all(
          AppConfigs.mediumVisualDensity,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              userBet.endGameResult.convertToNum.toStringAsFixed(2),
              style: userBet.endGameResult.convertToNum > 0
                  ? AppConfigs.titleGreenTextStyle
                  : AppConfigs.titleTextStyle,
            ),
            ListTile(
              leading: const Text(
                AppTexts.game,
              ),
              trailing:
                  Text('${AppTexts.gameType}${userBet.game.gameType.name}'),
            ),
            ListTile(
              leading: const Text(
                AppTexts.randomNo,
              ),
              trailing: Text(userBet.game.eachGameUniqueNumber.toString()),
            ),
            ListTile(
              leading: const Text(
                AppTexts.orderTime,
              ),
              trailing: Text(
                functions.convertDateTimeToDateAndTime(
                  dateTime: userBet.createdAt,
                ),
              ),
            ),
            ListTile(
              leading: const Text(
                AppTexts.bettingOptions,
              ),
              trailing: RichText(
                text: TextSpan(
                  children: List.generate(
                    userBetOptions.length,
                    (index) {
                      return TextSpan(
                        text: '${userBetOptions[index].name} ',
                        style: TextStyle(
                          color: functions.isColorExistsInGameResult(
                            userBetOptions: userBetOptions[index],
                            oneMinGameResult: oneMinGameResult,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Text(
                AppTexts.gameResult,
              ),
              trailing: Text(
                userBet.game.gameResult?.name ?? '',
                style: AppConfigs.timerWhiteTextStyle,
              ),
            ),
            ListTile(
              leading: const Text(
                AppTexts.totalAmount,
              ),
              trailing: Text(
                userBet.amount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
