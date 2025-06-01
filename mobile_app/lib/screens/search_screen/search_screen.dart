import 'package:flutter/material.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/widgets/widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController searchIntoGamesTextEditingController;
  late final ValueNotifier<List<String>> gamesSearchedValueNotifier;
  void initializeDatas() {
    searchIntoGamesTextEditingController = TextEditingController();
    searchIntoGamesTextEditingController
        .addListener(textEditingControllerListener);
    gamesSearchedValueNotifier = ValueNotifier<List<String>>([]);
  }

  void textEditingControllerListener() {
    if (searchIntoGamesTextEditingController.text.isNotEmpty) {
      final List<String> gameNames = AppConfigs.listOfGames.keys
          .where((e) => e.toLowerCase().contains(
              searchIntoGamesTextEditingController.text.toLowerCase()))
          .toList();

      if (gameNames.isNotEmpty) {
        for (final String gameName in gameNames) {
          gamesSearchedValueNotifier.value = [gameName];
        }
      } else {
        gamesSearchedValueNotifier.value = [];
      }
    } else {
      gamesSearchedValueNotifier.value = [];
    }
  }

  void changeListOfSearchedGamesValueNotifier({required List<String> games}) {
    gamesSearchedValueNotifier.value = games;
  }

  void dispositionalDatas() {
    searchIntoGamesTextEditingController
        .removeListener(textEditingControllerListener);
    searchIntoGamesTextEditingController.dispose();
    gamesSearchedValueNotifier.dispose();
  }

  @override
  void initState() {
    super.initState();
    initializeDatas();
  }

  @override
  void dispose() {
    dispositionalDatas();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppTexts.search,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConfigs.largeVisualDensity,
          horizontal: AppConfigs.mediumVisualDensity,
        ),
        child: Column(
          children: [
            TextField(
              controller: searchIntoGamesTextEditingController,
              decoration: AppConfigs.customInputDecoration.copyWith(
                labelText: AppTexts.search,
              ),
            ),
            const CustomSpaceWidget(),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppConfigs.appShadowColor,
                  borderRadius: BorderRadius.circular(
                    AppConfigs.mediumVisualDensity,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(
                    AppConfigs.mediumVisualDensity,
                  ),
                  child: ValueListenableBuilder<List<String>>(
                    valueListenable: gamesSearchedValueNotifier,
                    builder: (context, games, _) {
                      return games.isEmpty
                          ? const CustomErrorWidget()
                          : GridView.builder(
                              itemCount: games.length,
                              itemBuilder: (context, index) {
                                final int gameIndex = AppConfigs
                                    .listOfGames.keys
                                    .toList()
                                    .indexWhere((e) => e == games[index]);
                                GameType gameType = GameType.one_min_game;
                                if (gameIndex != -1) {
                                  gameType = AppConfigs.listOfGames.values
                                      .toList()[gameIndex];
                                }
                                return GameThumbItemTileWidget(
                                  gameType: gameType,
                                  gameName: games[index],
                                  imagePath: AppConfigs.oneMinGameImage,
                                );
                              },
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                              ),
                            );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
