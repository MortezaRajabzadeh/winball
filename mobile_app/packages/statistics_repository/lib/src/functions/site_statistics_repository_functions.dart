import 'package:base_repository/base_repository.dart';
import 'package:network_repository/network_repository.dart';
import '../configs/statistics_confings.dart';
import '../models/statistics_model.dart';

class SiteStatisticsRepositoryFunctions {
  const SiteStatisticsRepositoryFunctions();
  Future<StatisticsModel> getSiteStatistics({
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
          endpointUrl: StatisticsConfings.getStatisticsModel, token: token);
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
          response: response);
      return StatisticsModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }
}
