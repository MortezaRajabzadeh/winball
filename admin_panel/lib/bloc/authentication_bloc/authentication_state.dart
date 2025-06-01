part of './authentication_bloc.dart';

abstract class AuthenticationState {
  final UserModel? currentUser;
  const AuthenticationState({
    this.currentUser,
  });
  AuthenticationState copyWith({UserModel? currentUser});
}

class InitializedAuthenticationState extends AuthenticationState {
  const InitializedAuthenticationState({super.currentUser});

  @override
  InitializedAuthenticationState copyWith({UserModel? currentUser}) {
    return InitializedAuthenticationState(currentUser: currentUser);
  }
}
