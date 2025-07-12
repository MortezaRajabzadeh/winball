import 'package:base_repository/base_repository.dart';

abstract class RedBlackGameConfigs {
  static const String getLastRedBlackGame =
      '${BaseConfigs.baseUrl}/get-last-red-black-game';
  static const String getGameWithGameHash =
      '${BaseConfigs.baseUrl}/get-red-black-game-with-game-hash';
  static const String getTwoLastRedBlackGame =
      '${BaseConfigs.baseUrl}/get-two-last-red-black-game';
  static const String getTwoLastRedBlackGameByGameType =
      '${BaseConfigs.baseUrl}/get-two-last-red-black-game-by-game-type';
  static const String getRedBlackGameWithId =
      '${BaseConfigs.baseUrl}/get-red-black-game-with-id';
  static const String gameWebsocketUrl =
      '${BaseConfigs.baseWebsocketConnection}/red-black-ws';
  static const String getOldRedBlackGamesPerPage =
      '${BaseConfigs.baseUrl}/get-old-red-black-games-per-page';
  static const String getOldRedBlackGamesByGameTypePerPage =
      '${BaseConfigs.baseUrl}/get-old-red-black-games-by-game-type-and-page';
}