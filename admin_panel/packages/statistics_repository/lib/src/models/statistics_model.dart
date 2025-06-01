import 'dart:convert';

import 'package:base_repository/base_repository.dart';

class StatisticsModel extends BaseModel {
  final int usersCount;
  final double outgoingTonAmountPerDay;
  final double outgoingTonAmountPerMonth;
  final double outgoingTonAmountPerYear;
  final double incomeTonAmountPerDay;
  final double incomeTonAmountPerMonth;
  final double incomeTonAmountPerYear;
  // final double outgoingStarsAmountPerDay;
  // final double outgoingStarsAmountPerMonth;
  // final double outgoingStarsAmountPerYear;
  // final double incomeStarsAmountPerDay;
  // final double incomeStarsAmountPerMonth;
  // final double incomeStarsAmountPerYear;
  final int winnerCount;
  final int losersCount;

  StatisticsModel({
    required this.usersCount,
    required this.outgoingTonAmountPerDay,
    required this.outgoingTonAmountPerMonth,
    required this.outgoingTonAmountPerYear,
    required this.incomeTonAmountPerDay,
    required this.incomeTonAmountPerMonth,
    required this.incomeTonAmountPerYear,
    // required this.outgoingStarsAmountPerDay,
    // required this.outgoingStarsAmountPerMonth,
    // required this.outgoingStarsAmountPerYear,
    // required this.incomeStarsAmountPerDay,
    // required this.incomeStarsAmountPerMonth,
    // required this.incomeStarsAmountPerYear,
    required this.winnerCount,
    required this.losersCount,
  });

  @override
  StatisticsModel copyWith({
    int? usersCount,
    double? outgoingTonAmountPerDay,
    double? outgoingTonAmountPerMonth,
    double? outgoingTonAmountPerYear,
    double? incomeTonAmountPerDay,
    double? incomeTonAmountPerMonth,
    double? incomeTonAmountPerYear,
    // double? outgoingStarsAmountPerDay,
    // double? outgoingStarsAmountPerMonth,
    // double? outgoingStarsAmountPerYear,
    // double? incomeStarsAmountPerDay,
    // double? incomeStarsAmountPerMonth,
    // double? incomeStarsAmountPerYear,
    int? winnerCount,
    int? losersCount,
  }) {
    return StatisticsModel(
      usersCount: usersCount ?? this.usersCount,
      outgoingTonAmountPerDay:
          outgoingTonAmountPerDay ?? this.outgoingTonAmountPerDay,
      outgoingTonAmountPerMonth:
          outgoingTonAmountPerMonth ?? this.outgoingTonAmountPerMonth,
      outgoingTonAmountPerYear:
          outgoingTonAmountPerYear ?? this.outgoingTonAmountPerYear,
      incomeTonAmountPerDay:
          incomeTonAmountPerDay ?? this.incomeTonAmountPerDay,
      incomeTonAmountPerMonth:
          incomeTonAmountPerMonth ?? this.incomeTonAmountPerMonth,
      incomeTonAmountPerYear:
          incomeTonAmountPerYear ?? this.incomeTonAmountPerYear,
      // outgoingStarsAmountPerDay:
      //     outgoingStarsAmountPerDay ?? this.outgoingStarsAmountPerDay,
      // outgoingStarsAmountPerMonth:
      //     outgoingStarsAmountPerMonth ?? this.outgoingStarsAmountPerMonth,
      // outgoingStarsAmountPerYear:
      //     outgoingStarsAmountPerYear ?? this.outgoingStarsAmountPerYear,
      // incomeStarsAmountPerDay:
      //     incomeStarsAmountPerDay ?? this.incomeStarsAmountPerDay,
      // incomeStarsAmountPerMonth:
      //     incomeStarsAmountPerMonth ?? this.incomeStarsAmountPerMonth,
      // incomeStarsAmountPerYear:
      //     incomeStarsAmountPerYear ?? this.incomeStarsAmountPerYear,
      winnerCount: winnerCount ?? this.winnerCount,
      losersCount: losersCount ?? this.losersCount,
    );
  }

  @override
  factory StatisticsModel.fromMap({required Map<String, dynamic> mapData}) {
    return StatisticsModel(
      usersCount: mapData['users_count'].toString().convertToNum.toInt(),
      outgoingTonAmountPerDay: mapData['outgoing_ton_amount_per_day']
          .toString()
          .convertToNum
          .toDouble(),
      outgoingTonAmountPerMonth: mapData['outgoing_ton_amount_per_month']
          .toString()
          .convertToNum
          .toDouble(),
      outgoingTonAmountPerYear: mapData['outgoing_ton_amount_per_year']
          .toString()
          .convertToNum
          .toDouble(),
      incomeTonAmountPerDay: mapData['income_ton_amount_per_day']
          .toString()
          .convertToNum
          .toDouble(),
      incomeTonAmountPerMonth: mapData['income_ton_amount_per_month']
          .toString()
          .convertToNum
          .toDouble(),
      incomeTonAmountPerYear: mapData['income_ton_amount_per_year']
          .toString()
          .convertToNum
          .toDouble(),
      // outgoingStarsAmountPerDay: mapData['outgoing_stars_amount_per_day']
      //     .toString()
      //     .convertToNum
      //     .toDouble(),
      // outgoingStarsAmountPerMonth: mapData['outgoing_stars_amount_per_month']
      //     .toString()
      //     .convertToNum
      //     .toDouble(),
      // outgoingStarsAmountPerYear: mapData['outgoing_stars_amount_per_year']
      //     .toString()
      //     .convertToNum
      //     .toDouble(),
      // incomeStarsAmountPerDay: mapData['income_stars_amount_per_day']
      //     .toString()
      //     .convertToNum
      //     .toDouble(),
      // incomeStarsAmountPerMonth: mapData['income_stars_amount_per_month']
      //     .toString()
      //     .convertToNum
      //     .toDouble(),
      // incomeStarsAmountPerYear: mapData['income_stars_amount_per_year']
      //     .toString()
      //     .convertToNum
      //     .toDouble(),
      winnerCount: mapData['winner_count'].toString().convertToNum.toInt(),
      losersCount: mapData['losers_count'].toString().convertToNum.toInt(),
    );
  }
  @override
  factory StatisticsModel.fromJson({required String jsonData}) =>
      StatisticsModel.fromMap(mapData: jsonDecode(jsonData));
  @override
  String get toJson => jsonEncode(toMap);

  @override
  Map<String, dynamic> get toMap => {
        'users_count': '$usersCount',
        'outgoing_ton_amount_per_day': '$outgoingTonAmountPerDay',
        'outgoing_ton_amount_per_month': '$outgoingTonAmountPerMonth',
        'outgoing_ton_amount_per_year': '$outgoingTonAmountPerYear',
        'income_ton_amount_per_day': '$incomeTonAmountPerDay',
        'income_ton_amount_per_month': '$incomeTonAmountPerMonth',
        'income_ton_amount_per_year': '$incomeTonAmountPerYear',
        // 'outgoing_stars_amount_per_day': '$outgoingStarsAmountPerDay',
        // 'outgoing_stars_amount_per_month': '$outgoingStarsAmountPerMonth',
        // 'outgoing_stars_amount_per_year': '$outgoingStarsAmountPerYear',
        // 'income_stars_amount_per_day': '$incomeStarsAmountPerDay',
        // 'income_stars_amount_per_month': '$incomeStarsAmountPerMonth',
        // 'income_stars_amount_per_year': '$incomeStarsAmountPerYear',
        'winner_count': '$winnerCount',
        'losers_count': '$losersCount',
      };
  static StatisticsModel empty = StatisticsModel(
    usersCount: 0,
    outgoingTonAmountPerDay: 0,
    outgoingTonAmountPerMonth: 0,
    outgoingTonAmountPerYear: 0,
    incomeTonAmountPerDay: 0,
    incomeTonAmountPerMonth: 0,
    incomeTonAmountPerYear: 0,
    // outgoingStarsAmountPerDay: 0,
    // outgoingStarsAmountPerMonth: 0,
    // outgoingStarsAmountPerYear: 0,
    // incomeStarsAmountPerDay: 0,
    // incomeStarsAmountPerMonth: 0,
    // incomeStarsAmountPerYear: 0,
    winnerCount: 0,
    losersCount: 0,
  );
}
