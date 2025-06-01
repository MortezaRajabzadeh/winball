import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:winball_admin_panel/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:winball_admin_panel/screens/screens.dart';

class AuthenticationControllerScreen extends StatelessWidget {
  const AuthenticationControllerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        return state.currentUser == null
            ? const LoginRegisterEntry()
            : const HomeScreen();
      },
    );
  }
}
