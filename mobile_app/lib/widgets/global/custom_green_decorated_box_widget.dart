import 'package:flutter/material.dart';
import 'package:winball/configs/configs.dart';

class CustomGreenDecoratedBoxWidget extends StatelessWidget {
  const CustomGreenDecoratedBoxWidget({
    super.key,
    this.child,
  });
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConfigs.greenColor.withOpacity(0.5),
            Colors.transparent,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(
          AppConfigs.mediumVisualDensity,
        ),
      ),
      child: child,
    );
  }
}
