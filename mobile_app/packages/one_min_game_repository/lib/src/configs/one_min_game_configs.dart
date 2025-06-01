import 'package:base_repository/base_repository.dart';

abstract class OneMinGameConfigs {
  static const String getLastOneMinGame =
      '${BaseConfigs.baseUrl}/get-last-one-min-game';
  static const String getGameWithGameHash =
      '${BaseConfigs.baseUrl}/get-game-with-game-hash';
  static const String getTwoLastOneMinGame =
      '${BaseConfigs.baseUrl}/get-two-last-one-min-game';
  static const String getTwoLastOneMinGameByGameType =
      '${BaseConfigs.baseUrl}/get-two-last-one-min-game-by-game-type';
  static const String getOneMinGameWithId =
      '${BaseConfigs.baseUrl}/get-one-min-game-with-id';
  static const String gameWebsocketUrl =
      '${BaseConfigs.baseWebsocketConnection}/ws';
  static const String getOldOneMinGamesPerPage =
      '${BaseConfigs.baseUrl}/get-old-one-min-games-per-page';
  static const String getOldOneMinGamesByGameTypePerPage =
      '${BaseConfigs.baseUrl}/get-old-one-min-games-by-game-type-and-page';
}
