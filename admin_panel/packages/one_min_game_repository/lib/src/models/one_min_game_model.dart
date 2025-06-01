import 'dart:convert';

import 'package:base_repository/base_repository.dart';
import 'package:one_min_game_repository/src/functions/one_min_game_functions.dart';
import '../enums/one_min_game_enums.dart';

class OneMinGameModel implements BaseModel {
  final int id;
  final int eachGameUniqueNumber;
  final GameType gameType;
  final String gameHash;
  final OneMinGameResult? gameResult;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OneMinGameModel({
    required this.id,
    required this.eachGameUniqueNumber,
    required this.gameType,
    required this.gameHash,
    required this.gameResult,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  OneMinGameModel copyWith({
    String? gameHash,
    GameType? gameType,
    OneMinGameResult? gameResult,
  }) {
    return OneMinGameModel(
      id: id,
      eachGameUniqueNumber: eachGameUniqueNumber,
      gameType: gameType ?? this.gameType,
      gameHash: gameHash ?? this.gameHash,
      gameResult: gameResult ?? this.gameResult,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String get toJson => jsonEncode(toMap);

  @override
  Map<String, dynamic> get toMap => {
        'id': '$id',
        'each_game_unique_number': '$eachGameUniqueNumber',
        'game_type': gameType.name,
        'game_hash': gameHash,
        'game_result': {'String': gameResult?.name},
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
  @override
  factory OneMinGameModel.fromMap({required Map<String, dynamic> mapData}) {
    final String gameResult =
        (mapData['game_result'] == null ? '' : mapData['game_result']['String'])
            .trim();
    return OneMinGameModel(
      id: mapData['id'].toString().convertToNum.toInt(),
      eachGameUniqueNumber:
          mapData['each_game_unique_number'].toString().convertToNum.toInt(),
      gameType: const OneMinGameFunctions()
          .convertStringToGameType(gameType: mapData['game_type']),
      gameHash: mapData['game_hash'],
      gameResult: const OneMinGameFunctions()
          .convertStringToOneMinGameResult(result: gameResult),
      createdAt: DateTime.parse(mapData['created_at']),
      updatedAt: DateTime.parse(mapData['updated_at']),
    );
  }
  @override
  factory OneMinGameModel.fromJson({required String jsonData}) =>
      OneMinGameModel.fromMap(
        mapData: jsonDecode(
          jsonData,
        ),
      );
  static List<OneMinGameModel> getListOfGamesByJson(
      {required String jsonData}) {
    final List<OneMinGameModel> games = [];
    if (jsonData.isValidJson) {
      final List<dynamic> listOfMaps = jsonDecode(jsonData);
      for (final Map<String, dynamic> mapData in listOfMaps) {
        games.add(OneMinGameModel.fromMap(mapData: mapData));
      }
    }
    return games;
  }

  static OneMinGameModel empty = OneMinGameModel(
    id: -1,
    eachGameUniqueNumber: -1,
    gameHash: 'gameHash',
    gameType: GameType.one_min_game,
    gameResult: OneMinGameResult.red2,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
  @override
  bool operator ==(covariant OneMinGameModel other) =>
      id == other.id &&
      eachGameUniqueNumber == other.eachGameUniqueNumber &&
      gameType == other.gameType &&
      gameHash == other.gameHash &&
      gameResult == other.gameResult &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt;
  @override
  int get hashCode =>
      id.hashCode ^
      eachGameUniqueNumber.hashCode ^
      gameType.hashCode ^
      gameHash.hashCode ^
      gameResult.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
