import 'package:flutter/material.dart';
import 'package:winball/configs/app_configs.dart';

class BlueBackgroundWidget extends StatelessWidget {
  const BlueBackgroundWidget({
    super.key,
    this.borderRadius,
    this.child,
    this.showBackground = true,
  });
  final BorderRadiusGeometry? borderRadius;
  final Widget? child;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: showBackground
            ? const LinearGradient(
                colors: [
                  AppConfigs.lightBlueButtonColor,
                  AppConfigs.darkBlueButtonColor,
                  AppConfigs.lightBlueButtonColor,
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              )
            : null,
      ),
      child: child,
    );
  }
}
