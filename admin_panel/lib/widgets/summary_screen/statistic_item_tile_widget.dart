import 'package:flutter/material.dart';
import 'package:winball_admin_panel/configs/configs.dart';

class StatisticItemTileWidget extends StatelessWidget {
  const StatisticItemTileWidget({
    super.key,
    required this.description,
    required this.title,
  });

  final String description;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConfigs.largeVisualDensity,
          horizontal: AppConfigs.mediumVisualDensity,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppConfigs.titleTextStyle,
              textAlign: TextAlign.center,
            ),
            Text(
              description,
              style: AppConfigs.titleTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
