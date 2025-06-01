import 'package:flutter/material.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:winball/utils/functions.dart';
import 'package:winball/widgets/widgets.dart';

class OldOneMinGameDetailsWidget extends StatelessWidget {
  const OldOneMinGameDetailsWidget({
    super.key,
    required this.isLoadingValueNotifier,
    required this.oneLastOneMinGameModelValueNotifier,
    required this.listWheelScrollController,
    required this.functions,
    required this.scrollListWheelScrollControllerByGameResult,
  });
  final void Function({required OneMinGameResult gameResult})
      scrollListWheelScrollControllerByGameResult;

  final ValueNotifier<bool> isLoadingValueNotifier;
  final ValueNotifier<OneMinGameModel> oneLastOneMinGameModelValueNotifier;
  final ScrollController listWheelScrollController;
  final Functions functions;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoadingValueNotifier,
      builder: (context, isLoading, child) {
        return isLoading ? const LoadingWidget() : child!;
      },
      child: ValueListenableBuilder<OneMinGameModel>(
        valueListenable: oneLastOneMinGameModelValueNotifier,
        builder: (context, oneMinGame, _) {
          final OneMinGameResult? result = oneMinGame.gameResult;
          return OldGameResultListTileWidget(
            result: result,
            oldOneMinGameId: oneMinGame.eachGameUniqueNumber,
            scrollListWheelScrollControllerByGameResult:
                scrollListWheelScrollControllerByGameResult,
            listWheelScrollController: listWheelScrollController,
            functions: functions,
          );
        },
      ),
    );
  }
}
