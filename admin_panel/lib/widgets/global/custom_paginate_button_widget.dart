import 'package:flutter/material.dart';
import 'package:winball_admin_panel/configs/app_configs.dart';

class CustomPaginateButtonWidget extends StatelessWidget {
  const CustomPaginateButtonWidget({
    super.key,
    required this.child,
    this.onPressed,
  });
  final Widget child;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppConfigs.minVisualDensity),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppConfigs.appShadowColor,
          borderRadius: BorderRadius.circular(
            AppConfigs.mediumVisualDensity,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConfigs.minVisualDensity),
          child: IconButton(
            icon: child,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
