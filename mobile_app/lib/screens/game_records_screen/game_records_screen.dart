import 'package:flutter/material.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:user_bet_repository/user_bet_repository.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/utils/functions.dart';
import 'package:winball/widgets/widgets.dart';

class GameRecordsScreen extends StatefulWidget {
  const GameRecordsScreen({super.key});

  @override
  State<GameRecordsScreen> createState() => _GameRecordsScreenState();
}

class _GameRecordsScreenState extends State<GameRecordsScreen> {
  late final Functions functions;
  late final OneMinGameFunctions oneMinGameFunctions;
  late final ValueNotifier<bool> hasMoreDatasValueNotifier;
  int page = 1;
  late final ValueNotifier<List<UserBetModel>> userBetsValueNotifier;
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final UserBetRepositoryFunctions userBetsRepositoryFunctions;
  void initializeDatas() {
    functions = const Functions();
    oneMinGameFunctions = const OneMinGameFunctions();
    userBetsRepositoryFunctions = const UserBetRepositoryFunctions();
    hasMoreDatasValueNotifier = ValueNotifier<bool>(true);
    userBetsValueNotifier = ValueNotifier<List<UserBetModel>>([]);
    isLoadingValueNotifier = ValueNotifier<bool>(false);
    loadUserBets();
  }

  void dispositionalDatas() {
    hasMoreDatasValueNotifier.dispose();
    userBetsValueNotifier.dispose();
    isLoadingValueNotifier.dispose();
  }

  void changeHasMoreDatasValueNotifier({required bool hasMoreDatas}) {
    hasMoreDatasValueNotifier.value = hasMoreDatas;
  }

  void changeUserBetsValueNotifier({required List<UserBetModel> userBets}) {
    userBetsValueNotifier.value = [...userBets];
  }

  void changeIsLoadingValueNotifier({bool? isLoading}) {
    isLoadingValueNotifier.value = isLoading ?? !isLoadingValueNotifier.value;
  }

  void addListOfUserBetsToListOfUserBetsValueNotifier(
      {required List<UserBetModel> userBets}) {
    final List<UserBetModel> bets = userBetsValueNotifier.value;
    changeUserBetsValueNotifier(userBets: []);
    bets.addAll(userBets);
    changeUserBetsValueNotifier(userBets: bets);
  }

  Future<void> loadUserBets() async {
    try {
      if (hasMoreDatasValueNotifier.value) {
        changeIsLoadingValueNotifier(
          isLoading: true,
        );
        final List<UserBetModel> bets =
            await userBetsRepositoryFunctions.getUserBetsPerPage(
          token: context.readAppBloc.state.currentUser.token ?? '',
          page: page,
        );
        addListOfUserBetsToListOfUserBetsValueNotifier(userBets: bets);
        page++;
        changeIsLoadingValueNotifier(
          isLoading: false,
        );
        changeHasMoreDatasValueNotifier(hasMoreDatas: bets.isNotEmpty);
      }
    } catch (e) {
      changeIsLoadingValueNotifier(
        isLoading: false,
      );
    }
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
          AppTexts.gameRecords,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder<List<UserBetModel>>(
              valueListenable: userBetsValueNotifier,
              builder: (context, userBets, _) {
                if (userBets.isEmpty) {
                  return const CustomErrorWidget(
                        error: AppTexts.noRecords,
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                        itemCount: userBets.length,
                        itemBuilder: (context, index) {
                          final UserBetModel userBet = userBets[index];
                          final List<UserBetOptions> userBetOptions = functions
                              .convertUserBetStringToListUserBetOptions(
                                  userBets: userBet.userChoices);
                          final OneMinGameResult? oneMinGameResult =
                              userBet.game.gameResult;
                          if (oneMinGameResult != null) {
                            return GameRecordsItemTileWidget(
                              userBet: userBet,
                              functions: functions,
                              userBetOptions: userBetOptions,
                              oneMinGameResult: oneMinGameResult,
                            );
                    }
                            return const SizedBox.shrink();
                        },
                      );
              },
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isLoadingValueNotifier,
            builder: (context, isLaoding, _) {
              return isLaoding
                  ? const LoadingWidget()
                  : const SizedBox.shrink();
            },
          ),
          const CustomSpaceWidget(),
          ValueListenableBuilder<bool>(
            valueListenable: hasMoreDatasValueNotifier,
            builder: (context, hasMoreDatas, _) {
              return hasMoreDatas
                  ? TextButton(
                      onPressed: () {
                        loadUserBets();
                      },
                      child: const Text(
                        AppTexts.loadMore,
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}