import 'package:base_repository/base_repository.dart';

abstract class ActivityRepostiroyConfigs {
  static const String createActivity = '${BaseConfigs.baseUrl}/create-activity';
  static const String editActivity = '${BaseConfigs.baseUrl}/edit-activity';
  static const String deleteActivityById =
      '${BaseConfigs.baseUrl}/delete-activity-by-id';
  static const String getActivities = '${BaseConfigs.baseUrl}/get-activities';
}
