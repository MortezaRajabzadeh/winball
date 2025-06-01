import 'dart:convert';

import 'package:base_repository/base_repository.dart';
import 'package:user_repository/user_repository.dart';

class ActivityModel extends BaseModel {
  final int id;
  final String title;
  final String bannerUrl;
  final String details;
  final int creatorId;
  final UserModel creator;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ActivityModel({
    required this.id,
    required this.title,
    required this.bannerUrl,
    required this.details,
    required this.creatorId,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  factory ActivityModel.fromMap({required Map<String, dynamic> mapData}) {
    return ActivityModel(
      id: mapData['id'].toString().convertToNum.toInt(),
      title: mapData['title'],
      bannerUrl: mapData['banner_url'],
      details: mapData['details'],
      creatorId: mapData['creator_id'].toString().convertToNum.toInt(),
      creator: UserModel.fromMap(mapData: mapData['creator']),
      createdAt: DateTime.parse(mapData['created_at']),
      updatedAt: DateTime.parse(mapData['updated_at']),
    );
  }
  @override
  factory ActivityModel.fromJson({required String jsonData}) =>
      ActivityModel.fromMap(mapData: jsonDecode(jsonData));
  @override
  ActivityModel copyWith({
    String? title,
    String? bannerUrl,
    String? details,
    int? creatorId,
    UserModel? creator,
  }) {
    return ActivityModel(
      id: id,
      title: title ?? this.title,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      details: details ?? this.details,
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
        'banner_url': bannerUrl,
        'details': details,
        'creator_id': '$creatorId',
        'creator': creator.toMap,
        'created_at': '',
        'updated_at': '',
      };
  static List<ActivityModel> getActivitiesByJsonData(
      {required String jsonData}) {
    final List<ActivityModel> activities = [];
    if (jsonData.isValidJson) {
      final List<dynamic> listOfMaps = jsonDecode(jsonData);
      for (final Map<String, dynamic> mapData in listOfMaps) {
        activities.add(ActivityModel.fromMap(mapData: mapData));
      }
    }
    return activities;
  }
}
