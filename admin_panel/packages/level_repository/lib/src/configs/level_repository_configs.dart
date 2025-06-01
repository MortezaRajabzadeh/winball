import 'package:base_repository/base_repository.dart';

abstract class LevelRepositoryConfigs {
  static const String createLevel = '${BaseConfigs.baseUrl}/create-level';
  static const String editLevel = '${BaseConfigs.baseUrl}/edit-level';
  static const String deleteLevelById =
      '${BaseConfigs.baseUrl}/delete-level-by-id';
  static const String getLevels = '${BaseConfigs.baseUrl}/get-levels';
}
