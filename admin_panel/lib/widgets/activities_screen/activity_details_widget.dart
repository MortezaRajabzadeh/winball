import 'package:activity_repository/activity_repository.dart';
import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/widgets/global/custom_space_widget.dart';

class ActivityDetailsWidget extends StatelessWidget {
  const ActivityDetailsWidget({
    super.key,
    required this.activityModel,
  });

  final ActivityModel activityModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            AppTexts.details,
            style: AppConfigs.titleTextStyle,
          ),
          const Divider(),
          const CustomSpaceWidget(),
          Text(
            '${AppTexts.title}:${activityModel.title}',
          ),
          const CustomSpaceWidget(),
          Text(
            '${AppTexts.details}:${activityModel.details}',
          ),
          const Divider(),
          const CustomSpaceWidget(),
          Image.network(
            '${BaseConfigs.serveImage}${activityModel.bannerUrl}',
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
