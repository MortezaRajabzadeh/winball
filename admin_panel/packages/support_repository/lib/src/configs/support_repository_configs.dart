import 'package:base_repository/base_repository.dart';

abstract class SupportRepositoryConfigs {
  static const String getSupportsByRoomId =
      '${BaseConfigs.baseUrl}/get-supports-by-room-id';
  static const String getSupportByUserId =
      '${BaseConfigs.baseUrl}/get-support-by-user-id';
  static const String createSupportMessage =
      '${BaseConfigs.baseUrl}/create-support-message';
}
