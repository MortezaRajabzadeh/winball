import 'package:base_repository/base_repository.dart';
import 'package:network_repository/network_repository.dart';
import 'package:slider_repository/src/configs/slider_repository_configs.dart';
import 'package:slider_repository/src/models/slider_model.dart';
import 'package:http/http.dart' as http;

typedef Slider = List<SliderModel>;

class SliderRepositoryFunctions {
  const SliderRepositoryFunctions();
  Future<SliderModel> createSlider({
    required String imagePath,
    String? buttonTitle,
    String? buttonLink,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: SliderRepositoryConfigs.createSlider,
        mapData: {
          'image_path': imagePath,
          'button_title': buttonTitle,
          'button_link': buttonLink,
        },
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return SliderModel.fromJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Slider> getSlider({
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: SliderRepositoryConfigs.getSlider,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return SliderModel.getListOfSliderByJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteSlider({
    required int sliderId,
    required String token,
  }) async {
    try {
      final http.Response response = await const NetworkRepositoryFunctions()
          .sendGetRequest(
              endpointUrl:
                  '${SliderRepositoryConfigs.deleteSlider}?slider_id=$sliderId',
              token: token);

      return response.statusCode.isRequestValid;
    } catch (e) {
      rethrow;
    }
  }
}
