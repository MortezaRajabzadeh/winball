import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:winball/bloc/app_bloc/app_bloc.dart';
import 'package:winball/bloc/authentication_bloc/authentication_bloc.dart';

extension BuildContextExtensions on BuildContext {
  AppBloc get readAppBloc => read<AppBloc>();
  AppBloc get watchAppBloc => watch<AppBloc>();
  AuthenticationBloc get readAuthBloc => read<AuthenticationBloc>();
  AuthenticationBloc get watchAuthBloc => watch<AuthenticationBloc>();
  Size get getSize => MediaQuery.of(this).size;
  bool get isMobile => getSize.width <= 800.0;
  bool get isTablet => getSize.width > 800.0 && getSize.width <= 1200;
  bool get isDesktop => getSize.width > 1200.0;
  Future<dynamic> tonamed({required String name, dynamic arguments}) =>
      Navigator.of(this).pushNamed(
        name,
      );
  Future<dynamic> to({required Widget child}) => Navigator.of(this).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (context, animation1, _) {
            const Offset firstOffset = Offset(-1, 0);
            const Offset secondOffset = Offset(0.0, 0.0);
            final Animation<Offset> offsetTween =
                Tween<Offset>(begin: firstOffset, end: secondOffset)
                    .animate(animation1);

            return SlideTransition(
              position: offsetTween,
              child: child,
            );
          },
        ),
      );
  Future<dynamic> tonamedReplacement(
          {required String name, dynamic arguments}) =>
      Navigator.of(this).pushReplacementNamed(
        name,
        arguments: arguments,
      );
  dynamic pop({dynamic arguments}) => Navigator.of(this).pop(arguments);
}

extension DoubleExtensions on double? {
  bool get isMobile => (this ?? 0) <= 800.0;
  bool get isTablet => (this ?? 0) > 800.0 && (this ?? 0) <= 1200;
  bool get isDesktop => (this ?? 0) > 1200.0;
}
