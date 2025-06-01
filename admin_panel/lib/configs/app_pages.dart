import 'package:flutter/material.dart' show Widget;
import 'package:winball_admin_panel/screens/screens.dart';

abstract class AppPages {
  static const String loginRegisterEntry = '/';

  static const Map<String, Widget> mapOfAppScreens = {
    loginRegisterEntry: AuthenticationControllerScreen(),
  };
}
