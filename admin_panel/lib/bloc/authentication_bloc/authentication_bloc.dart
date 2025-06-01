import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball_admin_panel/bloc/app_bloc/app_bloc.dart';
import 'package:winball_admin_panel/configs/configs.dart';
part './authentication_event.dart';
part './authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  late final UserRepositoryFunctions userRepositoryFunctions;
  final AppBloc appBloc;
  AuthenticationBloc({
    required this.appBloc,
  }) : super(const InitializedAuthenticationState()) {
    on<LoginEvent>(_onLoginEvent);
    userRepositoryFunctions = const UserRepositoryFunctions();
  }
  Future<void> _onLoginEvent(
      LoginEvent event, Emitter<AuthenticationState> emit) async {
    try {
      final UserModel userModel = await userRepositoryFunctions.loginEntry(
        username: event.username,
        password: event.password,
      );
      event.onLoginPassed();
      if (userModel.userType != UserType.normal) {
        appBloc.add(ChangeCurrentUserEvent(userModel: userModel));
        emit(state.copyWith(currentUser: userModel));
      } else {
        appBloc.addError(AppTexts.accessDenied);
      }
    } catch (e) {
      event.onLoginPassed();
      appBloc.addError(e);
    }
  }
}
