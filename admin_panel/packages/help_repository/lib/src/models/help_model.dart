import 'dart:convert';

import 'package:base_repository/base_repository.dart';
import 'package:user_repository/user_repository.dart';

class HelpModel implements BaseModel {
  final int id;
  final String title;
  final String subsection;
  final String description;
  final int creatorId;
  final UserModel creator;
  final DateTime createdAt;
  final DateTime updatedAt;
  @override
  factory HelpModel.fromJson({required String jsonData}) => HelpModel.fromMap(
        mapData: jsonDecode(
          jsonData,
        ),
      );
  @override
  factory HelpModel.fromMap({required Map<String, dynamic> mapData}) {
    return HelpModel(
      id: mapData['id'].toString().convertToNum.toInt(),
      title: mapData['title'],
      subsection: mapData['subsection'],
      description: mapData['description'],
      creatorId: mapData['creator_id'].toString().convertToNum.toInt(),
      creator: UserModel.fromMap(mapData: mapData['creator']),
      createdAt: DateTime.parse(mapData['created_at']),
      updatedAt: DateTime.parse(mapData['updated_at']),
    );
  }

  const HelpModel({
    required this.id,
    required this.title,
    required this.subsection,
    required this.description,
    required this.creatorId,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  HelpModel copyWith({
    String? title,
    String? subsection,
    String? description,
    int? creatorId,
    UserModel? creator,
  }) {
    return HelpModel(
      id: id,
      title: title ?? this.title,
      subsection: subsection ?? this.subsection,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      creator: creator ?? this.creator,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String get toJson => jsonEncode(toMap);

  @override
  Map<String, dynamic> get toMap => {
        'id': '$id',
        'title': title,
        'subsection': subsection,
        'description': description,
        'creator_id': '$creatorId',
        'creator': creator.toMap,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
  static List<HelpModel> getListOfHelpsByJsonData({required String jsonData}) {
    final List<HelpModel> helps = [];
    if (jsonData.isValidJson) {
      final List<dynamic> listOfMaps = jsonDecode(jsonData);
      for (final Map<String, dynamic> mapData in listOfMaps) {
        helps.add(HelpModel.fromMap(mapData: mapData));
      }
    }
    return helps;
  }
}
