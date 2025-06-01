import 'package:flutter/material.dart';
import 'package:winball_admin_panel/configs/configs.dart';

class UserProfileCircleAvatarWidget extends StatelessWidget {
  const UserProfileCircleAvatarWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      backgroundImage: AssetImage(
        AppConfigs.btcIcon,
      ),
      radius: AppConfigs.largeVisualDensity,
    );
  }
}
