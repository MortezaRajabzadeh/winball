import 'package:base_repository/base_repository.dart';

abstract class AnnouncementsConfigs {
  static const String createAnnouncement =
      '${BaseConfigs.baseUrl}/craete-announcement';
  static const String editAnnouncementt =
      '${BaseConfigs.baseUrl}/edit-announcement';
  static const String deleteAnnouncementById =
      '${BaseConfigs.baseUrl}/delete-announcement-by-id';
  static const String getAnnouncements =
      '${BaseConfigs.baseUrl}/get-announcements';
}
