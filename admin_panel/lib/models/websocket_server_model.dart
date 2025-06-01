import 'dart:convert';

import 'package:base_repository/base_repository.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';

class WebsocketServerModel {
  final String command;
  final OneMinGameModel oneMinGame;
  final int seconds;

  WebsocketServerModel({
    required this.command,
    required this.oneMinGame,
    required this.seconds,
  });
  factory WebsocketServerModel.fromJson({required String jsonData}) =>
      WebsocketServerModel.fromMap(mapData: jsonDecode(jsonData));
  factory WebsocketServerModel.fromMap(
      {required Map<String, dynamic> mapData}) {
    return WebsocketServerModel(
      command: mapData['command'],
      oneMinGame: OneMinGameModel.fromMap(mapData: mapData['value']),
      seconds: mapData['game_seconds_remains'].toString().convertToNum.toInt(),
    );
  }
}
