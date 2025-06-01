import 'package:flutter/material.dart';
import 'package:winball/configs/configs.dart';

class InvitationBackgroundTemplateWidget extends StatelessWidget {
  const InvitationBackgroundTemplateWidget({
    super.key,
    this.child,
  });

  final Widget? child;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppConfigs.appBackgroundColor,
        borderRadius: BorderRadius.circular(
          AppConfigs.mediumVisualDensity,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppConfigs.minVisualDensity,
        ),
        child: child,
      ),
    );
  }
}
