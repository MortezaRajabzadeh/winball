import 'package:base_repository/base_repository.dart';

abstract class SiteSettingsRepositoryConfigs {
  static const String createSiteSetting =
      '${BaseConfigs.baseUrl}/create-site-setting';
  static const String getSiteSettings =
      '${BaseConfigs.baseUrl}/get-site-settings';
}
