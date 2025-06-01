import 'package:base_repository/base_repository.dart';
import 'package:network_repository/network_repository.dart';
import 'package:support_repository/src/configs/support_repository_configs.dart';
import 'package:support_repository/src/enums/support_enums.dart';
import 'package:support_repository/src/models/support_model.dart';

typedef Supports = List<SupportModel>;

class SupportRepositoryFunctions {
  const SupportRepositoryFunctions();
  MessageType convertStringToMessageType({required String messageType}) =>
      MessageType.values.firstWhere((e) => e.name == messageType);
  Future<Supports> getSupportsByRoomId({
    required String roomId,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${SupportRepositoryConfigs.getSupportsByRoomId}?room_id=$roomId',
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return SupportModel.getListOfSupportsByJsonData(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Supports> getSupportByUserId({
    required int userId,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: SupportRepositoryConfigs.getSupportByUserId,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return SupportModel.getListOfSupportsByJsonData(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<SupportModel> createSupportMessage({
    required String messageValue,
    required MessageType messageType,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: SupportRepositoryConfigs.createSupportMessage,
        mapData: {
          'message_value': messageValue,
          'message_type': messageType.name,
        },
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return SupportModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }
}
