import 'dart:async';
import 'dart:convert';
import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
// import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:user_repository/user_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:winball/bloc/app_bloc/app_bloc.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/enums/enums.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/models/websocket_server_model.dart';
import 'package:winball/utils/functions.dart';
import 'package:winball/widgets/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:user_bet_repository/user_bet_repository.dart';

class OneMinGameScreen extends StatefulWidget {
  const OneMinGameScreen({
    super.key,
    required this.gameType,
  });
  final GameType gameType;

  @override
  State<OneMinGameScreen> createState() => _OneMinGameScreenState();
}

class _OneMinGameScreenState extends State<OneMinGameScreen> {
  WebSocketChannel? websocketChannel;
  late final ValueNotifier<bool> canChangeSelectedOptionsValueNotifier;
  late final ValueNotifier<WebsocketServerModel>
      currentWebsocketServerModelValueNotifier;
  late final ValueNotifier<OneMinGameModel> oneLastOneMinGameModelValueNotifier;
  late final ValueNotifier<int> currentGameTimerValueNotifier;
  late final ValueNotifier<double> amountPerOptionsValueNotifier;
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final OneMinGameFunctions oneMinGameFunctions;
  late final Functions functions;
  late final UserRepositoryFunctions userRepositoryFunctions;
  late final TextEditingController amountPerOptionTextEditingController;
  late final ScrollController listWheelScrollController;
  late final ValueNotifier<List<UserBetOptions>>
      listOfSelectedUserBetOptionsValueNotifier;
  UserModel? currentUser;
  Timer? gameSecondsTimer;
  late String debugServerResponse = '';
  bool isBetSubmitted = false;
  bool isSpinningAnimation = false;
  // Shared ValueNotifier for latest game data
  late ValueNotifier<OneMinGameModel> latestGameNotifier;
  
  void changeCurrentWebsocketServerModelValueNotifier(
      {required WebsocketServerModel websocketServerModel}) {
    currentWebsocketServerModelValueNotifier.value = websocketServerModel;
  }

  void changeCanChangeSelectedOptions({required bool canChange}) {
    canChangeSelectedOptionsValueNotifier.value = canChange;
  }

  void changeOneLastOneMinGameValueNotifier(
      {required OneMinGameModel oneMinGameModel}) {
    if (!mounted) return;
    
    if (oneMinGameModel.gameResult == null && 
        oneLastOneMinGameModelValueNotifier.value.gameResult != null &&
        !isSpinningAnimation) {
      return;
    }
    
    debugPrint('Updating game result: Result: ${oneMinGameModel.gameResult?.name}');
    
    oneLastOneMinGameModelValueNotifier.value = oneMinGameModel;
    
    if (oneMinGameModel.gameResult != null &&
        listWheelScrollController.hasClients &&
        oneMinGameModel.gameType == widget.gameType) {
      scrollListWheelScrollControllerByGameResult(
        gameResult: oneMinGameModel.gameResult!,
      );
    }
  }

  void addOrRemoveUserBetOptionsInListOfUserBetOptions(
      {required UserBetOptions userBetOptions}) {
    final List<UserBetOptions> options =
        listOfSelectedUserBetOptionsValueNotifier.value;
    if (canChangeSelectedOptionsValueNotifier.value) {
      if (options.contains(userBetOptions)) {
        options.remove(userBetOptions);
      } else {
        options.add(userBetOptions);
      }
      listOfSelectedUserBetOptionsValueNotifier.value = [...options];
    }
  }

  void amountPerOptionsTextEditingController() {
    changeAmountPerOptionsValueNotifier(
      value: amountPerOptionTextEditingController.text.convertToNum.toDouble(),
    );
  }

  Future<void> initializeBaseGame({required AppBloc appBloc}) async {
    try {
      changeIsLoadingValueNotifier(
        isLoading: true,
      );
      final List<OneMinGameModel> oneMinGames = 
          await oneMinGameFunctions.getOldOneMinGamesByGameTypeAndPage(
        token: appBloc.state.currentUser.token ?? '',
        gameType: widget.gameType,
        page: 1,
      );
      
      if (oneMinGames.isNotEmpty) {
        changeOneLastOneMinGameValueNotifier(oneMinGameModel: oneMinGames.first);
        // همگام‌سازی اولیه latestGameNotifier با آخرین بازی برای تطابق کامل داده‌ها
        latestGameNotifier.value = oneMinGames.first;
      }
      
      initializeWebsocketListener(
        appBloc: appBloc,
      );
      changeIsLoadingValueNotifier(
        isLoading: false,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> initializeDatas() async {
    try {
      canChangeSelectedOptionsValueNotifier = ValueNotifier<bool>(true);
      amountPerOptionsValueNotifier = ValueNotifier<double>(0.0);
      listWheelScrollController = ScrollController();
      listOfSelectedUserBetOptionsValueNotifier =
          ValueNotifier<List<UserBetOptions>>([]);
      amountPerOptionTextEditingController = TextEditingController(text: '0');
      amountPerOptionTextEditingController
          .addListener(amountPerOptionsTextEditingController);
      currentUser = context.readAppBloc.state.currentUser;
      userRepositoryFunctions = const UserRepositoryFunctions();
      functions = const Functions();
      isLoadingValueNotifier = ValueNotifier<bool>(true);
      oneMinGameFunctions = const OneMinGameFunctions();
      currentGameTimerValueNotifier = ValueNotifier<int>(0);
      currentWebsocketServerModelValueNotifier =
          ValueNotifier<WebsocketServerModel>(
        WebsocketServerModel(
          command: 'command',
          oneMinGame: OneMinGameModel.empty,
          seconds: 0,
        ),
      );
      final AppBloc appBloc = context.readAppBloc;
      oneLastOneMinGameModelValueNotifier =
          ValueNotifier<OneMinGameModel>(OneMinGameModel.empty);
      latestGameNotifier = ValueNotifier<OneMinGameModel>(OneMinGameModel.empty);

      final List<OneMinGameModel> oneMinGames = 
          await oneMinGameFunctions.getOldOneMinGamesByGameTypeAndPage(
        token: appBloc.state.currentUser.token ?? '',
        gameType: widget.gameType,
        page: 1,
      );
      
      if (oneMinGames.isNotEmpty) {
        changeOneLastOneMinGameValueNotifier(oneMinGameModel: oneMinGames.first);
        // همگام‌سازی اولیه latestGameNotifier با آخرین بازی برای تطابق کامل داده‌ها
        latestGameNotifier.value = oneMinGames.first;
      }
      
      changeIsLoadingValueNotifier(isLoading: false);
      //connect to websocket connection
      initializeWebsocketListener(appBloc: appBloc);
    } catch (e) {
      changeIsLoadingValueNotifier(isLoading: false);
      // مدیریت خطا و نمایش پیام مناسب به کاربر
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is BaseExceptions 
                ? 'Error: \\${e.error}' 
                : 'Connection error: Please try again'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                initializeBaseGame(appBloc: context.readAppBloc);
              },
            ),
          ),
        );
      }
      if (e is BaseExceptions) {
        // Log error if needed for debugging
      }
    }
  }

  void makeRandomSpinOfSpinnerGameResult({required OneMinGameModel tempOneMinGameModel}) {
    if (isSpinningAnimation) return;
    
    // نمایش اطلاعات انیمیشن برای اشکال‌زدایی
    debugPrint('Starting spin animation with FINAL result: ${tempOneMinGameModel.gameResult?.name}');
    isSpinningAnimation = true;
    
    // ایجاد انیمیشن چرخش با نمایش نتایج تصادفی
    for (int i = 1; i <= 33; i++) {
      Future.delayed(Duration(milliseconds: i * 100)).then(
        (_) {
          Future.delayed(
            const Duration(milliseconds: 900),
            () {
              if (mounted) {
                // نمایش نتایج مختلف به صورت تصادفی در طول انیمیشن
                final OneMinGameModel oneMinGameModel =
                    tempOneMinGameModel.copyWith(
                  gameResult: OneMinGameResult.values
                      .toList()[i % OneMinGameResult.values.length],
                );
                changeOneLastOneMinGameValueNotifier(
                  oneMinGameModel: oneMinGameModel,
                );
              }
            },
          );
        },
      );
    }
    
    // در پایان انیمیشن، نتیجه نهایی واقعی را نمایش می‌دهیم
    Future.delayed(
      const Duration(milliseconds: 4500),
      () {
        if (mounted) {
          isSpinningAnimation = false;
          // نمایش نتیجه نهایی که از وب‌سوکت دریافت شده است
          changeOneLastOneMinGameValueNotifier(
            oneMinGameModel: tempOneMinGameModel,
          );
          debugPrint('Finished spin animation with FINAL result: ${tempOneMinGameModel.gameResult?.name}');
        }
      },
    );
  }

  void initializeWebsocketListener({required AppBloc appBloc}) {
    try {
      websocketChannel = WebSocketChannel.connect(
        Uri.parse(
          '${OneMinGameConfigs.gameWebsocketUrl}?token=${appBloc.state.currentUser.token ?? ''}&game_type=${widget.gameType.name}',
        ),
      );
    } catch (e) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          initializeWebsocketListener(appBloc: appBloc);
        }
      });
      return;
    }
    websocketChannel?.stream.listen(
      (data) {
        final WebsocketServerModel websocketServerModel =
            WebsocketServerModel.fromJson(
          jsonData: data,
        );
        // نمایش اطلاعات دریافتی از وب‌سوکت برای عیب‌یابی
        debugPrint('WebSocket data received: Result: ${websocketServerModel.oneMinGame.gameResult?.name}');
        
        if (websocketServerModel.oneMinGame.gameResult != null &&
            websocketServerModel.oneMinGame.gameType == widget.gameType) {
          changeCanChangeSelectedOptions(canChange: true);
          
          // بروزرسانی فوری latestGameNotifier برای همگام‌سازی با تاریخچه
          // این تضمین می‌کند که هم نتیجه فعلی و هم تاریخچه داده‌های یکسان نشان دهند
          latestGameNotifier.value = websocketServerModel.oneMinGame;
          
          // ذخیره نتیجه جدید در oneLastOneMinGameModelValueNotifier بعد از انیمیشن
          // این باعث می‌شود بعد از انیمیشن، نتیجه نهایی صحیح در صفحه اصلی نمایش داده شود
          Future.delayed(
            const Duration(milliseconds: 4500),
            () {
              if (mounted) {
                changeOneLastOneMinGameValueNotifier(
                  oneMinGameModel: websocketServerModel.oneMinGame,
                );
              }
            },
          );
          
          if (isBetSubmitted && listOfSelectedUserBetOptionsValueNotifier.value.isNotEmpty) {
            final betResult = functions
                .calculateBetResultByGameResultAndListOfSelectedOptions(
              amountPerOption: amountPerOptionTextEditingController
                  .text.convertToNum
                  .toDouble(),
              gameResult: websocketServerModel.oneMinGame.gameResult!,
              options: listOfSelectedUserBetOptionsValueNotifier.value,
            );
            context.readAppBloc.add(
              UpdateUserInventoryEvent(
                coinType: context.readAppBloc.state.selectedCoinType,
                inventory: betResult,
              ),
            );
            resetGameBet();
            isBetSubmitted = false;
          }
          
          // here is to rotate all of the possibilities
          final int oneMinGameResultIndex = OneMinGameResult.values.indexWhere(
              (result) => result == websocketServerModel.oneMinGame.gameResult);
          if (oneMinGameResultIndex != -1 && !isSpinningAnimation) {
            final OneMinGameModel tempOneMinGameModel =
                websocketServerModel.oneMinGame.copyWith(
              gameResult: websocketServerModel.oneMinGame.gameResult,
            );
            makeRandomSpinOfSpinnerGameResult(
              tempOneMinGameModel: tempOneMinGameModel,
            );
          }
        }
        
        if (websocketServerModel.oneMinGame.gameType == widget.gameType) {
          changeCurrentWebsocketServerModelValueNotifier(
            websocketServerModel: websocketServerModel,
          );
          
          // بهینه‌سازی timer management
          final int newSeconds = websocketServerModel.seconds == 0
              ? oneMinGameFunctions.getSecondsByGameType(gameType: widget.gameType)
              : websocketServerModel.seconds;
          
          changeCurrentGameTimerValueNotifier(seconds: newSeconds);
          
          // لغو timer قبلی و شروع timer جدید
          gameSecondsTimer?.cancel();
          gameSecondsTimer = Timer.periodic(
            const Duration(seconds: 1),
            (_) {
              changeCurrentGameTimerValueNotifier(
                seconds: currentGameTimerValueNotifier.value - 1,
              );
            },
          );
        }
      },
    );
  }

  void updateUserFromServer() {
    context.readAppBloc.add(const UpdateUserEvent());
  }

  void scrollListWheelScrollControllerByGameResult(
      {required OneMinGameResult gameResult}) {
    final int gameResultIndex =
        OneMinGameResult.values.indexWhere((e) => e.name == gameResult.name);
    if (gameResultIndex != -1) {
      listWheelScrollController.animateTo(
        gameResultIndex * AppConfigs.listWheelItemExtentHeight,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void changeCurrentGameTimerValueNotifier({required int seconds}) {
    if (websocketChannel?.closeCode != null) {
      websocketChannel?.sink.close();
      Future.delayed(
        const Duration(seconds: 7),
        () {
          if (mounted) {
            initializeBaseGame(appBloc: context.readAppBloc);
          }
        },
      );
    }
    if (seconds >= 0) {
      currentGameTimerValueNotifier.value = seconds;
    }
  }

  void changeIsLoadingValueNotifier({bool? isLoading}) {
    isLoadingValueNotifier.value = isLoading ?? !isLoadingValueNotifier.value;
  }

  void multipy3AmountPerOptionTextEditingController() {
    amountPerOptionTextEditingController.text =
        (amountPerOptionTextEditingController.text.convertToNum.toDouble() * 3)
            .toStringAsFixed(2);
  }

  void divideBy3AmountPerOptionTextEditingController() {
    amountPerOptionTextEditingController.text =
        (amountPerOptionTextEditingController.text.convertToNum.toDouble() / 3)
            .toStringAsFixed(2);
  }

  void changeAmountPerOptionsValueNotifier({required double value}) {
    // بدون اعمال محدودیت، مقدار ورودی مستقیماً به ValueNotifier انتقال می‌یابد
    amountPerOptionsValueNotifier.value = value;
  }

  void dispositoinalDatas() {
    canChangeSelectedOptionsValueNotifier.dispose();
    amountPerOptionTextEditingController
        .removeListener(amountPerOptionsTextEditingController);
    amountPerOptionsValueNotifier.dispose();
    amountPerOptionTextEditingController.dispose();
    websocketChannel?.sink.close();
    currentWebsocketServerModelValueNotifier.dispose();
    oneLastOneMinGameModelValueNotifier.dispose();
    currentGameTimerValueNotifier.dispose();
    gameSecondsTimer?.cancel();
    isLoadingValueNotifier.dispose();
    listOfSelectedUserBetOptionsValueNotifier.dispose();
    listWheelScrollController.dispose();
    latestGameNotifier.dispose();
  }

  void changeListOfUserBetsValueNotifier({
    required List<UserBetOptions> userBetOptions,
  }) {
    listOfSelectedUserBetOptionsValueNotifier.value = userBetOptions;
  }

  void resetGameBet() {
    changeListOfUserBetsValueNotifier(userBetOptions: []);
  }

  @override
  void initState() {
    super.initState();
    initializeDatas();
  }

  @override
  void dispose() {
    latestGameNotifier.dispose();
    dispositoinalDatas();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: context.pop,
          ),
          PopupMenuButton(
            itemBuilder: (context) {
              return List.generate(
                AppConfigs.oneMinGameMoreMenuValues.length,
                (index) {
                  return PopupMenuItem(
                    value: AppConfigs.oneMinGameMoreMenuValues.values.elementAt(index),
                    child: Text(
                      AppConfigs.oneMinGameMoreMenuValues.keys.elementAt(index),
                    ),
                    onTap: () {
                      context.tonamed(
                        name: AppConfigs.oneMinGameMoreMenuValues.values.elementAt(index),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
        title: Text(
          oneMinGameFunctions.convertGameTypeToNormalString(
            gameType: widget.gameType,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConfigs.mediumVisualDensity,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CurrentOneMinGameDetailsWidget(
                        currentWebsocketServerModelValueNotifier:
                            currentWebsocketServerModelValueNotifier,
                        currentGameTimerValueNotifier:
                            currentGameTimerValueNotifier,
                        functions: functions,
                      ),
                      OldOneMinGameDetailsWidget(
                        isLoadingValueNotifier: isLoadingValueNotifier,
                        oneLastOneMinGameModelValueNotifier: oneLastOneMinGameModelValueNotifier,
                        listWheelScrollController: listWheelScrollController,
                        scrollListWheelScrollControllerByGameResult: scrollListWheelScrollControllerByGameResult,
                        functions: functions,
                      ),
                      const CustomSpaceWidget(
                        size: AppConfigs.largeVisualDensity,
                      ),
                    ],
                  ),
                  ValueListenableBuilder<OneMinGameModel>(
                    valueListenable: oneLastOneMinGameModelValueNotifier,
                    builder: (context, lastGame, _) {
                      final OneMinGameResult? result = lastGame.gameResult;
                      return result != null
                          ? OldOneMinGameResultWidget(
                              functions: functions,
                              gameType: widget.gameType,
                              listWheelScrollController: listWheelScrollController,
                              result: result,
                              scrollListWheelScrollControllerByGameResult: scrollListWheelScrollControllerByGameResult,
                              // ارسال notifier برای همگام‌سازی داده‌ها
                              latestGameNotifier: latestGameNotifier,
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                  OneMinGameTimerValueNotifierWidget(
                    currentGameTimerValueNotifier: currentGameTimerValueNotifier,
                    functions: functions,
                  ),
                ],
              ),
              const Text(AppTexts.gameDescription),
              const CustomSpaceWidget(),
              ListOfGamePrimaryColorWidget(
                addOrRemoveUserBetOptionsInListOfUserBetOptions:
                    addOrRemoveUserBetOptionsInListOfUserBetOptions,
                listOfSelectedUserBetOptionsValueNotifier:
                    listOfSelectedUserBetOptionsValueNotifier,
              ),
              const CustomSpaceWidget(
                size: AppConfigs.largeVisualDensity,
              ),
              Wrap(
                children: List.generate(
                  AppConfigs.mapOfGameOptionsAndColors.length,
                  (index) {
                    final List<Color> colors = AppConfigs
                        .mapOfGameOptionsAndColors.values
                        .elementAt(index);
                    return UserBetOptionItemTileWidget(
                      colors: colors,
                      listOfUserBetsValueNotifier:
                          listOfSelectedUserBetOptionsValueNotifier,
                      userBetOptions: AppConfigs.mapOfGameOptionsAndColors.keys
                          .elementAt(index),
                      onTap: addOrRemoveUserBetOptionsInListOfUserBetOptions,
                      optionIndex: index,
                    );
                  },
                ),
              ),
              const Divider(),
              UserCurrentAmountWidget(
                updateUserFromServer: updateUserFromServer,
              ),
              const CustomSpaceWidget(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      controller: amountPerOptionTextEditingController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.,]'),
                          replacementString: '0',
                        ),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          // تبدیل ویرگول به نقطه
                          return TextEditingValue(
                            text: newValue.text.replaceAll(',', '.'),
                            selection: newValue.selection,
                          );
                        }),
                      ],
                      decoration: AppConfigs.customInputDecoration.copyWith(
                        labelText: AppTexts.amountPerOption,
                      ),
                    ),
                  ),
                  const CustomSpaceWidget(
                    sizeDirection: SizeDirection.horizontal,
                  ),
                  TextButton(
                    onPressed: () {
                      divideBy3AmountPerOptionTextEditingController();
                    },
                    child: const Text('/3'),
                  ),
                  const CustomSpaceWidget(
                    sizeDirection: SizeDirection.horizontal,
                  ),
                  TextButton(
                    onPressed: () {
                      multipy3AmountPerOptionTextEditingController();
                    },
                    child: const Text('x3'),
                  ),
                ],
              ),
              const CustomSpaceWidget(),
              ValueListenableBuilder<List<UserBetOptions>>(
                valueListenable: listOfSelectedUserBetOptionsValueNotifier,
                builder: (context, options, _) {
                  return ValueListenableBuilder<double>(
                    valueListenable: amountPerOptionsValueNotifier,
                    builder: (context, amountPerPage, _) {
                      // محدود کردن اعداد اعشاری به 3 رقم برای نمایش بهتر
                      final String formattedAmount = amountPerPage.toStringAsFixed(3);
                      final String formattedTotal = (options.length * amountPerPage).toStringAsFixed(3);
                      
                      return Text(
                        '${options.length}x$formattedAmount=$formattedTotal ${context.readAppBloc.state.selectedCoinType == CoinType.stars ? AppTexts.stars : context.readAppBloc.state.selectedCoinType.name}',
                      );
                    },
                  );
                },
              ),
              const CustomSpaceWidget(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: resetGameBet,
                  ),
                  ValueListenableBuilder(
                    valueListenable: listOfSelectedUserBetOptionsValueNotifier,
                    builder: (context, listOfSelectedUserBetOptions, _) {
                      return ValueListenableBuilder<double>(
                        valueListenable: amountPerOptionsValueNotifier,
                        builder: (context, amountPerOption, _) {
                          return CreateUserBetButtonWidget(
                            canChangeSelectedOptionsValueNotifier:
                                canChangeSelectedOptionsValueNotifier,
                            changeCanChangeSelectedOptionsValueNotifier:
                                changeCanChangeSelectedOptions,
                            currentWebsocketServerModelValueNotifier:
                                currentWebsocketServerModelValueNotifier,
                            currentGameTimerValueNotifier:
                                currentGameTimerValueNotifier,
                            listOfSelectedUserBetOptionsValueNotifier:
                                listOfSelectedUserBetOptionsValueNotifier,
                            amount:
                                '${listOfSelectedUserBetOptions.length * amountPerOption}',
                            functions: functions,
                            amountPerOptionsValueNotifier:
                                amountPerOptionsValueNotifier,
                            onBetSubmitted: () { isBetSubmitted = true; },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
