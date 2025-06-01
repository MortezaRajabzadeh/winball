import 'package:base_repository/base_repository.dart';
import 'package:http/http.dart' as http;

class FileRepositoryExceptions {
  static http.Response handleFileRepositoryExceptions(
      {required http.Response response}) {
    if (response.statusCode.isRequestValid) {
      return response;
    } else {
      throw FileRepositoryException(
          error: response.body, code: response.statusCode);
    }
  }
}

class FileRepositoryException extends BaseExceptions {
  const FileRepositoryException({
    required super.error,
    super.code,
  });
}
