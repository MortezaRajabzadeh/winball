import 'package:base_repository/base_repository.dart';

abstract class TransactionRepositoryConfigs {
  static const String createTransaction =
      '${BaseConfigs.baseUrl}/create-transaction';
  static const String getTransactionsByCreatorId =
      '${BaseConfigs.baseUrl}/get-transaction-by-creator-id';
  static const String getTransactionsWithStatus =
      '${BaseConfigs.baseUrl}/get-transaction-with-status';
  static const String getTransactionsByTransactionTypeAndStatusAndPage =
      '${BaseConfigs.baseUrl}/get-transactions-by-transaction-type-and-status-and-page';
  static const String getStarsPayment =
      'https://bot.winball.xyz/get-stars-payment';
}
