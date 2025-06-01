import 'package:base_repository/base_repository.dart';
import 'package:level_repository/src/configs/level_repository_configs.dart';
import 'package:level_repository/src/models/level_model.dart';
import 'package:network_repository/network_repository.dart';

typedef Levels = List<LevelModel>;

class LevelRepositoryFunctions {
  const LevelRepositoryFunctions();
  Future<LevelModel> createLevel({
    required String levelTag,
    required String expToUpgrade,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: LevelRepositoryConfigs.createLevel,
        mapData: {
          'level_tag': levelTag,
          'exp_to_upgrade': expToUpgrade,
        },
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return LevelModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<LevelModel> editLevel({
    required int levelId,
    required String levelTag,
    required String expToUpgrade,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: LevelRepositoryConfigs.editLevel,
        mapData: {
          'level_tag': levelTag,
          'exp_to_upgrade': expToUpgrade,
          'level_id': '$levelId',
        },
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return LevelModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteLevelById({
    required int levelId,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${LevelRepositoryConfigs.deleteLevelById}?level_id=$levelId',
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return response.statusCode.isRequestValid;
    } catch (e) {
      rethrow;
    }
  }

  Future<Levels> getLevels({
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: LevelRepositoryConfigs.getLevels,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return LevelModel.getLevelsByListOfJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }
}
