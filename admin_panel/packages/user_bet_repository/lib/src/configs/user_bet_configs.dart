import 'package:base_repository/base_repository.dart';

abstract class UserBetConfigs {
  static const String createUserBet = '${BaseConfigs.baseUrl}/create-user-bet';
  static const String editUserBet = '${BaseConfigs.baseUrl}/edit-user-bet';
  static const String getUserBets = '${BaseConfigs.baseUrl}/get-user-bets';
  static const String getUserBetsByGameId =
      '${BaseConfigs.baseUrl}/get-user-bet-by-game-id';
  static const String getTwoLastUserBets =
      '${BaseConfigs.baseUrl}/get-two-last-user-bets';
  static const String getUserBetsPerPage =
      '${BaseConfigs.baseUrl}/get-user-bets-per-page';
  static const String getUserBetsByUserId =
      '${BaseConfigs.baseUrl}/get-user-bets-by-user-id';
}
