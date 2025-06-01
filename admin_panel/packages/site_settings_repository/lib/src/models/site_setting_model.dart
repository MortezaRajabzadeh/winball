import 'dart:convert';

import 'package:base_repository/base_repository.dart';
import 'package:user_repository/user_repository.dart';

class SiteSettingModel implements BaseModel {
  final int id;
  final String loadingPicture;
  final int referalPercent;
  final String minWithdrawAmount;
  final String minDepositAmount;
  final int creatorId;
  final UserModel creator;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SiteSettingModel({
    required this.id,
    required this.loadingPicture,
    required this.referalPercent,
    required this.minWithdrawAmount,
    required this.minDepositAmount,
    required this.creatorId,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  factory SiteSettingModel.fromJson({required String jsonData}) =>
      SiteSettingModel.fromMap(mapData: jsonDecode(jsonData));
  @override
  factory SiteSettingModel.fromMap({required Map<String, dynamic> mapData}) {
    return SiteSettingModel(
      id: mapData['id'].toString().convertToNum.toInt(),
      loadingPicture: mapData['loading_picture'] != null &&
              mapData['loading_picture']['String'].isNotEmpty
          ? mapData['loading_picture']['String']
          : null,
      referalPercent:
          mapData['referal_percent'].toString().convertToNum.toInt(),
      minWithdrawAmount: mapData['min_withdraw_amount'].toString(),
      minDepositAmount: mapData['min_deposit_amount'].toString(),
      creatorId: mapData['creator_id'].toString().convertToNum.toInt(),
      creator: UserModel.fromMap(mapData: mapData['creator']),
      createdAt: DateTime.parse(mapData['created_at']),
      updatedAt: DateTime.parse(mapData['updated_at']),
    );
  }
  @override
  SiteSettingModel copyWith({
    String? loadingPicture,
    int? referalPercent,
    String? minWithdrawAmount,
    String? minDepositAmount,
    int? creatorId,
    UserModel? creator,
  }) {
    return SiteSettingModel(
      id: id,
      loadingPicture: loadingPicture ?? this.loadingPicture,
      referalPercent: referalPercent ?? this.referalPercent,
      minWithdrawAmount: minWithdrawAmount ?? this.minWithdrawAmount,
      minDepositAmount: minDepositAmount ?? this.minDepositAmount,
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
        'loading_picture': loadingPicture,
        'referal_percent': '$referalPercent',
        'min_withdraw_amount': minWithdrawAmount,
        'min_deposit_amount': minDepositAmount,
        'creator_id': '$creatorId',
        'creator': creator.toMap,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
  static List<SiteSettingModel> getListOfSiteSettingByJson(
      {required String jsonData}) {
    final List<SiteSettingModel> siteSettings = [];
    if (jsonData.isValidJson) {
      final List<dynamic> listOfMaps = jsonDecode(jsonData);
      for (final Map<String, dynamic> mapData in listOfMaps) {
        siteSettings.add(SiteSettingModel.fromMap(mapData: mapData));
      }
    }
    return siteSettings;
  }

  static SiteSettingModel empty = SiteSettingModel(
    createdAt: DateTime.now(),
    creator: UserModel.empty,
    creatorId: -1,
    id: -1,
    loadingPicture: '',
    minDepositAmount: '',
    minWithdrawAmount: '',
    referalPercent: 0,
    updatedAt: DateTime.now(),
  );
}
