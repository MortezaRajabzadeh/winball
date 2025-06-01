import 'dart:convert';

import 'package:base_repository/base_repository.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:user_bet_repository/src/enums/user_bet_enums.dart';
import 'package:user_bet_repository/src/functions/user_bet_repository_functions.dart';
import 'package:user_repository/user_repository.dart';

class UserBetModel implements BaseModel {
  final int id;
  final int gameId;
  final OneMinGameModel game;
  final String userChoices;
  final String endGameResult;
  final BetStatus betStatus;
  final int creatorId;
  final UserModel creator;
  final String amount;
  final CoinType coinType;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserBetModel({
    required this.id,
    required this.gameId,
    required this.game,
    required this.userChoices,
    required this.endGameResult,
    required this.betStatus,
    required this.creatorId,
    required this.creator,
    required this.amount,
    required this.coinType,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  UserBetModel copyWith({
    int? gameId,
    OneMinGameModel? game,
    String? userChoices,
    String? endGameResult,
    BetStatus? betStatus,
    int? creatorId,
    CoinType? coinType,
    UserModel? creator,
    String? amount,
  }) {
    return UserBetModel(
      id: id,
      gameId: gameId ?? this.gameId,
      game: game ?? this.game,
      userChoices: userChoices ?? this.userChoices,
      endGameResult: endGameResult ?? this.endGameResult,
      betStatus: betStatus ?? this.betStatus,
      creatorId: creatorId ?? this.creatorId,
      creator: creator ?? this.creator,
      amount: amount ?? this.amount,
      coinType: coinType ?? this.coinType,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  factory UserBetModel.fromJson({required String jsonData}) =>
      UserBetModel.fromMap(mapData: jsonDecode(jsonData));
  @override
  factory UserBetModel.fromMap({required Map<String, dynamic> mapData}) {
    return UserBetModel(
      id: mapData['id'].toString().convertToNum.toInt(),
      gameId: mapData['game_id'].toString().convertToNum.toInt(),
      game: OneMinGameModel.fromMap(mapData: mapData['game']),
      userChoices: mapData['user_choices'],
      endGameResult: mapData['end_game_result'] == null
          ? ''
          : mapData['end_game_result']['String'] ?? '',
      betStatus: const UserBetRepositoryFunctions()
          .convertStringToBetStatus(betStatus: mapData['bet_status']),
      creatorId: mapData['creator_id'].toString().convertToNum.toInt(),
      creator: UserModel.fromMap(mapData: mapData['creator']),
      amount: mapData['amount'].toString(),
      coinType: const BaseRepositoryFunctions()
          .convertStringToCoinType(coinType: mapData['coin_type']),
      createdAt: DateTime.parse(mapData['created_at']),
      updatedAt: DateTime.parse(mapData['updated_at']),
    );
  }

  @override
  String get toJson => jsonEncode(toMap);

  @override
  Map<String, dynamic> get toMap => {
        'id': '$id',
        'game_id': '$gameId',
        'game': game.toMap,
        'user_choices': userChoices,
        'end_game_result': endGameResult,
        'bet_status': betStatus.name,
        'creator_id': '$creatorId',
        'creator': creator.toMap,
        'amount': amount,
        'coin_type': coinType.name,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
  static List<UserBetModel> getListOfUserBetsByJson(
      {required String jsonData}) {
    final List<UserBetModel> userBets = [];
    if (jsonData.isValidJson) {
      final List<dynamic> listOfMaps = jsonDecode(jsonData);
      for (final Map<String, dynamic> mapData in listOfMaps) {
        userBets.add(UserBetModel.fromMap(mapData: mapData));
      }
    }
    return userBets;
  }
}
