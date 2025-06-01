import 'dart:convert';

import 'package:base_repository/base_repository.dart';

class TeamReportModel implements BaseModel {
  final int registerationUsers;
  final double firstDepositTonUsers;
  final double firstDepositStarsUsers;
  final double depositsTonUsers;
  final double depositsStarsUsers;
  final double withdrawTonUsers;
  final double withdrawStarsUsers;
  const TeamReportModel({
    required this.registerationUsers,
    required this.firstDepositTonUsers,
    required this.firstDepositStarsUsers,
    required this.depositsTonUsers,
    required this.depositsStarsUsers,
    required this.withdrawTonUsers,
    required this.withdrawStarsUsers,
  });
  @override
  TeamReportModel copyWith({
    int? registerationUsers,
    double? firstDepositTonUsers,
    double? firstDepositStarsUsers,
    double? depositsTonUsers,
    double? depositsStarsUsers,
    double? withdrawTonUsers,
    double? withdrawStarsUsers,
  }) {
    return TeamReportModel(
      registerationUsers: registerationUsers ?? this.registerationUsers,
      firstDepositTonUsers: firstDepositTonUsers ?? this.firstDepositTonUsers,
      firstDepositStarsUsers:
          firstDepositStarsUsers ?? this.firstDepositStarsUsers,
      depositsTonUsers: depositsTonUsers ?? this.depositsTonUsers,
      depositsStarsUsers: depositsStarsUsers ?? this.depositsStarsUsers,
      withdrawTonUsers: withdrawTonUsers ?? this.withdrawTonUsers,
      withdrawStarsUsers: withdrawStarsUsers ?? this.withdrawStarsUsers,
    );
  }

  @override
  String get toJson => jsonEncode(toMap);

  @override
  Map<String, dynamic> get toMap => {};
  @override
  factory TeamReportModel.fromJson({required String jsonData}) =>
      TeamReportModel.fromMap(mapData: jsonDecode(jsonData));
  @override
  factory TeamReportModel.fromMap({required Map<String, dynamic> mapData}) {
    return TeamReportModel(
      registerationUsers:
          mapData['registration_users'].toString().convertToNum.toInt(),
      firstDepositTonUsers:
          mapData['first_deposit_ton_users'].toString().convertToNum.toDouble(),
      firstDepositStarsUsers: mapData['first_deposit_stars_users']
          .toString()
          .convertToNum
          .toDouble(),
      depositsTonUsers:
          mapData['deposit_ton_users'].toString().convertToNum.toDouble(),
      depositsStarsUsers:
          mapData['deposit_stars_users'].toString().convertToNum.toDouble(),
      withdrawTonUsers:
          mapData['withdraw_ton_users'].toString().convertToNum.toDouble(),
      withdrawStarsUsers:
          mapData['withdraw_stars_users'].toString().convertToNum.toDouble(),
    );
  }
  static const TeamReportModel empty = TeamReportModel(
    registerationUsers: 0,
    firstDepositTonUsers: 0.0,
    firstDepositStarsUsers: 0.0,
    depositsTonUsers: 0.0,
    depositsStarsUsers: 0.0,
    withdrawTonUsers: 0.0,
    withdrawStarsUsers: 0.0,
  );
}
