import 'package:base_repository/base_repository.dart';

abstract class WithdrawRepositoryConfigs {
  static const String createWithdraw = '${BaseConfigs.baseUrl}/create-withdraw';
  static const String getWithdrawByCreator =
      '${BaseConfigs.baseUrl}/get-withdraw-by-creator';
  static const String getWithdrawByTransactionId =
      '${BaseConfigs.baseUrl}/get-withdraw-by-transaction-id';
  static const String getWithdrawsByStatusAndPage =
      '${BaseConfigs.baseUrl}/get-withdraws-by-status-and-page';
  static const changeWithdrawStatus =
      '${BaseConfigs.baseUrl}/change-withdraw-status';
}
