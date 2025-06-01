import 'package:flutter/material.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/widgets/global/game_thumb_item_tile_widget.dart';

class ListOfGamesScreen extends StatelessWidget {
  const ListOfGamesScreen({super.key});

  // تابع برای انتخاب تصویر مناسب هر بازی بر اساس نوع آن
  String getGameImage(GameType gameType) {
    switch (gameType) {
      case GameType.one_min_game:
        return AppConfigs.oneMinGameImage;
      case GameType.three_min_game:
        return AppConfigs.threeMinGameImage;
      case GameType.five_min_game:
        return AppConfigs.fiveMinGameImage;
      default:
        return AppConfigs.oneMinGameImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.games),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConfigs.largeVisualDensity,
          horizontal: AppConfigs.mediumVisualDensity,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppConfigs.appShadowColor,
            borderRadius: BorderRadius.circular(
              AppConfigs.mediumVisualDensity,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppConfigs.mediumVisualDensity,
              horizontal: AppConfigs.largeVisualDensity,
            ),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: AppConfigs.listOfGames.length,
              itemBuilder: (context, index) {
                final GameType gameType = AppConfigs.listOfGames.values.elementAt(index);
                return GameThumbItemTileWidget(
                  gameType: gameType,
                  gameName: AppTexts.oneMinGame,
                  imagePath: getGameImage(gameType),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
