import 'dart:convert';

import 'package:base_repository/base_repository.dart';
import 'package:user_repository/user_repository.dart';

class InvitationModel extends BaseModel {
  final int id;
  final int invitorId;
  final UserModel invitor;
  final int invitedId;
  final UserModel invited;
  final String invitationCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  const InvitationModel({
    required this.id,
    required this.invitorId,
    required this.invitor,
    required this.invitedId,
    required this.invited,
    required this.invitationCode,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  InvitationModel copyWith({
    int? invitorId,
    UserModel? invitor,
    int? invitedId,
    UserModel? invited,
    String? invitationCode,
  }) {
    return InvitationModel(
      id: id,
      invitorId: invitorId ?? this.invitorId,
      invitor: invitor ?? this.invitor,
      invitedId: invitedId ?? this.invitedId,
      invited: invited ?? this.invited,
      invitationCode: invitationCode ?? this.invitationCode,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String get toJson => jsonEncode(toMap);
  @override
  factory InvitationModel.fromJson({required String jsonData}) =>
      InvitationModel.fromMap(mapData: jsonDecode(jsonData));
  @override
  factory InvitationModel.fromMap({required Map<String, dynamic> mapData}) {
    return InvitationModel(
      id: mapData['id'].toString().convertToNum.toInt(),
      invitorId: mapData['invitor_id'].toString().convertToNum.toInt(),
      invitor: UserModel.fromMap(mapData: mapData['invitor']),
      invitedId: mapData['invited_id'].toString().convertToNum.toInt(),
      invited: UserModel.fromMap(mapData: mapData['invited']),
      invitationCode: mapData['invitation_code'],
      createdAt: DateTime.parse(mapData['created_at']),
      updatedAt: DateTime.parse(mapData['updated_at']),
    );
  }
  @override
  Map<String, dynamic> get toMap => {
        'id': '$id',
        'invitor_id': '$invitorId',
        'invitor': invitor.toMap,
        'invited_id': '$invitedId',
        'invited': invited.toMap,
        'invitation_code': invitationCode,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
  static List<InvitationModel> getListOfInvitationByJsonData(
      {required String jsonData}) {
    final List<InvitationModel> invitations = [];
    if (jsonData.isValidJson) {
      final List<dynamic> listOfMaps = jsonDecode(jsonData);
      for (final Map<String, dynamic> mapData in listOfMaps) {
        invitations.add(InvitationModel.fromMap(mapData: mapData));
      }
    }
    return invitations;
  }
}
