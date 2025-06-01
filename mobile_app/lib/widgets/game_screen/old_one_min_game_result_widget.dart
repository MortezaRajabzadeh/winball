import 'package:flutter/material.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/utils/functions.dart';
import 'package:winball/widgets/game_screen/number_and_circles_by_one_min_game_result_widget.dart';
import 'package:winball/widgets/global/custom_error_widget.dart';
import 'package:winball/widgets/global/loading_widget.dart';

class OldOneMinGameResultWidget extends StatefulWidget {
  const OldOneMinGameResultWidget({
    super.key,
    required this.result,
    required this.functions,
    required this.listWheelScrollController,
    required this.scrollListWheelScrollControllerByGameResult,
    required this.gameType,
    required this.latestGameNotifier,
  });
  final OneMinGameResult? result;
  final void Function({required OneMinGameResult gameResult})
      scrollListWheelScrollControllerByGameResult;
  final GameType gameType;
  final ScrollController listWheelScrollController;
  final Functions functions;
  final ValueNotifier<OneMinGameModel> latestGameNotifier;

  @override
  State<OldOneMinGameResultWidget> createState() =>
      _OldOneMinGameResultWidgetState();
}

class _OldOneMinGameResultWidgetState extends State<OldOneMinGameResultWidget> {
  late final ValueNotifier<bool> hasMoreDataValueNotifier;
  int page = 1;
  late final ValueNotifier<List<OneMinGameModel>>
      listOfOldOneMinGamesValueNotifier;
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final OneMinGameFunctions oneMinGameFunctions;
  
  Future<void> initializeDatas() async {
    hasMoreDataValueNotifier = ValueNotifier<bool>(false);
    oneMinGameFunctions = const OneMinGameFunctions();
    listOfOldOneMinGamesValueNotifier =
        ValueNotifier<List<OneMinGameModel>>([]);
    isLoadingValueNotifier = ValueNotifier<bool>(true);
    
    // اضافه کردن listener برای بروزرسانی تاریخچه با نتیجه جدید
    widget.latestGameNotifier.addListener(_updateWithLatestGame);
  }
  
  void _updateWithLatestGame() {
    final OneMinGameModel latestGame = widget.latestGameNotifier.value;
    if (latestGame.gameResult == null || latestGame.eachGameUniqueNumber == null) return;
    
    final List<OneMinGameModel> games = List.from(listOfOldOneMinGamesValueNotifier.value);
    if (games.isEmpty) {
      // اگر لیست خالی است و بازی جدید نتیجه دارد، آن را اضافه کنیم
      if (latestGame.gameResult != null) {
        games.add(latestGame);
        changeListOfOldOneMinGamesValueNotifier(oneMinGames: games);
      }
      return;
    }
    
    // بررسی آیا بازی در لیست وجود دارد
    bool gameExists = false;
    for (int i = 0; i < games.length; i++) {
      if (games[i].eachGameUniqueNumber == latestGame.eachGameUniqueNumber) {
        games[i] = latestGame;
        gameExists = true;
        break;
      }
    }
    
    // اگر بازی در لیست نیست و نتیجه دارد، آن را در ابتدای لیست اضافه کنیم
    if (!gameExists && latestGame.gameResult != null) {
      games.insert(0, latestGame);
      
      // اطمینان از ترتیب نزولی بر اساس شماره بازی (جدیدترین در ابتدا)
      games.sort((a, b) => (b.eachGameUniqueNumber ?? 0).compareTo(a.eachGameUniqueNumber ?? 0));
    }
    
    // بروزرسانی لیست با تغییرات
    changeListOfOldOneMinGamesValueNotifier(oneMinGames: games);
    
    debugPrint('History updated: ${latestGame.eachGameUniqueNumber} with result ${latestGame.gameResult?.name}');
  }

  Future<void> loadOneMinGames() async {
    try {
      changeIsLoadingValueNotifier(value: true);
      
      // فقط استفاده از یک API
      final List<OneMinGameModel> oneMinGames =
          await oneMinGameFunctions.getOldOneMinGamesByGameTypeAndPage(
        gameType: widget.gameType,
        token: context.readAppBloc.state.currentUser.token ?? '',
        page: page,
      );
      
      if (page == 1) {
        changeListOfOldOneMinGamesValueNotifier(oneMinGames: []);
        
        // بررسی آیا آخرین بازی در نتایج API موجود است
        final OneMinGameModel latestGame = widget.latestGameNotifier.value;
        if (latestGame.gameResult != null && 
            latestGame.eachGameUniqueNumber != null && 
            !oneMinGames.any((game) => game.eachGameUniqueNumber == latestGame.eachGameUniqueNumber)) {
          
          // اگر آخرین بازی در نتایج API نیست، آن را به لیست اضافه کنیم
          oneMinGames.insert(0, latestGame);
          
          // مرتب‌سازی مجدد برای اطمینان از ترتیب درست
          oneMinGames.sort((a, b) => (b.eachGameUniqueNumber ?? 0).compareTo(a.eachGameUniqueNumber ?? 0));
          
          debugPrint('Added latest game to history: ${latestGame.eachGameUniqueNumber}');
        }
      }
      
      addListOfGamesToListOfOldOneMinGamesValueNotifier(
        oneMinGames: oneMinGames,
      );
      changeIsLoadingValueNotifier(value: false);
      page++;
      changeHasMoreDataValueNotifier(value: oneMinGames.isNotEmpty);
    } catch (e, stack) {
      changeIsLoadingValueNotifier(value: false);
      debugPrint('Error loading one minute games: ' + e.toString());
      debugPrintStack(stackTrace: stack);
      // Show error message to user if needed
    }
  }

  void changeListOfOldOneMinGamesValueNotifier(
      {required List<OneMinGameModel> oneMinGames}) {
    listOfOldOneMinGamesValueNotifier.value = List.from(oneMinGames);
  }

  void changeIsLoadingValueNotifier({bool? value}) {
    isLoadingValueNotifier.value = value ?? !isLoadingValueNotifier.value;
  }

  void addListOfGamesToListOfOldOneMinGamesValueNotifier(
      {required List<OneMinGameModel> oneMinGames}) {
    final List<OneMinGameModel> currentGames = List.from(listOfOldOneMinGamesValueNotifier.value);
    
    // برای هر بازی جدید بررسی می‌کنیم آیا قبلاً در لیست وجود دارد
    for (final newGame in oneMinGames) {
      bool gameExists = currentGames.any(
        (existingGame) => existingGame.eachGameUniqueNumber == newGame.eachGameUniqueNumber
      );
      
      // اگر بازی در لیست نیست، آن را اضافه می‌کنیم
      if (!gameExists) {
        currentGames.add(newGame);
      }
    }
    
    // مرتب‌سازی بر اساس شماره بازی (نزولی - جدیدترین اول)
    currentGames.sort((a, b) => (b.eachGameUniqueNumber ?? 0).compareTo(a.eachGameUniqueNumber ?? 0));
    
    // بروزرسانی لیست
    changeListOfOldOneMinGamesValueNotifier(oneMinGames: currentGames);
  }

  void changeHasMoreDataValueNotifier({bool? value}) {
    hasMoreDataValueNotifier.value = value ?? !hasMoreDataValueNotifier.value;
  }

  void dispositionalDatas() {
    listOfOldOneMinGamesValueNotifier.dispose();
    hasMoreDataValueNotifier.dispose();
    isLoadingValueNotifier.dispose();
    // حذف listener قبل از dispose
    widget.latestGameNotifier.removeListener(_updateWithLatestGame);
  }

  @override
  void initState() {
    super.initState();
    initializeDatas();
    // لاگ برای اشکال‌زدایی
    debugPrint('OldOneMinGameResultWidget initialized with gameType: ${widget.gameType.name}');
  }

  @override
  void dispose() {
    dispositionalDatas();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppConfigs.listWheelItemExtentWidth,
      height: AppConfigs.listWheelItemExtentHeight,
      child: GestureDetector(
        onTap: () {
          page = 1;
          loadOneMinGames();
          showAdaptiveDialog(
            context: context,
            builder: (context) {
              final Size size = context.getSize;
              return AlertDialog.adaptive(
                actions: [
                  TextButton(
                    onPressed: context.pop,
                    child: const Text(
                      AppTexts.close,
                    ),
                  ),
                ],
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValueListenableBuilder<List<OneMinGameModel>>(
                      valueListenable: listOfOldOneMinGamesValueNotifier,
                      builder: (context, games, _) {
                        return games.isEmpty
                            ? const CustomErrorWidget()
                            : SizedBox(
                                height: context.getSize.height / 2,
                                width:
                                    size.width - AppConfigs.largeVisualDensity,
                                child: ListView.builder(
                                  itemCount: games.length,
                                  itemExtent: 50,
                                  shrinkWrap: true,
                                  primary: true,
                                  itemBuilder: (context, index) {
                                    final OneMinGameResult? gameResult =
                                        games[index].gameResult;
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            '${AppTexts.randomNo}${games[index].eachGameUniqueNumber}'),
                                        if (gameResult != null) ...[
                                          const Spacer(),
                                          NumberAndCirclesByOneMinGameResultWidget(
                                            functions: widget.functions,
                                            oneMinGameResult: gameResult,
                                          ),
                                        ],
                                      ],
                                    );
                                    // return ListTile(
                                    //   contentPadding: EdgeInsets.zero,
                                    //   title: Text(
                                    //       '${AppTexts.randomNo}${games[index].id}'),
                                    //   trailing: gameResult == null
                                    //       ? null
                                    //       : NumberAndCirclesByOneMinGameResultWidget(
                                    //           functions: widget.functions,
                                    //           oneMinGameResult: gameResult,
                                    //         ),
                                    // );
                                  },
                                ),
                              );
                      },
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: isLoadingValueNotifier,
                      builder: (context, isLoading, child) {
                        return isLoading ? const LoadingWidget() : child!;
                      },
                      child: ValueListenableBuilder<bool>(
                        valueListenable: hasMoreDataValueNotifier,
                        builder: (context, hasMoreDatas, _) {
                          return TextButton(
                            onPressed: hasMoreDatas ? loadOneMinGames : null,
                            style: const ButtonStyle(
                              foregroundColor: WidgetStatePropertyAll<Color>(
                                AppConfigs.yellowColor,
                              ),
                            ),
                            child: const Text(
                              AppTexts.loadMore,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: widget.result != null ? NumberAndCirclesByOneMinGameResultWidget(
          functions: widget.functions,
          oneMinGameResult: widget.result!,
        ) : Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppConfigs.yellowColor,
              ),
            ),
          ),
        ),
        // ListWheelScrollView(
        //   physics: const NeverScrollableScrollPhysics(),
        //   // offAxisFraction: -0.5,
        //   // offAxisFraction: -0.5,
        //   clipBehavior: Clip.hardEdge,
        //   controller: widget.listWheelScrollController,
        //   perspective: 0.010,
        //   itemExtent: AppConfigs.listWheelItemExtentHeight,
        //   children: List.generate(
        //     OneMinGameResult.values.length,
        //     (index) => NumberAndCirclesByOneMinGameResultWidget(
        //       functions: widget.functions,
        //       oneMinGameResult: OneMinGameResult.values.elementAt(index),
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
