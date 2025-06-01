import 'package:flutter/material.dart';
import 'package:winball_admin_panel/configs/configs.dart';

abstract class PagesRoutes {
  static Route<dynamic> onGenerateRoutes(RouteSettings settings) {
    final String? routename = settings.name;

    Widget? child;
    final int widgetIndex = AppPages.mapOfAppScreens.keys
        .toList()
        .indexWhere((e) => e == routename);
    if (widgetIndex != -1) {
      child = AppPages.mapOfAppScreens.values.toList().elementAt(widgetIndex);
    } else {
      child = AppPages.mapOfAppScreens.values.first;
    }
    return PageRouteBuilder(
      pageBuilder: (context, animation1, _) {
        const Offset startOffset = Offset(-1.0, 0.0);
        const Offset endOffset = Offset(0.0, 0.0);
        final Tween<Offset> slideTween = Tween<Offset>(
          begin: startOffset,
          end: endOffset,
        );
        final Animation<Offset> slideAnimation = animation1.drive(slideTween);
        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
      opaque: false,
      settings: settings,
    );
  }
}
