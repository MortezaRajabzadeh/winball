import 'dart:convert';

import 'package:http/http.dart' as http;
import '../extensions/network_extensions.dart';

class NetworkRepositoryFunctions {
  const NetworkRepositoryFunctions();
  Future<dynamic> sendPostRequest({
    required String endpointUrl,
    required Map<String, dynamic> mapData,
    String? token,
  }) async {
    try {
      return (() => http.post(
            Uri.parse(endpointUrl),
            body: jsonEncode(mapData),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null) 'Authorization': token,
            },
          )).withRetries();
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> sendGetRequest({
    required String endpointUrl,
    String? token,
  }) async {
    try {
      return (() => http.get(
            Uri.parse(endpointUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token != null) 'Authorization': token,
            },
          )).withRetries();
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> sendGetRequestToCoinMarketCap({
    required String endpointUrl,
    required String apiKey,
  }) async {
    try {
      return (() => http.get(
            Uri.parse(endpointUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-CMC_PRO_API_KEY': apiKey,
            },
          )).withRetries();
    } catch (e) {
      rethrow;
    }
  }
}
