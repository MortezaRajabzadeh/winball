part of './authentication_bloc.dart';

abstract class AuthenticationEvent {
  const AuthenticationEvent();
}

class LoginEvent extends AuthenticationEvent {
  final String username;
  final String password;
  final void Function() onLoginPassed;
  const LoginEvent({
    required this.username,
    required this.password,
    required this.onLoginPassed,
  });
}

class RegisterEvent extends AuthenticationEvent {
  final String firstname, lastname, password, userIdentifier, username;
  final String? invitationCode;
  final void Function() onLoginPassed;
  const RegisterEvent({
    this.invitationCode,
    required this.firstname,
    required this.lastname,
    required this.password,
    required this.userIdentifier,
    required this.username,
    required this.onLoginPassed,
  });
}

// class InitializeAuthenticationEvent extends AuthenticationEvent {
//   const InitializeAuthenticationEvent();
// }

class GetUserWithUniqueNumberEvent extends AuthenticationEvent {
  final String userUniqueNumber;
  const GetUserWithUniqueNumberEvent({
    required this.userUniqueNumber,
  });
}
