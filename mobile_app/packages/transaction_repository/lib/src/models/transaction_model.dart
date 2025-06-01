import 'dart:convert';

import 'package:base_repository/base_repository.dart';
import 'package:transaction_repository/src/enums/transaction_enums.dart';
import 'package:transaction_repository/src/functions/transaction_repository_functions.dart';
import 'package:user_repository/user_repository.dart';

class TransactionModel implements BaseModel {
  final int id;
  final CoinType coinType;
  final TransactionType transactionType;
  final String amount;
  final TransactionStatus transactionStatus;
  final String transactionId;
  final String moreInfo;
  final int creatorId;
  final UserModel creator;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.coinType,
    required this.transactionType,
    required this.amount,
    required this.transactionStatus,
    required this.transactionId,
    required this.moreInfo,
    required this.creatorId,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  TransactionModel copyWith({
    CoinType? coinType,
    TransactionType? transactionType,
    String? amount,
    TransactionStatus? transactionStatus,
    String? transactionId,
    String? moreInfo,
    int? creatorId,
    UserModel? creator,
  }) {
    return TransactionModel(
      id: id,
      coinType: coinType ?? this.coinType,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      transactionStatus: transactionStatus ?? this.transactionStatus,
      transactionId: transactionId ?? this.transactionId,
      moreInfo: moreInfo ?? this.moreInfo,
      creatorId: creatorId ?? this.creatorId,
      creator: creator ?? this.creator,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  factory TransactionModel.fromMap({required Map<String, dynamic> mapData}) {
    return TransactionModel(
      id: mapData['id'].toString().convertToNum.toInt(),
      coinType: const BaseRepositoryFunctions()
          .convertStringToCoinType(coinType: mapData['coin_type']),
      transactionType: const TransactionRepositoryFunctions()
          .convertStringToTransactionType(
              transactionType: mapData['transaction_type']),
      amount: mapData['amount'].toString(),
      transactionStatus: const TransactionRepositoryFunctions()
          .convertStringToTransactionStatus(
              transactionStatus: mapData['status']),
      transactionId: mapData['transaction_id'],
      moreInfo: mapData['more_info'] != null &&
              mapData['more_info']['String'].isNotEmpty
          ? mapData['more_info']['String']
          : '',
      creatorId: mapData['creator_id'].toString().convertToNum.toInt(),
      creator: UserModel.fromMap(mapData: mapData['creator']),
      createdAt: DateTime.parse(mapData['created_at']),
      updatedAt: DateTime.parse(mapData['updated_at']),
    );
  }
  @override
  factory TransactionModel.fromJson({required String jsonData}) =>
      TransactionModel.fromMap(mapData: jsonDecode(jsonData));
  @override
  String get toJson => jsonEncode(toMap);

  @override
  Map<String, dynamic> get toMap => {
        'id': '$id',
        'coin_type': coinType.name,
        'transaction_type': transactionType.name,
        'amount': amount,
        'status': transactionStatus.name,
        'transaction_id': transactionId,
        'more_info': {'String': moreInfo},
        'creator_id': '$creatorId',
        'creator': creator.toMap,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
  static List<TransactionModel> getListOfTransactionModelByJson(
      {required String jsonData}) {
    final List<TransactionModel> transactions = [];
    if (jsonData.isValidJson) {
      final List<dynamic> listOfMaps = jsonDecode(jsonData);
      for (final Map<String, dynamic> mapData in listOfMaps) {
        transactions.add(TransactionModel.fromMap(mapData: mapData));
      }
    }
    return transactions;
  }
}
