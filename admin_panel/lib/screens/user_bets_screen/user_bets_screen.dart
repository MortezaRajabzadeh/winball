import 'package:flutter/material.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:user_bet_repository/user_bet_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/extensions/extensions.dart';
import 'package:winball_admin_panel/utils/functions.dart';
import 'package:winball_admin_panel/widgets/global/custom_error_widget.dart';
import 'package:winball_admin_panel/widgets/global/game_record_item_tile_widget.dart';
import 'package:winball_admin_panel/widgets/global/loading_widget.dart';

class UserBetsScreen extends StatefulWidget {
  const UserBetsScreen({
    super.key,
    required this.user,
  });
  final UserModel user;

  @override
  State<UserBetsScreen> createState() => _UserBetsScreenState();
}

class _UserBetsScreenState extends State<UserBetsScreen> {
  late final UserBetRepositoryFunctions userBetRepositoryFunctions;
  late final UserModel currentUser;
  late final Functions functions;
  void initializeDatas() {
    userBetRepositoryFunctions = const UserBetRepositoryFunctions();
    currentUser = context.readAppBloc.state.currentUser;
    functions = const Functions();
  }

  void dispositionalDatas() {}
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
          AppTexts.userBets,
        ),
      ),
      body: FutureBuilder<List<UserBetModel>>(
        future: userBetRepositoryFunctions.getUserBetsByUserId(
          userId: widget.user.id,
          token: currentUser.token ?? '',
        ),
        builder: (context, AsyncSnapshot<List<UserBetModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          } else if (snapshot.hasData && (snapshot.data ?? []).isNotEmpty) {
            final List<UserBetModel> userBets = snapshot.data ?? [];
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                        '${AppTexts.wholeLoseAmount} ${functions.addAmountOfUserBets(
                              userBets: userBets
                                  .where(
                                      (userBet) => userBet.endGameResult == '0')
                                  .toList(),
                            ).toStringAsFixed(3)} ${AppTexts.ton}'),
                    Text(
                        '${AppTexts.wholeWinAmount} ${functions.addEndGameResultOfUserBets(
                              userBets: userBets
                                  .where(
                                      (userBet) => userBet.endGameResult != '0')
                                  .toList(),
                            ).toStringAsFixed(3)} ${AppTexts.ton}'),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: userBets.length,
                    itemBuilder: (context, index) {
                      final UserBetModel userBet = userBets[index];
                      final List<UserBetOptions> userBetOptions =
                          functions.convertUserBetStringToListUserBetOptions(
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
                      } else {
                        return const SizedBox.shrink();
                      }
                      // return ListTile(
                      //   title: Text(
                      //       '${userBet.coinType.name} ${userBet.coinType == CoinType.ton ? double.parse(userBet.amount) / AppConfigs.tonBaseFactory : userBet.amount}'),
                      //   subtitle: Text(
                      //     '${functions.convertDateTimeToDateAndTime(
                      //       dateTime: userBet.createdAt,
                      //     )} - ${AppTexts.gameId} ${userBet.gameId}',
                      //   ),
                      // );
                    },
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return CustomErrorWidget(
              error: snapshot.error.toString(),
            );
          } else {
            return const CustomErrorWidget();
          }
        },
      ),
    );
  }
}
