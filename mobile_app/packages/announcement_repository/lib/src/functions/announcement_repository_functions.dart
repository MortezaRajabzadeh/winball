import 'package:announcement_repository/src/configs/announcements_configs.dart';
import 'package:announcement_repository/src/models/announcement_model.dart';
import 'package:base_repository/base_repository.dart';
import 'package:network_repository/network_repository.dart';
import 'package:http/http.dart' as http;

typedef Announcements = List<AnnouncementModel>;

class AnnouncementRepositoryFunctions {
  const AnnouncementRepositoryFunctions();
  Future<AnnouncementModel> createAnnouncement({
    required String title,
    required String details,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: AnnouncementsConfigs.createAnnouncement,
        mapData: {
          'title': title,
          'details': details,
        },
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return AnnouncementModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<AnnouncementModel> editAnnouncementt({
    required int announcementId,
    required String title,
    required String details,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: AnnouncementsConfigs.editAnnouncementt,
        mapData: {
          'announce_id': '$announcementId',
          'title': title,
          'details': details,
        },
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return AnnouncementModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteAnnouncementById({
    required int announceId,
    required String token,
  }) async {
    try {
      final http.Response response =
          await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${AnnouncementsConfigs.deleteAnnouncementById}?announcement_id=$announceId',
        token: token,
      );
      return response.statusCode.isRequestValid;
    } catch (e) {
      rethrow;
    }
  }

  Future<Announcements> getAnnouncements({
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: AnnouncementsConfigs.getAnnouncements,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return AnnouncementModel.getListOfAnnouncementsByJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }
}
