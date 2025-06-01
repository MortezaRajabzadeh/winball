import 'package:base_repository/base_repository.dart';

abstract class HelpRepositoryConfigs {
  static const String createHelp = '${BaseConfigs.baseUrl}/create-help';
  static const String editHelp = '${BaseConfigs.baseUrl}/edit-help';
  static const String getHelps = '${BaseConfigs.baseUrl}/get-helps';
  static const String deleteHelpWithId =
      '${BaseConfigs.baseUrl}/delete-help-with-id';
}
