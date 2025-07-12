import 'dart:convert';

import 'package:base_repository/base_repository.dart';
import 'package:red_black_game_repository/src/functions/red_black_game_functions.dart';
import '../enums/red_black_game_enums.dart';

class RedBlackGameModel implements BaseModel {
  final int id;
  final int eachGameUniqueNumber;
  final RedBlackGameType gameType;
  final String gameHash;
  final RedBlackGameResult? gameResult;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RedBlackGameModel({
    required this.id,
    required this.eachGameUniqueNumber,
    required this.gameType,
    required this.gameHash,
    required this.gameResult,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  RedBlackGameModel copyWith({
    String? gameHash,
    RedBlackGameType? gameType,
    RedBlackGameResult? gameResult,
  }) {
    return RedBlackGameModel(
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
  factory RedBlackGameModel.fromMap({required Map<String, dynamic> mapData}) {
    final String gameResult =
        (mapData['game_result'] == null ? '' : mapData['game_result']['String'])
            .trim();
    return RedBlackGameModel(
      id: mapData['id'].toString().convertToNum.toInt(),
      eachGameUniqueNumber:
          mapData['each_game_unique_number'].toString().convertToNum.toInt(),
      gameType: const RedBlackGameFunctions()
          .convertStringToGameType(gameType: mapData['game_type']),
      gameHash: mapData['game_hash'],
      gameResult: const RedBlackGameFunctions()
          .convertStringToRedBlackGameResult(result: gameResult),
      createdAt: DateTime.parse(mapData['created_at']),
      updatedAt: DateTime.parse(mapData['updated_at']),
    );
  }

  @override
  factory RedBlackGameModel.fromJson({required String jsonData}) =>
      RedBlackGameModel.fromMap(
        mapData: jsonDecode(jsonData),
      );

  static List<RedBlackGameModel> getListOfGamesByJson(
      {required String jsonData}) {
    final List<RedBlackGameModel> games = [];
    if (jsonData.isValidJson) {
      final List<dynamic> listOfMaps = jsonDecode(jsonData);
      for (final Map<String, dynamic> mapData in listOfMaps) {
        games.add(RedBlackGameModel.fromMap(mapData: mapData));
      }
    }
    return games;
  }

  static RedBlackGameModel empty = RedBlackGameModel(
    id: -1,
    eachGameUniqueNumber: -1,
    gameHash: 'gameHash',
    gameType: RedBlackGameType.red_black_1min,
    gameResult: RedBlackGameResult.red,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

class RedBlackWebsocketServerModel {
  final String command;
  final RedBlackGameModel redBlackGame;
  final int seconds;

  RedBlackWebsocketServerModel({
    required this.command,
    required this.redBlackGame,
    required this.seconds,
  });
  
  factory RedBlackWebsocketServerModel.fromJson({required String jsonData}) =>
      RedBlackWebsocketServerModel.fromMap(mapData: jsonDecode(jsonData));
      
  factory RedBlackWebsocketServerModel.fromMap(
      {required Map<String, dynamic> mapData}) {
    return RedBlackWebsocketServerModel(
      command: mapData['command'],
      redBlackGame: RedBlackGameModel.fromMap(mapData: mapData['value']),
      seconds: mapData['game_seconds_remains'].toString().convertToNum.toInt(),
    );
  }
}