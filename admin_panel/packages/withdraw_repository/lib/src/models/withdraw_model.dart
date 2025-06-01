import 'dart:convert';

import 'package:base_repository/base_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:withdraw_repository/src/enums/withdraw_enums.dart';
import 'package:withdraw_repository/src/functions/withdraw_repository_functions.dart';

class WithdrawModel implements BaseModel {
  final int id;
  final String amount;
  final String walletAddress;
  final CoinType coinType;
  final WithdrawStatus status;
  final int creatorId;
  final UserModel creator;
  final String transactionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WithdrawModel({
    required this.id,
    required this.amount,
    required this.walletAddress,
    required this.coinType,
    required this.status,
    required this.creatorId,
    required this.creator,
    required this.transactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  factory WithdrawModel.fromJson({required String jsonData}) =>
      WithdrawModel.fromMap(mapData: jsonDecode(jsonData));
  @override
  factory WithdrawModel.fromMap({required Map<String, dynamic> mapData}) {
    return WithdrawModel(
      id: mapData['id'].toString().convertToNum.toInt(),
      amount: mapData['amount'].toString(),
      walletAddress: mapData['wallet_address'],
      coinType: const BaseRepositoryFunctions()
          .convertStringToCoinType(coinType: mapData['coin_type']),
      status: const WithdrawRepositoryFunctions()
          .convertStringToWithdrawStatus(withdrawStatus: mapData['status']),
      creatorId: mapData['creator_id'].toString().convertToNum.toInt(),
      creator: UserModel.fromMap(mapData: mapData['creator']),
      transactionId: mapData['transaction_id'],
      createdAt: DateTime.parse(mapData['created_at']),
      updatedAt: DateTime.parse(mapData['updated_at']),
    );
  }
  @override
  WithdrawModel copyWith({
    String? amount,
    String? walletAddress,
    CoinType? coinType,
    WithdrawStatus? status,
    int? creatorId,
    UserModel? creator,
    String? transactionId,
  }) {
    return WithdrawModel(
      id: id,
      amount: amount ?? this.amount,
      walletAddress: walletAddress ?? this.walletAddress,
      coinType: coinType ?? this.coinType,
      status: status ?? this.status,
      creatorId: creatorId ?? this.creatorId,
      creator: creator ?? this.creator,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String get toJson => jsonEncode(toMap);

  @override
  Map<String, dynamic> get toMap => {
        'id': '$id',
        'amount': amount,
        'wallet_address': walletAddress,
        'coin_type': coinType,
        'status': status.name,
        'creator_id': '$creatorId',
        'creator': creator.toMap,
        'transaction_id': transactionId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
  static List<WithdrawModel> getListOfWithdrawsByJson(
      {required String jsonData}) {
    final List<WithdrawModel> withdraws = [];
    if (jsonData.isValidJson) {
      final List<dynamic> listOfMaps = jsonDecode(jsonData);
      for (final Map<String, dynamic> mapData in listOfMaps) {
        withdraws.add(WithdrawModel.fromMap(mapData: mapData));
      }
    }
    return withdraws;
  }
}
