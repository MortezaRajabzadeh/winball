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
      case GameType.red_black_30s:
        return AppConfigs.redBlack30sImage;
      case GameType.red_black_1min:
        return AppConfigs.redBlack1MinImage;
      case GameType.red_black_3min:
        return AppConfigs.redBlack3MinImage;
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
        padding: const EdgeInsets.all(16), // استاندارد Material Design برای حاشیه‌ها
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppConfigs.appShadowColor,
            borderRadius: BorderRadius.circular(16), // استاندارد Material Design برای گرد‌کردن گوشه‌ها
          ),
          child: Padding(
            padding: const EdgeInsets.all(16), // پدینگ داخلی استاندارد
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16, // فاصله استاندارد بین ردیف‌ها
                crossAxisSpacing: 16, // فاصله استاندارد بین ستون‌ها
                childAspectRatio: 0.85, // نسبت عرض به ارتفاع بهینه برای نمایش آیکون و متن
              ),
              itemCount: AppConfigs.listOfGames.length,
              itemBuilder: (context, index) {
                final GameType gameType = AppConfigs.listOfGames.values.elementAt(index);
                final String gameName = AppConfigs.listOfGames.entries
                  .firstWhere((entry) => entry.value == gameType)
                  .key;
                return GameThumbItemTileWidget(
                  gameType: gameType,
                  gameName: gameName,
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
