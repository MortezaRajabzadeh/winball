import 'package:base_repository/base_repository.dart';
import 'package:invitation_repository/src/configs/invitation_repository_configs.dart';
import 'package:invitation_repository/src/models/invitation_model.dart';
import 'package:network_repository/network_repository.dart';

typedef Invitations = List<InvitationModel>;

class InvitationRepositoryFunctions {
  const InvitationRepositoryFunctions();
  Future<void> createInvitation({
    required int invitedId,
    required String invitationCode,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: InvitationRepositoryConfigs.createInvitation,
        mapData: {
          'invited_id': '$invitedId',
          'invitation_code': invitationCode,
        },
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Invitations> getInvitationByInvitorId({
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: InvitationRepositoryConfigs.getInvitationByInvitorId,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
          response: response);
      return InvitationModel.getListOfInvitationByJsonData(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getInvitedUsersCount({required String token}) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: InvitationRepositoryConfigs.getInvitedUsersCount,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return response.body.toString().convertToNum.toInt();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getFirstInvitationUsers({required String token}) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: InvitationRepositoryConfigs.getFirstInvitationUsers,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
          response: response);
      return response.body.toString().convertToNum.toInt();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getSecondInvitationUsers({required String token}) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: InvitationRepositoryConfigs.getSecondInvitationUsers,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
          response: response);
      return response.body.toString().convertToNum.toInt();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getThirdInvitationUsers({required String token}) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: InvitationRepositoryConfigs.getThirdInvitationUsers,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
          response: response);
      return response.body.toString().convertToNum.toInt();
    } catch (e) {
      rethrow;
    }
  }
}
