import 'package:base_repository/base_repository.dart';
import 'package:network_repository/network_repository.dart';
import 'package:red_black_game_repository/src/configs/red_black_game_configs.dart';
import 'package:red_black_game_repository/src/enums/red_black_game_enums.dart';
import 'package:red_black_game_repository/src/models/red_black_game_model.dart';

typedef RedBlackGames = List<RedBlackGameModel>;

class RedBlackGameFunctions {
  const RedBlackGameFunctions();

  String convertRedBlackGameResultToString(
          {required RedBlackGameResult redBlackGameResult}) =>
      redBlackGameResult.name;

  RedBlackGameResult? convertStringToRedBlackGameResult({required String result}) {
    if (result.trim().isEmpty) {
      return null;
    }
    return RedBlackGameResult.values
        .firstWhere((e) => e.name.toLowerCase() == result.toLowerCase());
  }

  RedBlackGameType convertStringToGameType({required String gameType}) =>
      RedBlackGameType.values.firstWhere((e) => e.name == gameType);

  RedBlackUserBetOptions convertStringToUserBetOptions({required String option}) =>
      RedBlackUserBetOptions.values.firstWhere(
        (e) => e.name.toLowerCase() == option.toLowerCase(),
      );

  String convertGameTypeToNormalString({required RedBlackGameType gameType}) {
    switch (gameType) {
      case RedBlackGameType.red_black_30s:
        return 'Red Black 30s Game';
      case RedBlackGameType.red_black_1min:
        return 'Red Black 1 Min Game';
      case RedBlackGameType.red_black_3min:
        return 'Red Black 3 Min Game';
    }
  }

  String convertGameTypeMinutes({required RedBlackGameType gameType}) {
    switch (gameType) {
      case RedBlackGameType.red_black_30s:
        return '30 Seconds';
      case RedBlackGameType.red_black_1min:
        return '1 Minute';
      case RedBlackGameType.red_black_3min:
        return '3 Minutes';
    }
  }

  int getSecondsByGameType({required RedBlackGameType gameType}) {
    switch (gameType) {
      case RedBlackGameType.red_black_30s:
        return 30;
      case RedBlackGameType.red_black_1min:
        return 60;
      case RedBlackGameType.red_black_3min:
        return 180;
    }
  }

  Future<List<RedBlackGameModel>> getOldRedBlackGamesByGameTypeAndPage({
    required String token,
    required RedBlackGameType gameType,
    required int page,
  }) async {
    try {
      final NetworkRepositoryFunctions networkRepositoryFunctions =
          const NetworkRepositoryFunctions();
      final response = await networkRepositoryFunctions.sendGetRequest(
        endpointUrl: '${RedBlackGameConfigs.getOldRedBlackGamesByGameTypePerPage}?game_type=${gameType.name}&page=$page',
        token: token,
      );
      return RedBlackGameModel.getListOfGamesByJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<RedBlackGameModel> getRedBlackGameWithGameHash({
    required String token,
    required String gameHash,
  }) async {
    try {
      final NetworkRepositoryFunctions networkRepositoryFunctions =
          const NetworkRepositoryFunctions();
      final response = await networkRepositoryFunctions.sendGetRequest(
        endpointUrl: '${RedBlackGameConfigs.getGameWithGameHash}?game_hash=$gameHash',
        token: token,
      );
      return RedBlackGameModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }
}