import 'package:base_repository/base_repository.dart';

abstract class InvitationRepositoryConfigs {
  static const String createInvitation =
      '${BaseConfigs.baseUrl}/create-invitation';
  static const String getInvitationByInvitorId =
      '${BaseConfigs.baseUrl}/get-invitation-by-invitor-id';
}
