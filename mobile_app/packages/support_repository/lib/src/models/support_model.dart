import 'dart:convert';

import 'package:base_repository/base_repository.dart';
import 'package:support_repository/src/enums/support_enums.dart';
import 'package:support_repository/src/functions/support_repository_functions.dart';
import 'package:user_repository/user_repository.dart';

class SupportModel implements BaseModel {
  final int id;
  final String messageValue;
  final MessageType messageType;
  final int creatorId;
  final UserModel creator;
  final String roomId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupportModel({
    required this.id,
    required this.messageValue,
    required this.messageType,
    required this.creatorId,
    required this.creator,
    required this.roomId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  SupportModel copyWith({
    String? messageValue,
    MessageType? messageType,
    int? creatorId,
    UserModel? creator,
    String? roomId,
  }) {
    return SupportModel(
      id: id,
      messageValue: messageValue ?? this.messageValue,
      messageType: messageType ?? this.messageType,
      creatorId: creatorId ?? this.creatorId,
      creator: creator ?? this.creator,
      roomId: roomId ?? this.roomId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  factory SupportModel.fromMap({required Map<String, dynamic> mapData}) {
    return SupportModel(
      id: mapData['id'].toString().convertToNum.toInt(),
      messageValue: mapData['message_value'],
      messageType: const SupportRepositoryFunctions()
          .convertStringToMessageType(messageType: mapData['message_type']),
      creatorId: mapData['creator_id'].toString().convertToNum.toInt(),
      creator: UserModel.fromMap(mapData: mapData['creator']),
      roomId: mapData['room_id'],
      createdAt: DateTime.parse(mapData['created_at']),
      updatedAt: DateTime.parse(mapData['updated_at']),
    );
  }
  @override
  factory SupportModel.fromJson({required String jsonData}) =>
      SupportModel.fromMap(mapData: jsonDecode(jsonData));
  @override
  String get toJson => jsonEncode(toMap);

  @override
  Map<String, dynamic> get toMap => {
        'id': '$id',
        'message_value': messageValue,
        'message_type': messageType.name,
        'creator_id': '$creatorId',
        'creator': creator.toMap,
        'room_id': roomId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
  static List<SupportModel> getListOfSupportsByJsonData(
      {required String jsonData}) {
    final List<SupportModel> supports = [];
    if (jsonData.isValidJson) {
      final List<dynamic> listOfMaps = jsonDecode(jsonData);
      for (final Map<String, dynamic> mapData in listOfMaps) {
        supports.add(SupportModel.fromMap(mapData: mapData));
      }
    }
    return supports;
  }
}
