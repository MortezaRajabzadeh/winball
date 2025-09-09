import 'dart:convert';
import 'dart:developer' as developer;

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
  factory WebsocketServerModel.fromJson({required String jsonData}) {
    try {
      // بررسی داده‌های ساده مثل Result: null
      if (jsonData.contains('Result:')) {
        final result = jsonData.replaceAll('Result: ', '').trim();
        developer.log('دریافت داده ساده وب‌سوکت: $result');
        
        // مقدار پیش‌فرض برگردان
        return WebsocketServerModel(
          command: 'result',
          oneMinGame: OneMinGameModel.empty,
          seconds: 0,
        );
      }
      
      // تبدیل داده‌های JSON استاندارد
      return WebsocketServerModel.fromMap(mapData: jsonDecode(jsonData));
    } catch (e) {
      developer.log('خطا در تبدیل داده‌های وب سوکت: $e');
      developer.log('داده دریافتی: $jsonData');
      
      // مقدار پیش‌فرض برگردان در صورت خطا
      return WebsocketServerModel(
        command: '',
        oneMinGame: OneMinGameModel.empty,
        seconds: 0,
      );
    }
  }
  factory WebsocketServerModel.fromMap(
      {required Map<String, dynamic> mapData}) {
    try {
      return WebsocketServerModel(
        command: mapData['command'] ?? '',
        oneMinGame: mapData['value'] != null 
          ? OneMinGameModel.fromMap(mapData: mapData['value'])
          : OneMinGameModel.empty,
        seconds: mapData['game_seconds_remains'] != null
          ? mapData['game_seconds_remains'].toString().convertToNum.toInt()
          : 0,
      );
    } catch (e) {
      developer.log('خطا در تبدیل داده‌های map وب سوکت: $e');
      developer.log('داده دریافتی: $mapData');
      return WebsocketServerModel(
        command: '',
        oneMinGame: OneMinGameModel.empty,
        seconds: 0,
      );
    }
  }
}
