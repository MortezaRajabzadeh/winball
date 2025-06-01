import 'package:base_repository/base_repository.dart';

abstract class UserRepositoryConfigs {
  static const String registerEntry = '${BaseConfigs.baseUrl}/register-entry';
  static const String getUserTeam = '${BaseConfigs.baseUrl}/get-user-team';
  static const String updateUser = '${BaseConfigs.baseUrl}/update-user';
  static const String loginEntry = '${BaseConfigs.baseUrl}/login-entry';
  static const String getUserWithUniqueIdentifier =
      '${BaseConfigs.baseUrl}/get-user-with-unique-identifier';
  static const String getTeamReportModel =
      '${BaseConfigs.baseUrl}/get-team-report-model';
  static const String changeUserTonAmount =
      '${BaseConfigs.baseUrl}/change-user-ton-amount';
  static const String changeUserStarsAmount =
      '${BaseConfigs.baseUrl}/change-user-stars-amount';
  static const String changeUserType =
      '${BaseConfigs.baseUrl}/change-user-type';
  static const String changeUserDemoAccount =
      '${BaseConfigs.baseUrl}/change-user-demo-account';
  static const String getAllUsersPerPage =
      '${BaseConfigs.baseUrl}/get-all-users-per-page';
  static const String getUserWithUsername =
      '${BaseConfigs.baseUrl}/get-user-with-username';
}
