import 'package:base_repository/base_repository.dart';
import 'package:network_repository/network_repository.dart';
import 'package:withdraw_repository/src/configs/withdraw_repository_configs.dart';
import 'package:withdraw_repository/src/enums/withdraw_enums.dart';
import 'package:withdraw_repository/src/models/withdraw_model.dart';
import 'package:http/http.dart' as http;

typedef Withdraws = List<WithdrawModel>;

class WithdrawRepositoryFunctions {
  const WithdrawRepositoryFunctions();
  WithdrawStatus convertStringToWithdrawStatus(
          {required String withdrawStatus}) =>
      WithdrawStatus.values.firstWhere((e) => e.name == withdrawStatus);
  Future<WithdrawModel> createWithdraw({
    required String amount,
    required String address,
    required CoinType coinType,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: WithdrawRepositoryConfigs.createWithdraw,
        mapData: {
          'amount': amount,
          'address': address,
          'coin_type': coinType.name,
        },
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return WithdrawModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<Withdraws> getWithdrawByCreator({
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: WithdrawRepositoryConfigs.getWithdrawByCreator,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return WithdrawModel.getListOfWithdrawsByJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<WithdrawModel> getWithdrawByTransactionId({
    required String transactionId,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${WithdrawRepositoryConfigs.getWithdrawByTransactionId}?transaction_id',
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return WithdrawModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<Withdraws> getWithDrawsByStatusAndPage(
      {required WithdrawStatus status,
      int page = 1,
      required String token}) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${WithdrawRepositoryConfigs.getWithdrawsByStatusAndPage}?status=${status.name}&page=$page',
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return WithdrawModel.getListOfWithdrawsByJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changeWithdrawStatus({
    required int withdrawId,
    required WithdrawStatus status,
    required String token,
  }) async {
    try {
      final http.Response response =
          await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${WithdrawRepositoryConfigs.changeWithdrawStatus}?status=${status.name}&withdraw_id=$withdrawId',
        token: token,
      );
      return response.statusCode.isRequestValid;
    } catch (e) {
      rethrow;
    }
  }
}
