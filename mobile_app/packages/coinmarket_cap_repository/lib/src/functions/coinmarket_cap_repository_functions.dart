import 'package:base_repository/base_repository.dart';
import 'package:coinmarket_cap_repository/src/configs/configs.dart';
import 'package:coinmarket_cap_repository/src/models/coin_model.dart';
import 'package:network_repository/network_repository.dart';

typedef Coins = List<CoinModel>;

class CoinmarketCapRepositoryFunctions {
  const CoinmarketCapRepositoryFunctions();
  Future<Coins> getListOfCoins() async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: CoinmarketCapConfigs.coinmarketCapEndpoint,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return CoinModel.getListOfCoinModelsByJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }
}
