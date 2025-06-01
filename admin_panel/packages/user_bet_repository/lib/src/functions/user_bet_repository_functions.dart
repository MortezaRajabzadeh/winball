import 'package:base_repository/base_repository.dart';
import 'package:network_repository/network_repository.dart';
import 'package:user_bet_repository/src/configs/user_bet_configs.dart';
import 'package:user_bet_repository/src/enums/user_bet_enums.dart';
import 'package:user_bet_repository/src/models/user_bet_model.dart';

typedef UserBets = List<UserBetModel>;

class UserBetRepositoryFunctions {
  const UserBetRepositoryFunctions();
  BetStatus convertStringToBetStatus({required String betStatus}) =>
      BetStatus.values.firstWhere((e) => e.name == betStatus);
  Future<UserBetModel> createUserBet({
    required int gameId,
    required String userChoices,
    required String amount,
    required CoinType coinType,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: UserBetConfigs.createUserBet,
        mapData: {
          'game_id': '$gameId',
          'user_choices': userChoices,
          'amount': amount,
          'coin_type': coinType.name,
        },
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return UserBetModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserBetModel> editUserBet({
    required int userBetId,
    required String userChoices,
    required String amount,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: UserBetConfigs.editUserBet,
        mapData: {
          'user_bet_id': '$userBetId',
          'user_choices': userChoices,
          'amount': amount,
        },
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return UserBetModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserBets> getUserBets({
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: UserBetConfigs.getUserBets,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return UserBetModel.getListOfUserBetsByJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserBets> getUserBetsByGameId({
    required int gameId,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: '${UserBetConfigs.getUserBetsByGameId}?game_id=$gameId',
        token: token,
      );
      return UserBetModel.getListOfUserBetsByJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserBets> getTwoLastUserBets({
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: UserBetConfigs.getTwoLastUserBets,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return UserBetModel.getListOfUserBetsByJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserBets> getUserBetsPerPage({
    required String token,
    int page = 1,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: '${UserBetConfigs.getUserBetsPerPage}?page=$page',
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return UserBetModel.getListOfUserBetsByJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserBets> getUserBetsByUserId({
    required int userId,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: '${UserBetConfigs.getUserBetsByUserId}?user_id=$userId',
        token: token,
      );
      return UserBetModel.getListOfUserBetsByJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }
}
