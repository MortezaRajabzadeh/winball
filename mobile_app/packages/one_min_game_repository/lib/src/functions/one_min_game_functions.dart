import 'package:base_repository/base_repository.dart';
import 'package:network_repository/network_repository.dart';
import 'package:one_min_game_repository/src/configs/one_min_game_configs.dart';
import 'package:one_min_game_repository/src/enums/one_min_game_enums.dart';
import 'package:one_min_game_repository/src/models/one_min_game_model.dart';

typedef OneMinGames = List<OneMinGameModel>;

class OneMinGameFunctions {
  const OneMinGameFunctions();
  String convertOneMinGameResultToString(
          {required OneMinGameResult oneMinGameResult}) =>
      oneMinGameResult.name;
  OneMinGameResult? convertStringToOneMinGameResult({required String result}) {
    if (result.trim().isEmpty) {
      return null;
    }
    return OneMinGameResult.values
        .firstWhere((e) => e.name.toLowerCase() == result.toLowerCase());
  }

  GameType convertStringToGameType({required String gameType}) =>
      GameType.values.firstWhere((e) => e.name == gameType);
  UserBetOptions convertStringToUserBetOptions({required String option}) =>
      UserBetOptions.values.firstWhere(
        (e) => e.name.toLowerCase() == option.toLowerCase(),
      );
  String convertGameTypeToNormalString({required GameType gameType}) {
    switch (gameType) {
      case GameType.one_min_game:
        {
          return 'One Min Game';
        }
      case GameType.three_min_game:
        {
          return 'Three Min Game';
        }
      case GameType.five_min_game:
        {
          return 'Five Min Game';
        }
      case GameType.red_black_30s:
        {
          return 'Red & Black (30s)';
        }
      case GameType.red_black_3m:
        {
          return 'Red & Black (3m)';
        }
      case GameType.red_black_5m:
        {
          return 'Red & Black (5m)';
        }
    }
  }

  String convertGameTypeMinutes({required GameType gameType}) {
    switch (gameType) {
      case GameType.one_min_game:
        {
          return '1 Minute';
        }
      case GameType.three_min_game:
        {
          return '3 Minutes';
        }
      case GameType.five_min_game:
        {
          return '5 Minutes';
        }
      case GameType.red_black_30s:
        {
          return '30 Seconds';
        }
      case GameType.red_black_3m:
        {
          return '3 Minutes';
        }
      case GameType.red_black_5m:
        {
          return '5 Minutes';
        }
    }
  }

  int getSecondsByGameType({required GameType gameType}) {
    switch (gameType) {
      case GameType.five_min_game:
        return 300;
      case GameType.three_min_game:
        return 180;
      case GameType.one_min_game:
        return 60;
      case GameType.red_black_30s:
        return 30;
      case GameType.red_black_3m:
        return 180;
      case GameType.red_black_5m:
        return 300;
    }
  }

  Future<OneMinGameModel> getLastOneMinGame({required String token}) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: OneMinGameConfigs.getLastOneMinGame,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
          response: response);
      return OneMinGameModel.fromJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<OneMinGameModel> getGameWithGameHash({
    required String gameHash,
    required String token,
  }) async {
    try {
      try {
        final response =
            await const NetworkRepositoryFunctions().sendGetRequest(
          endpointUrl:
              '${OneMinGameConfigs.getGameWithGameHash}?game_hash=$gameHash',
          token: token,
        );
        HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
            response: response);
        return OneMinGameModel.fromJson(
          jsonData: response.body,
        );
      } catch (e) {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<OneMinGameModel> getTwoLastOneMinGame({
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: OneMinGameConfigs.getTwoLastOneMinGame,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return OneMinGameModel.fromJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<OneMinGameModel> getTwoLastOneMinGameByGameType({
    required GameType gameType,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${OneMinGameConfigs.getTwoLastOneMinGameByGameType}?game_type=${gameType.name}',
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return OneMinGameModel.fromJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<OneMinGameModel> getOneMinGameWithId({
    required int gameId,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: '${OneMinGameConfigs.getOneMinGameWithId}?game_id=$gameId',
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return OneMinGameModel.fromJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<OneMinGames> getOldOneMinGamesByPage({
    int page = 1,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: '${OneMinGameConfigs.getOldOneMinGamesPerPage}?page=$page',
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return OneMinGameModel.getListOfGamesByJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<OneMinGames> getOldOneMinGamesByGameTypeAndPage({
    int page = 1,
    required String token,
    required GameType gameType,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${OneMinGameConfigs.getOldOneMinGamesByGameTypePerPage}?page=$page&game_type=${gameType.name}',
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return OneMinGameModel.getListOfGamesByJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }
}
