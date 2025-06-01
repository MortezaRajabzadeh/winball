import 'package:site_settings_repository/src/configs/site_settings_repository_configs.dart';
import 'package:site_settings_repository/src/models/site_setting_model.dart';
import 'package:base_repository/base_repository.dart';
import 'package:network_repository/network_repository.dart';

typedef SiteSettings = List<SiteSettingModel>;

class SiteSettingRepositoryFunctions {
  const SiteSettingRepositoryFunctions();
  Future<SiteSettingModel> createSiteSetting({
    required String loadingPicture,
    required String minWithdrawAmount,
    required String minDepositAmount,
    required int referalPercent,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: SiteSettingsRepositoryConfigs.createSiteSetting,
        mapData: {
          'loading_picture': loadingPicture,
          'min_withdraw_amount': minWithdrawAmount,
          'min_deposit_amount': minDepositAmount,
          'referal_percent': '$referalPercent'
        },
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return SiteSettingModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<SiteSettings> getSiteSettings() async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: SiteSettingsRepositoryConfigs.getSiteSettings,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
          response: response);
      return SiteSettingModel.getListOfSiteSettingByJson(
          jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }
}
