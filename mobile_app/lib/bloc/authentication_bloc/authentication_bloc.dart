import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:site_settings_repository/site_settings_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball/bloc/app_bloc/app_bloc.dart';
import 'package:winball/configs/app_texts.dart';
part './authentication_event.dart';
part './authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  late final UserRepositoryFunctions userRepositoryFunctions;
  // late final DatabaseRepositoryFunctions databaseRepositoryFunctions;
  late final SiteSettingRepositoryFunctions siteSettingRepositoryFunctions;
  final AppBloc appBloc;
  AuthenticationBloc({
    required this.appBloc,
  }) : super(const InitializedAuthenticationState()) {
    on<LoginEvent>(_onLoginEvent);
    on<RegisterEvent>(_onRegisterEvent);
    // on<InitializeAuthenticationEvent>(_onInitializeAuthenticationEvent);
    on<GetUserWithUniqueNumberEvent>(_onGetUserWithUniqueNumberEvent);
    userRepositoryFunctions = const UserRepositoryFunctions();
    // databaseRepositoryFunctions = const DatabaseRepositoryFunctions();
    siteSettingRepositoryFunctions = const SiteSettingRepositoryFunctions();
  }
  Future<void> _onGetUserWithUniqueNumberEvent(
    GetUserWithUniqueNumberEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      appBloc.showLoadingDialog();
      await Future.delayed(const Duration(seconds: 1));
      final UserModel userModel =
          await userRepositoryFunctions.getUserWithUniqueIdentifier(
        userUniqueIdentifier: event.userUniqueNumber,
      );
      appBloc.closeDialog();
      if (userModel.id == 0) {
        appBloc.addError(
          AppTexts.youMustRegister,
        );
      } else {
        // ذخیره توکن در AppBloc و مدل کاربر
        emit(state.copyWith(currentUser: userModel));
        appBloc.add(
          LoginRegisterEvent(
            currentUser: userModel,
          ),
        );
      }
    } catch (e) {
      appBloc.closeDialog();
      appBloc.addError(e);
    }
  }

  // Future<void> _onInitializeAuthenticationEvent(
  //     InitializeAuthenticationEvent event,
  //     Emitter<AuthenticationState> emit) async {
  //   try {
  // final String? userJson = await databaseRepositoryFunctions.getUserFromDb;
  //     if (userJson != null) {
  //       appBloc.showLoadingDialog();
  //       final UserModel currentUser = UserModel.fromJson(jsonData: userJson);
  //       emit(state.copyWith(currentUser: currentUser));
  //       appBloc.add(
  //         LoginRegisterEvent(
  //           currentUser: currentUser,
  //         ),
  //       );
  //       appBloc.closeDialog();
  //     }
  //   } catch (e) {
  //     appBloc.addError(e);
  //   }
  // }

  Future<void> _onRegisterEvent(
      RegisterEvent event, Emitter<AuthenticationState> emit) async {
    try {
      appBloc.showLoadingDialog();
      final UserModel userModel = await userRepositoryFunctions.registerEntry(
        firstname: event.firstname,
        password: event.password,
        lastname: event.lastname,
        userIdentifier: event.userIdentifier,
        username: event.username,
        invitationCode:
            (event.invitationCode ?? '').isEmpty ? null : event.invitationCode,
      );

      appBloc.add(
        LoginRegisterEvent(
          currentUser: userModel,
        ),
      );
      emit(state.copyWith(currentUser: userModel));
      // databaseRepositoryFunctions.saveUsersToDb(userJson: userModel.toJson);
      appBloc.closeDialog();
      event.onLoginPassed();
    } catch (e) {
      event.onLoginPassed();
      appBloc.addError(e);
    }
  }

  Future<void> _onLoginEvent(
      LoginEvent event, Emitter<AuthenticationState> emit) async {
    try {
      final UserModel userModel = await userRepositoryFunctions.loginEntry(
        username: event.username,
        password: event.password,
      );
      event.onLoginPassed();
      emit(state.copyWith(currentUser: userModel));
      appBloc.add(LoginRegisterEvent(
        currentUser: userModel,
      ));
      // databaseRepositoryFunctions.saveUsersToDb(userJson: userModel.toJson);
    } catch (e) {
      event.onLoginPassed();
      appBloc.addError(e);
    }
  }
}
