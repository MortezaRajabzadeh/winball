import 'package:base_repository/base_repository.dart';

class BaseRepositoryFunctions {
  const BaseRepositoryFunctions();
  CoinType convertStringToCoinType({required String coinType}) =>
      CoinType.values.firstWhere((e) => e.name == coinType);
}
