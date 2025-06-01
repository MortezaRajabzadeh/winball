import 'dart:convert';

import 'package:base_repository/base_repository.dart';

class LevelModel implements BaseModel {
  final int id;
  final String levelTag;
  final String expToUpgrade;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LevelModel({
    required this.id,
    required this.levelTag,
    required this.expToUpgrade,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  LevelModel copyWith({
    String? levelTag,
    String? expToUpgrade,
  }) {
    return LevelModel(
      id: id,
      levelTag: levelTag ?? this.levelTag,
      expToUpgrade: expToUpgrade ?? this.expToUpgrade,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  factory LevelModel.fromJson({required String jsonData}) =>
      LevelModel.fromMap(mapData: jsonDecode(jsonData));
  @override
  factory LevelModel.fromMap({required Map<String, dynamic> mapData}) {
    return LevelModel(
      id: mapData['id'].toString().convertToNum.toInt(),
      levelTag: mapData['level_tag'],
      expToUpgrade: mapData['exp_to_upgrade'].toString(),
      createdAt: DateTime.parse(mapData['created_at']),
      updatedAt: DateTime.parse(mapData['updated_at']),
    );
  }
  @override
  String get toJson => jsonEncode(toMap);

  @override
  Map<String, dynamic> get toMap => {
        'id': '$id',
        'level_tag': levelTag,
        'exp_to_upgrade': expToUpgrade,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
  static List<LevelModel> getLevelsByListOfJson({required String jsonData}) {
    final List<LevelModel> levels = [];
    if (jsonData.isValidJson) {
      final List<dynamic> listOfMap = jsonDecode(jsonData);
      for (final Map<String, dynamic> mapData in listOfMap) {
        levels.add(LevelModel.fromMap(mapData: mapData));
      }
    }
    return levels;
  }
}
