import 'package:base_repository/base_repository.dart';
import 'package:network_repository/network_repository.dart';
import 'package:transaction_repository/src/configs/transaction_repository_configs.dart';
import 'package:transaction_repository/src/enums/transaction_enums.dart';
import 'package:transaction_repository/src/models/transaction_model.dart';

typedef Transactions = List<TransactionModel>;

class TransactionRepositoryFunctions {
  const TransactionRepositoryFunctions();
  TransactionType convertStringToTransactionType(
          {required String transactionType}) =>
      TransactionType.values.firstWhere((e) => e.name == transactionType);
  TransactionStatus convertStringToTransactionStatus(
          {required String transactionStatus}) =>
      TransactionStatus.values.firstWhere((e) => e.name == transactionStatus);
  Future<TransactionModel> createTransaction({
    required TransactionType transactionType,
    required String amount,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: TransactionRepositoryConfigs.createTransaction,
        mapData: {
          'transaction_type': transactionType.name,
          'amount': amount,
        },
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
          response: response);
      return TransactionModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<Transactions> getTransactionsByCreatorId({
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: TransactionRepositoryConfigs.getTransactionsByCreatorId,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
          response: response);
      return TransactionModel.getListOfTransactionModelByJson(
          jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<Transactions> getTransactionsWithStatus({
    required TransactionStatus status,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: TransactionRepositoryConfigs.getTransactionsWithStatus,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
          response: response);
      return TransactionModel.getListOfTransactionModelByJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Transactions> getTransactionsByTransactionTypeAndStatusAndPage({
    required TransactionType transactionType,
    required TransactionStatus status,
    int page = 1,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${TransactionRepositoryConfigs.getTransactionsByTransactionTypeAndStatusAndPage}?transaction_type=${transactionType.name}&status=${status.name}&page=$page',
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return TransactionModel.getListOfTransactionModelByJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Transactions> getTransactionsByUserId({
    required int userId,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${TransactionRepositoryConfigs.getTransactionsByUserId}?user_id=$userId',
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return TransactionModel.getListOfTransactionModelByJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }
}
