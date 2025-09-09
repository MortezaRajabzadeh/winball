import 'dart:async';
import 'dart:convert';
import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
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

class RedBlackGameScreen extends StatefulWidget {
  const RedBlackGameScreen({
    super.key,
    required this.gameType,
  });
  final GameType gameType;

  @override
  State<RedBlackGameScreen> createState() => _RedBlackGameScreenState();
}
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F222E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Balance Display
          UserCurrentAmountWidget(
            updateUserFromServer: updateUserFromServer,
          ),
          const SizedBox(height: 16),
          
          // Amount Input
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2F3F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: amountPerOptionTextEditingController,
                    style: const TextStyle(color: Colors.white),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9.,]'),
                        replacementString: '0',
                      ),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        return TextEditingValue(
                          text: newValue.text.replaceAll(',', '.'),
                          selection: newValue.selection,
                        );
                      }),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.attach_money, color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Quick amount buttons
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2F3F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed: divideBy3AmountPerOptionTextEditingController,
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: Colors.white24,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: multipy3AmountPerOptionTextEditingController,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Bet Info and Submit Button
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<List<UserBetOptions>>(
                  valueListenable: listOfSelectedUserBetOptionsValueNotifier,
                  builder: (context, options, _) {
                    return ValueListenableBuilder<double>(
                      valueListenable: amountPerOptionsValueNotifier,
                      builder: (context, amountPerPage, _) {
                        final total = options.length * amountPerPage;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Bet',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${total.toStringAsFixed(2)} ${context.readAppBloc.state.selectedCoinType.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              ValueListenableBuilder<List<UserBetOptions>>(
                valueListenable: listOfSelectedUserBetOptionsValueNotifier,
                builder: (context, listOfSelectedUserBetOptions, _) {
                  return ValueListenableBuilder<double>(
                    valueListenable: amountPerOptionsValueNotifier,
                    builder: (context, amountPerOption, _) {
                      final isEnabled = listOfSelectedUserBetOptions.isNotEmpty && amountPerOption > 0;
                      return ElevatedButton(
                        onPressed: isEnabled
                            ? () {
                                // Submit bet logic
                                isBetSubmitted = true;
                                // You can add more submission logic here
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEnabled ? const Color(0xFF28A745) : const Color(0xFF2C2F3F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Place Bet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceAndInputSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F222E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Balance Display
          UserCurrentAmountWidget(
            updateUserFromServer: updateUserFromServer,
          ),
          const SizedBox(height: 16),
          
          // Amount Input
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2F3F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    controller: amountPerOptionTextEditingController,
                    style: const TextStyle(color: Colors.white),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9.,]'),
                        replacementString: '0',
                      ),
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        return TextEditingValue(
                          text: newValue.text.replaceAll(',', '.'),
                          selection: newValue.selection,
                        );
                      }),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Enter amount',
                      hintStyle: TextStyle(color: Colors.white38),
                      prefixIcon: Icon(Icons.attach_money, color: Colors.white54),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Quick amount buttons
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2F3F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed: divideBy3AmountPerOptionTextEditingController,
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: Colors.white24,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: multipy3AmountPerOptionTextEditingController,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Bet Info and Submit Button
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<List<UserBetOptions>>(
                  valueListenable: listOfSelectedUserBetOptionsValueNotifier,
                  builder: (context, options, _) {
                    return ValueListenableBuilder<double>(
                      valueListenable: amountPerOptionsValueNotifier,
                      builder: (context, amountPerPage, _) {
                        final total = options.length * amountPerPage;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Bet',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${total.toStringAsFixed(2)} ${context.readAppBloc.state.selectedCoinType.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              ValueListenableBuilder<List<UserBetOptions>>(
                valueListenable: listOfSelectedUserBetOptionsValueNotifier,
                builder: (context, listOfSelectedUserBetOptions, _) {
                  return ValueListenableBuilder<double>(
                    valueListenable: amountPerOptionsValueNotifier,
                    builder: (context, amountPerOption, _) {
                      return CreateUserBetButtonWidget(
                        canChangeSelectedOptionsValueNotifier: canChangeSelectedOptionsValueNotifier,
                        changeCanChangeSelectedOptionsValueNotifier: changeCanChangeSelectedOptions,
                        currentWebsocketServerModelValueNotifier: currentWebsocketServerModelValueNotifier,
                        currentGameTimerValueNotifier: currentGameTimerValueNotifier,
                        listOfSelectedUserBetOptionsValueNotifier: listOfSelectedUserBetOptionsValueNotifier,
                        amount: '${listOfSelectedUserBetOptions.length * amountPerOption}',
                        functions: functions,
                        amountPerOptionsValueNotifier: amountPerOptionsValueNotifier,
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
    );
  }
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
  late final ValueNotifier<UserBetOptions?> selectedBetOptionValueNotifier;
  late final ValueNotifier<List<OneMinGameModel>> gameHistoryValueNotifier;
  late final ValueNotifier<List<int>> currentGameNumbersValueNotifier;
  late final ValueNotifier<List<UserBetOptions>> listOfSelectedUserBetOptionsValueNotifier;
  UserModel? currentUser;
  Timer? gameSecondsTimer;
  String debugServerResponse = '';
  bool isBetSubmitted = false;

  void changeCurrentWebsocketServerModelValueNotifier({
    required WebsocketServerModel websocketServerModel,
  }) {
    currentWebsocketServerModelValueNotifier.value = websocketServerModel;
  }

  void changeCanChangeSelectedOptions({required bool canChange}) {
    canChangeSelectedOptionsValueNotifier.value = canChange;
  }

  void changeOneLastOneMinGameValueNotifier({
    required OneMinGameModel oneMinGameModel,
  }) {
    if (!mounted) return;
    oneLastOneMinGameModelValueNotifier.value = oneMinGameModel;
  }

  void selectBetOption(UserBetOptions option) {
    if (canChangeSelectedOptionsValueNotifier.value) {
      final List<UserBetOptions> currentOptions = listOfSelectedUserBetOptionsValueNotifier.value;
      if (currentOptions.contains(option)) {
        currentOptions.remove(option);
      } else {
        // For Red-Black game, only allow one selection at a time
        currentOptions.clear();
        currentOptions.add(option);
      }
      listOfSelectedUserBetOptionsValueNotifier.value = [...currentOptions];
      selectedBetOptionValueNotifier.value = currentOptions.isEmpty ? null : option;
    }
  }

  void addOrRemoveUserBetOptionsInListOfUserBetOptions({required UserBetOptions userBetOptions}) {
    final List<UserBetOptions> options = listOfSelectedUserBetOptionsValueNotifier.value;
    if (canChangeSelectedOptionsValueNotifier.value) {
      if (options.contains(userBetOptions)) {
        options.remove(userBetOptions);
      } else {
        // For Red-Black game, only allow one selection
        options.clear();
        options.add(userBetOptions);
      }
      listOfSelectedUserBetOptionsValueNotifier.value = [...options];
      selectedBetOptionValueNotifier.value = options.isEmpty ? null : userBetOptions;
    }
  }

  void amountPerOptionsTextEditingController() {
    changeAmountPerOptionsValueNotifier(
      value: amountPerOptionTextEditingController.text.convertToNum.toDouble(),
    );
  }

  void changeAmountPerOptionsValueNotifier({required double value}) {
    amountPerOptionsValueNotifier.value = value;
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

  void changeListOfUserBetsValueNotifier({required List<UserBetOptions> userBetOptions}) {
    listOfSelectedUserBetOptionsValueNotifier.value = userBetOptions;
  }

  void resetGameBet() {
    changeListOfUserBetsValueNotifier(userBetOptions: []);
    selectedBetOptionValueNotifier.value = null;
  }

  Future<void> initializeBaseGame({required AppBloc appBloc}) async {
    try {
      changeIsLoadingValueNotifier(isLoading: true);
      
      final List<OneMinGameModel> oneMinGames = 
          await oneMinGameFunctions.getOldOneMinGamesByGameTypeAndPage(
        token: appBloc.state.currentUser.token ?? '',
        gameType: widget.gameType,
        page: 1,
      );
      
      if (oneMinGames.isNotEmpty) {
        changeOneLastOneMinGameValueNotifier(oneMinGameModel: oneMinGames.first);
      }
      
      initializeWebsocketListener(appBloc: appBloc);
      changeIsLoadingValueNotifier(isLoading: false);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> initializeDatas() async {
    try {
      canChangeSelectedOptionsValueNotifier = ValueNotifier<bool>(true);
      amountPerOptionsValueNotifier = ValueNotifier<double>(0.0);
      selectedBetOptionValueNotifier = ValueNotifier<UserBetOptions?>(null);
      gameHistoryValueNotifier = ValueNotifier<List<OneMinGameModel>>([]);
      // CoinVid RB sequence: 1,14,2,13,3,12,4,11,5,10,6,9,7,8,15
      currentGameNumbersValueNotifier = ValueNotifier<List<int>>([
        1, 14, 2, 13, 3, 12, 4, 11, 5, 10, 6, 9, 7, 8, 15,
      ]);
      listOfSelectedUserBetOptionsValueNotifier = ValueNotifier<List<UserBetOptions>>([]);
      amountPerOptionTextEditingController = TextEditingController(text: '0');
      amountPerOptionTextEditingController.addListener(amountPerOptionsTextEditingController);
      
      currentUser = context.readAppBloc.state.currentUser;
      userRepositoryFunctions = const UserRepositoryFunctions();
      functions = const Functions();
      isLoadingValueNotifier = ValueNotifier<bool>(true);
      oneMinGameFunctions = const OneMinGameFunctions();
      currentGameTimerValueNotifier = ValueNotifier<int>(0);
      currentWebsocketServerModelValueNotifier = ValueNotifier<WebsocketServerModel>(
        WebsocketServerModel(
          command: 'command',
          oneMinGame: OneMinGameModel.empty,
          seconds: 0,
        ),
      );
      
      final AppBloc appBloc = context.readAppBloc;
      oneLastOneMinGameModelValueNotifier = ValueNotifier<OneMinGameModel>(OneMinGameModel.empty);

      final List<OneMinGameModel> oneMinGames = 
          await oneMinGameFunctions.getOldOneMinGamesByGameTypeAndPage(
        token: appBloc.state.currentUser.token ?? '',
        gameType: widget.gameType,
        page: 1,
      );
      
      if (oneMinGames.isNotEmpty) {
        changeOneLastOneMinGameValueNotifier(oneMinGameModel: oneMinGames.first);
        gameHistoryValueNotifier.value = oneMinGames.take(8).toList();
      }
      
      changeIsLoadingValueNotifier(isLoading: false);
      initializeWebsocketListener(appBloc: appBloc);
    } catch (e) {
      changeIsLoadingValueNotifier(isLoading: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection error: Please try again'),
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
    }
  }

  Future<void> initializeWebsocketListener({required AppBloc appBloc}) async {
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
        
        debugPrint('WebSocket data received: Result: ${websocketServerModel.oneMinGame.gameResult?.name}');
        
        if (websocketServerModel.oneMinGame.gameResult != null &&
            websocketServerModel.oneMinGame.gameType == widget.gameType) {
          changeCanChangeSelectedOptions(canChange: true);
          
          // Update game history
          changeOneLastOneMinGameValueNotifier(
            oneMinGameModel: websocketServerModel.oneMinGame,
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
        }
        
        if (websocketServerModel.oneMinGame.gameType == widget.gameType) {
          changeCurrentWebsocketServerModelValueNotifier(
            websocketServerModel: websocketServerModel,
          );
          
          // Timer management like one_min_game_screen
          final int newSeconds = websocketServerModel.seconds == 0
              ? oneMinGameFunctions.getSecondsByGameType(gameType: widget.gameType)
              : websocketServerModel.seconds;
          
          changeCurrentGameTimerValueNotifier(seconds: newSeconds);
          
          // Cancel previous timer and start new one
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
      onError: (error) {
        debugPrint('WebSocket error: $error');
        if (mounted) {
          Future.delayed(const Duration(seconds: 5), () {
            initializeWebsocketListener(appBloc: appBloc);
          });
        }
      },
      onDone: () {
        debugPrint('WebSocket connection closed');
        if (mounted) {
          Future.delayed(const Duration(seconds: 3), () {
            initializeWebsocketListener(appBloc: appBloc);
          });
        }
      },
    );
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

  void changeIsLoadingValueNotifier({required bool isLoading}) {
    if (mounted) {
      isLoadingValueNotifier.value = isLoading;
    }
  }

  String getGameTypeTitle() {
    switch (widget.gameType) {
      case GameType.red_black_30s:
        return 'Red & Black [30s]';
      case GameType.red_black_3m:
        return 'Red & Black [3m]';
      case GameType.red_black_5m:
        return 'Red & Black [5m]';
      default:
        return 'Red & Black Game';
    }
  }

  String getGameDescription() {
    switch (widget.gameType) {
      case GameType.red_black_30s:
        return 'Choose Red or Black - 30 seconds to bet!';
      case GameType.red_black_3m:
        return 'Choose Red or Black - 3 minutes to bet!';
      case GameType.red_black_5m:
        return 'Choose Red or Black - 5 minutes to bet!';
      default:
        return 'Choose Red or Black and win!';
    }
  }

  Color getResultColor(String? result) {
    if (result == null) return Colors.grey;
    return result.toLowerCase() == 'red' ? Colors.red : Colors.black;
  }

  void resetBet() {
    resetGameBet();
  }

  Color getGameResultColor(String? result) {
    if (result == null) return Colors.grey;
    switch (result.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'black':
        return Colors.grey[800]!;
      default:
        return Colors.white;
    }
  }

  Color getGameNumberColor(int number) {
    if (number >= 1 && number <= 7) {
      return const Color(0xFFDC3545); // قرمز
    } else if (number >= 8 && number <= 14) {
      return const Color(0xFF6C757D); // خاکستری
    } else if (number == 15) {
      return Colors.white; // سفید
    } else {
      return const Color(0xFF6C757D); // پیش‌فرض خاکستری
    }
  }

  void updateUserFromServer() {
    context.readAppBloc.add(const UpdateUserEvent());
  }

  void dispositionalDatas() {
    canChangeSelectedOptionsValueNotifier.dispose();
    amountPerOptionTextEditingController.removeListener(amountPerOptionsTextEditingController);
    amountPerOptionTextEditingController.dispose();
    amountPerOptionsValueNotifier.dispose();
    websocketChannel?.sink.close();
    currentWebsocketServerModelValueNotifier.dispose();
    oneLastOneMinGameModelValueNotifier.dispose();
    currentGameTimerValueNotifier.dispose();
    gameSecondsTimer?.cancel();
    isLoadingValueNotifier.dispose();
    selectedBetOptionValueNotifier.dispose();
    gameHistoryValueNotifier.dispose();
    currentGameNumbersValueNotifier.dispose();
    listOfSelectedUserBetOptionsValueNotifier.dispose();
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
      backgroundColor: const Color(0xFF2C2F3F),
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: isLoadingValueNotifier,
          builder: (context, isLoading, _) {
            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            return Column(
              children: [
                // Top Bar with History
                Container(
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF1F222E),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: context.pop,
                          ),
                          Text(
                            getGameTypeTitle(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
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
                      ),
                      const SizedBox(height: 16),
                      // Game History
                      _buildGameHistory(),
                    ],
                  ),
                ),
                
                // Main Game Area
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Timer Section
                          _buildTimerSection(),
                          const SizedBox(height: 24),
                          
                          // Game Grid
                          _buildGameGrid(),
                          const SizedBox(height: 32),
                          
                          // Betting Options
                          _buildBettingOptionsSection(),
                          const SizedBox(height: 24),
                          
                          // Balance and Input Section
                          _buildBalanceAndInputSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGameHistory() {
    return ValueListenableBuilder<List<OneMinGameModel>>(
      valueListenable: gameHistoryValueNotifier,
      builder: (context, gameHistory, _) {
        return SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: gameHistory.length,
            itemBuilder: (context, index) {
              final game = gameHistory[index];
              final gameNumber = game.eachGameUniqueNumber % 100;
              final numberColor = getGameNumberColor(gameNumber);
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: numberColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$gameNumber',
                    style: TextStyle(
                      color: numberColor == Colors.white ? Colors.black : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTimerSection() {
    return ValueListenableBuilder<WebsocketServerModel>(
      valueListenable: currentWebsocketServerModelValueNotifier,
      builder: (context, websocketModel, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1F222E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: currentGameTimerValueNotifier,
                builder: (context, seconds, _) {
                  return Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: seconds <= 15 ? Colors.red : Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '00:${seconds.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: seconds <= 15 ? Colors.red : Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 24),
              Text(
                'Round #${websocketModel.oneMinGame.eachGameUniqueNumber}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F222E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Numbers Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 15,
            itemBuilder: (context, index) {
              final number = index + 1;
              final numberColor = getGameNumberColor(number);
              
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2F3F),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: numberColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: numberColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$number',
                        style: TextStyle(
                          color: number == 15 ? Colors.black : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBettingOptionsSection() {
    return ValueListenableBuilder<List<UserBetOptions>>(
      valueListenable: listOfSelectedUserBetOptionsValueNotifier,
      builder: (context, selectedOptions, _) {
        return Row(
          children: [
            // Red Option
            Expanded(
              child: _buildBetOption(
                title: 'Red',
                multiplier: '1.98x',
                color: const Color(0xFFDC3545),
                option: UserBetOptions.red,
                isSelected: selectedOptions.contains(UserBetOptions.red),
                icon: Icons.circle,
              ),
            ),
            const SizedBox(width: 12),
            // White Option
            Expanded(
              child: _buildBetOption(
                title: 'White', 
                multiplier: '13.87x',
                color: Colors.white,
                option: UserBetOptions.purple,
                isSelected: selectedOptions.contains(UserBetOptions.purple),
                icon: Icons.circle,
              ),
            ),
            const SizedBox(width: 12),
            // Black Option
            Expanded(
              child: _buildBetOption(
                title: 'Black',
                multiplier: '1.98x',
                color: const Color(0xFF6C757D),
                option: UserBetOptions.black,
                isSelected: selectedOptions.contains(UserBetOptions.black),
                icon: Icons.circle,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBetOption({
    required String title,
    required String multiplier,
    required Color color,
    required UserBetOptions option,
    required bool isSelected,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => addOrRemoveUserBetOptionsInListOfUserBetOptions(userBetOptions: option),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.2) 
              : const Color(0xFF1F222E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFF2C2F3F),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              multiplier,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
