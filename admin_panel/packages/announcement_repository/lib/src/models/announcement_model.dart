import 'dart:convert';

import 'package:base_repository/base_repository.dart';
import 'package:user_repository/user_repository.dart';

class AnnouncementModel extends BaseModel {
  final int id;
  final String title;
  final String details;
  final int creatorId;
  final UserModel creator;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AnnouncementModel({
    required this.id,
    required this.title,
    required this.details,
    required this.creatorId,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  AnnouncementModel copyWith({
    String? title,
    String? details,
    int? creatorId,
    UserModel? creator,
  }) {
    return AnnouncementModel(
      id: id,
      title: title ?? this.title,
      details: details ?? this.details,
      creatorId: creatorId ?? this.creatorId,
      creator: creator ?? this.creator,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  factory AnnouncementModel.fromJson({required String jsonData}) =>
      AnnouncementModel.fromMap(mapData: jsonDecode(jsonData));
  @override
  factory AnnouncementModel.fromMap({required Map<String, dynamic> mapData}) {
    return AnnouncementModel(
      id: mapData['id'].toString().convertToNum.toInt(),
      title: mapData['title'],
      details: mapData['details'],
      creatorId: mapData['creator_id'].toString().convertToNum.toInt(),
      creator: UserModel.fromMap(mapData: mapData['creator']),
      createdAt: DateTime.parse(mapData['created_at']),
      updatedAt: DateTime.parse(mapData['updated_at']),
    );
  }

  @override
  String get toJson => jsonEncode(toMap);

  @override
  Map<String, dynamic> get toMap => {
        'id': '$id',
        'title': title,
        'details': details,
        'creator_id': '$creatorId',
        'creator': creator.toMap,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
  static List<AnnouncementModel> getListOfAnnouncementsByJson(
      {required String jsonData}) {
    final List<AnnouncementModel> announcements = [];
    if (jsonData.isValidJson) {
      final List<dynamic> listOfMaps = jsonDecode(jsonData);
      for (final Map<String, dynamic> mapData in listOfMaps) {
        announcements.add(AnnouncementModel.fromMap(mapData: mapData));
      }
    }
    return announcements;
  }
}
