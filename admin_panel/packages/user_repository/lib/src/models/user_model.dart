import 'dart:convert';

import 'package:base_repository/base_repository.dart';
import 'package:level_repository/level_repository.dart';
import 'package:user_repository/src/src.dart';

class UserModel implements BaseModel {
  final int id;
  final String invitationCode;
  final String? username;
  final String? firstname;
  final String? lastname;
  final String userUniqueNumber;
  final bool isDemoAccount;
  final String tonInventory;
  final String starsInventory;
  final String usdtInventory;
  final String btcInventory;
  final String cusdInventory;
  final String? userProfile;
  final String totalWagered;
  final String totalBets;
  final String totalWins;
  final int levelId;
  final LevelModel level;
  final String experience;
  final UserType userType;
  final String? token;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.invitationCode,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.userUniqueNumber,
    required this.isDemoAccount,
    required this.tonInventory,
    required this.starsInventory,
    required this.usdtInventory,
    required this.cusdInventory,
    required this.btcInventory,
    required this.userProfile,
    required this.totalWagered,
    required this.totalBets,
    required this.totalWins,
    required this.levelId,
    required this.level,
    required this.experience,
    required this.userType,
    required this.token,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  UserModel copyWith({
    String? username,
    String? firstname,
    String? lastname,
    String? userUniqueNumber,
    bool? isDemoAccount,
    String? tonInventory,
    String? starsInventory,
    String? usdtInventory,
    String? btcInventory,
    String? cusdInventory,
    String? userProfile,
    String? totalWagered,
    String? totalBets,
    String? totalWins,
    int? levelId,
    LevelModel? level,
    String? experience,
    UserType? userType,
    String? token,
  }) {
    return UserModel(
      id: id,
      invitationCode: invitationCode,
      username: username,
      firstname: firstname,
      lastname: lastname,
      userUniqueNumber: userUniqueNumber ?? this.userUniqueNumber,
      isDemoAccount: isDemoAccount ?? this.isDemoAccount,
      tonInventory: tonInventory ?? this.tonInventory,
      starsInventory: starsInventory ?? this.starsInventory,
      usdtInventory: usdtInventory ?? this.usdtInventory,
      btcInventory: btcInventory ?? this.btcInventory,
      cusdInventory: cusdInventory ?? this.cusdInventory,
      userProfile: userProfile ?? this.userProfile,
      totalWagered: totalWagered ?? this.totalWagered,
      totalBets: totalBets ?? this.totalBets,
      totalWins: totalWins ?? this.totalWins,
      levelId: levelId ?? this.levelId,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      userType: userType ?? this.userType,
      token: token,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  factory UserModel.fromMap({required Map<String, dynamic> mapData}) {
    return mapData['id'].toString().convertToNum.toInt() < 1
        ? empty
        : UserModel(
            id: mapData['id'].toString().convertToNum.toInt(),
            invitationCode: mapData['invitation_code'],
            username: mapData['username']['String'],
            firstname: mapData['firstname']['String'],
            lastname: mapData['lastname']['String'],
            userUniqueNumber: mapData['user_unique_number'].toString(),
            isDemoAccount: mapData['is_demo_account']
                .toString()
                .convertToNum
                .convertToBool,
            tonInventory: mapData['ton_inventory'].toString(),
            starsInventory: mapData['stars_inventory'].toString(),
            usdtInventory: mapData['usdt_inventory'].toString(),
            btcInventory: mapData['btc_inventory'].toString(),
            cusdInventory: mapData['cusd_inventory'].toString(),
            userProfile: mapData['user_profile']['String'],
            totalWagered: mapData['total_wagered'].toString(),
            totalBets: mapData['total_bets'].toString(),
            totalWins: mapData['total_wins'].toString(),
            levelId: mapData['level_id'].toString().convertToNum.toInt(),
            level: LevelModel.fromMap(mapData: mapData['level']),
            experience: mapData['experience'],
            userType: const UserRepositoryFunctions()
                .convertStringToUserType(userType: mapData['user_type']),
            token: mapData['token']['String'],
            createdAt: DateTime.parse(mapData['created_at']),
            updatedAt: DateTime.parse(mapData['updated_at']),
          );
  }
  @override
  factory UserModel.fromJson({required String jsonData}) =>
      UserModel.fromMap(mapData: jsonDecode(jsonData));
  @override
  String get toJson => jsonEncode(toMap);

  @override
  Map<String, dynamic> get toMap => {
        'id': '$id',
        'invitation_code': invitationCode,
        'username': {'String': username},
        'firstname': {'String': firstname},
        'lastname': {'String': lastname},
        'user_unique_number': userUniqueNumber,
        'ton_inventory': tonInventory,
        'stars_inventory': starsInventory,
        'is_demo_account': '${isDemoAccount.convertBooleanToInteger}',
        'usdt_inventory': usdtInventory,
        'btc_inventory': btcInventory,
        'cusd_inventory': cusdInventory,
        'user_profile': {'String': userProfile},
        'total_wagered': totalWagered,
        'total_bets': totalBets,
        'total_wins': totalWins,
        'level_id': '$levelId',
        'level': level.toMap,
        'experience': experience,
        'user_type': userType.name,
        'token': {'String': token},
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
  static List<UserModel> getListOfUsersByJson({required String jsonData}) {
    final List<UserModel> users = [];
    if (jsonData.isValidJson) {
      final List<dynamic> listOfMaps = jsonDecode(jsonData);
      for (final Map<String, dynamic> mapData in listOfMaps) {
        users.add(UserModel.fromMap(mapData: mapData));
      }
    }
    return users;
  }

  static UserModel empty = UserModel(
    id: -1,
    invitationCode: 'invitationCode',
    username: 'Username Not Found',
    firstname: 'firstname',
    lastname: 'lastname',
    userUniqueNumber: 'userUniqueNumber',
    tonInventory: 'tonInventory',
    starsInventory: 'starsInventory',
    isDemoAccount: true,
    usdtInventory: 'usdtInventory',
    cusdInventory: 'cusdInventory',
    btcInventory: 'btcInventory',
    userProfile: 'userProfile',
    totalWagered: 'totalWagered',
    totalBets: 'totalBets',
    totalWins: 'totalWins',
    levelId: -1,
    level: LevelModel(
      id: -1,
      levelTag: 'levelTag',
      expToUpgrade: 'expToUpgrade',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    experience: 'experience',
    userType: UserType.normal,
    token: 'invalid token',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
