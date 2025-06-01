import 'dart:typed_data';

import 'package:file_repository/exceptions/file_repository_exceptions.dart';
import 'package:file_repository/src/configs/file_repository_configs.dart';
import 'package:network_repository/network_repository.dart';

class FileRepositoryFunctions {
  const FileRepositoryFunctions();
  Future<String> uploadFile({
    required String fileType,
    required Uint8List bytes,
    required String fileExtension,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: FileRepositoryConfigs.uploadFile,
        mapData: {
          'file': bytes,
          'file_extension': Uint8List.fromList(fileExtension.codeUnits),
          'file_type': Uint8List.fromList(fileType.codeUnits),
        },
        token: token,
      );
      FileRepositoryExceptions.handleFileRepositoryExceptions(
          response: response);
      return response.body;
    } catch (e) {
      rethrow;
    }
  }
}
