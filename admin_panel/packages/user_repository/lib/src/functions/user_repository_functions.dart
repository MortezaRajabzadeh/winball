import 'package:base_repository/base_repository.dart';
import 'package:network_repository/network_repository.dart';
import 'package:user_repository/src/configs/user_repository_configs.dart';
import 'package:user_repository/src/enums/user_repository_enums.dart';
import 'package:user_repository/src/models/team_report_model.dart';
import 'package:user_repository/src/models/user_model.dart';
import 'package:http/http.dart' as http;

typedef Users = List<UserModel>;

class UserRepositoryFunctions {
  const UserRepositoryFunctions();
  UserType convertStringToUserType({required String userType}) =>
      UserType.values.firstWhere(
        (e) => e.name == userType,
      );
  Future<UserModel> registerEntry({
    required String firstname,
    required String lastname,
    required String userIdentifier,
    required String username,
    required String password,
    String? invitationCode,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendPostRequest(
        endpointUrl: UserRepositoryConfigs.registerEntry,
        mapData: {
          'firstname': firstname,
          'lastname': lastname,
          'user_identifier': userIdentifier,
          'username': username,
          'password': password,
          if (invitationCode != null) 'invitation_code': invitationCode,
        },
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return UserModel.fromJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Users> getTeamByUserId({
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: UserRepositoryConfigs.getUserTeam,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return UserModel.getListOfUsersByJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> updateUser({
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: UserRepositoryConfigs.updateUser,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
          response: response);
      return UserModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> loginEntry({
    required String username,
    required String password,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${UserRepositoryConfigs.loginEntry}?username=$username&password=$password',
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return UserModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUserWithUniqueIdentifier({
    required String userUniqueIdentifier,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${UserRepositoryConfigs.getUserWithUniqueIdentifier}?unique_identifier=$userUniqueIdentifier',
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return UserModel.fromJson(jsonData: response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<TeamReportModel> getTeamReportModel({
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: UserRepositoryConfigs.getTeamReportModel,
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return TeamReportModel.fromJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changeUserTonAmount({
    required double tonAmount,
    required int userId,
    required String token,
  }) async {
    try {
      final http.Response response =
          await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${UserRepositoryConfigs.changeUserTonAmount}?amount=$tonAmount&user_id=$userId',
        token: token,
      );
      return response.statusCode.isRequestValid;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changeUserStarsAmount({
    required int amount,
    required int userId,
    required String token,
  }) async {
    try {
      final http.Response response =
          await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${UserRepositoryConfigs.changeUserStarsAmount}?amount=$amount&user_id=$userId',
        token: token,
      );
      return response.statusCode.isRequestValid;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changeUserType({
    required String userType,
    required int userId,
    required String token,
  }) async {
    try {
      final http.Response response =
          await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${UserRepositoryConfigs.changeUserType}?user_type=$userType&user_id=$userId',
        token: token,
      );
      return response.statusCode.isRequestValid;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changeUserDemoAccount({
    required int userId,
    required int isDemo,
    required String token,
  }) async {
    try {
      final http.Response response =
          await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${UserRepositoryConfigs.changeUserDemoAccount}?user_id=$userId&is_demo=$isDemo',
        token: token,
      );
      return response.statusCode.isRequestValid;
    } catch (e) {
      rethrow;
    }
  }

  Future<Users> getAllUsersPerPage({
    required int page,
    required String token,
  }) async {
    try {
      final response = await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: '${UserRepositoryConfigs.getAllUsersPerPage}?page=$page',
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return UserModel.getListOfUsersByJson(
        jsonData: response.body,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUserWithUsername({
    required String username,
    required String token,
  }) async {
    try {
      final http.Response response =
          await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl:
            '${UserRepositoryConfigs.getUserWithUsername}?username=$username',
        token: token,
      );
      HandleNetworkRequestExceptions.handleNetworkRequestExceptions(
        response: response,
      );
      return UserModel.fromJson(
        jsonData: response.body,
      );
    } catch (_) {
      rethrow;
    }
  }
}
