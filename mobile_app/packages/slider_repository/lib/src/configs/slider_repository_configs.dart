import 'package:base_repository/base_repository.dart';

abstract class SliderRepositoryConfigs {
  static const String createSlider = '${BaseConfigs.baseUrl}/create-slider';
  static const String getSlider = '${BaseConfigs.baseUrl}/get-slider';
  static const String deleteSlider = '${BaseConfigs.baseUrl}/delete-slider';
}
