import 'dart:convert';

import 'package:base_repository/base_repository.dart';

class CoinModel {
  final int id;
  final String symbol;
  final String percentChagne24H;
  final String numMarketPais;
  final String volumeChanged24Hours;
  const CoinModel({
    required this.id,
    required this.symbol,
    required this.percentChagne24H,
    required this.numMarketPais,
    required this.volumeChanged24Hours,
  });
  factory CoinModel.fromJson({required String jsonData}) =>
      CoinModel.fromMap(mapData: jsonDecode(jsonData));
  factory CoinModel.fromMap({required Map<String, dynamic> mapData}) {
    return CoinModel(
        id: mapData['id'].toString().convertToNum.toInt(),
        symbol: mapData['symbol'],
        percentChagne24H:
            mapData['quote']['USD']['percent_change_24h'].toString(),
        numMarketPais: mapData['num_market_pairs'].toString(),
        volumeChanged24Hours:
            mapData['quote']['USD']['volume_change_24h'].toString());
  }
  static List<CoinModel> getListOfCoinModelsByJson({required String jsonData}) {
    final List<CoinModel> coins = [];
    if (jsonData.isValidJson) {
      final Map<String, dynamic> datas = jsonDecode(jsonData);
      final List<dynamic> listOfMaps = datas['data'];
      for (final Map<String, dynamic> mapData in listOfMaps) {
        coins.add(CoinModel.fromMap(mapData: mapData));
      }
    }
    return coins;
  }
}
