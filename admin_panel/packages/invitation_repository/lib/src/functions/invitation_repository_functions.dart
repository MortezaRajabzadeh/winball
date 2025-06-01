import 'package:base_repository/base_repository.dart';
import 'package:invitation_repository/src/configs/invitation_repository_configs.dart';
import 'package:invitation_repository/src/models/invitation_model.dart';
import 'package:network_repository/network_repository.dart';

typedef Invitations = List<InvitationModel>;

class InvitationRepositoryFunctions {
  const InvitationRepositoryFunctions();
  Future<InvitationModel> createInvitation({
    required int invitorId,
    required int invitedId,
    required String invitationCode,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: InvitationRepositoryConfigs.createInvitation,
        mapData: {
          'invitor_id': '$invitorId',
          'invited_id': '$invitedId',
          'invitation_code': invitationCode,
        },
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return InvitationModel.fromJson(jsonData: response.body);
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
}
