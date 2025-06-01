import 'package:base_repository/base_repository.dart';
import 'package:help_repository/src/configs/help_repository_configs.dart';
import 'package:help_repository/src/models/help_model.dart';
import 'package:network_repository/network_repository.dart';

typedef Helps = List<HelpModel>;

class HelpRepositoryFunctions {
  const HelpRepositoryFunctions();
  Future<HelpModel> createHelp({
    required String title,
    required String subsection,
    required String description,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: HelpRepositoryConfigs.createHelp,
        mapData: {
          'title': title,
          'subsection': subsection,
          'description': description,
        },
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return HelpModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<HelpModel> editHelp({
    required String title,
    required String subsection,
    required String description,
    required int helpId,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: HelpRepositoryConfigs.editHelp,
        mapData: {
          'title': title,
          'help_id': '$helpId',
          'subsection': subsection,
          'description': description,
        },
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return HelpModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<Helps> getHelps({
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: HelpRepositoryConfigs.getHelps,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return HelpModel.getListOfHelpsByJsonData(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteHelpWithId({
    required int helpId,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${HelpRepositoryConfigs.deleteHelpWithId}?help_id=$helpId',
        token: token,
      );
      return response.statusCode.isRequestValid;
    } catch (e) {
      rethrow;
    }
  }
}
