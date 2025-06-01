part of './authentication_bloc.dart';

abstract class AuthenticationEvent {
  const AuthenticationEvent();
}

class LoginEvent extends AuthenticationEvent {
  final String username;
  final String password;
  final String userUniqueNumber;
  final void Function() onLoginPassed;
  const LoginEvent({
    required this.username,
    required this.password,
    required this.userUniqueNumber,
    required this.onLoginPassed,
  });
}
