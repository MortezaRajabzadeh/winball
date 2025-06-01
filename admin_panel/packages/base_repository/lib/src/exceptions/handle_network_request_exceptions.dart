import 'package:base_repository/base_repository.dart';
import 'package:http/http.dart' as http;

abstract class HandleNetworkRequestExceptions {
  static http.Response handleNetworkRequestExceptions(
      {required http.Response response}) {
    if (response.statusCode.isRequestValid) {
      return response;
    } else {
      throw BaseExceptions(error: response.body, code: response.statusCode);
    }
  }
}
