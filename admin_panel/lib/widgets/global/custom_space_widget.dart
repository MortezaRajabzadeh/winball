import 'package:flutter/material.dart';
import 'package:winball_admin_panel/configs/app_configs.dart';
import 'package:winball_admin_panel/enums/enums.dart';

class CustomSpaceWidget extends StatelessWidget {
  const CustomSpaceWidget({
    super.key,
    this.sizeDirection = SizeDirection.vertical,
    this.size = AppConfigs.mediumVisualDensity,
  });
  final SizeDirection sizeDirection;
  final double size;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: sizeDirection == SizeDirection.vertical ? 0 : size,
      height: sizeDirection == SizeDirection.horizontal ? 0 : size,
    );
  }
}
