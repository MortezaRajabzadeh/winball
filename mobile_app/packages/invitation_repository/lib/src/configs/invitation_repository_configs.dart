import 'package:base_repository/base_repository.dart';

abstract class InvitationRepositoryConfigs {
  static const String createInvitation =
      '${BaseConfigs.baseUrl}/create-invitation';
  static const String getInvitationByInvitorId =
      '${BaseConfigs.baseUrl}/get-invitation-by-invitor-id';
  static const String getInvitedUsersCount =
      '${BaseConfigs.baseUrl}/get-invited-users-count';
  static const String getFirstInvitationUsers =
      '${BaseConfigs.baseUrl}/get-first-invitation-users';
  static const String getSecondInvitationUsers =
      '${BaseConfigs.baseUrl}/get-second-invitation-users';
  static const String getThirdInvitationUsers =
      '${BaseConfigs.baseUrl}/get-third-invitation-users';
}
