import 'package:activity_repository/src/configs/activity_repostiroy_configs.dart';
import 'package:activity_repository/src/models/activity_model.dart';
import 'package:base_repository/base_repository.dart';
import 'package:network_repository/network_repository.dart';
import 'package:http/http.dart' as http;

typedef Activities = List<ActivityModel>;

class ActivityRepositoryFunctions {
  const ActivityRepositoryFunctions();
  Future<ActivityModel> createActivity({
    required String title,
    required String bannerUrl,
    required String details,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: ActivityRepostiroyConfigs.createActivity,
        mapData: {
          'title': title,
          'details': details,
          'banner_url': bannerUrl,
        },
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return ActivityModel.fromJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ActivityModel> editActivity({
    required String title,
    required String details,
    required String bannerUrl,
    required int activityId,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: ActivityRepostiroyConfigs.editActivity,
        mapData: {
          'title': title,
          'details': details,
          'banner_url': bannerUrl,
          'activity_id': '$activityId',
        },
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return ActivityModel.fromJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteActivityById({
    required int activityId,
    required String token,
  }) async {
    try {
      final http.Response response =
          await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${ActivityRepostiroyConfigs.deleteActivityById}?activity_id=$activityId',
        token: token,
      );
      return response.statusCode.isRequestValid;
    } catch (e) {
      rethrow;
    }
  }

  Future<Activities> getActivities({
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: ActivityRepostiroyConfigs.getActivities,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return ActivityModel.getActivitiesByJsonData(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }
}
