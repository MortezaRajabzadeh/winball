import 'package:flutter/material.dart';
import 'package:winball/extensions/extensions.dart';

import '../../configs/app_configs.dart';

class CustomHomeScreenIconButtonWidget extends StatelessWidget {
  const CustomHomeScreenIconButtonWidget({
    super.key,
    required this.routename,
    required this.icon,
    required this.title,
    required this.color,
  });

  final String routename;
  final IconData icon;
  final String title;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConfigs.minVisualDensity,
            vertical: AppConfigs.largeVisualDensity,
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppConfigs.appShadowColor,
            ),
            child: IconButton(
              style: ButtonStyle(
                iconColor: WidgetStatePropertyAll<Color>(color),
                padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
                  EdgeInsets.all(
                    AppConfigs.extraLargeVisualDensity,
                  ),
                ),
              ),
              onPressed: () {
                if (routename.isNotEmpty) {
                  context.tonamed(name: routename);
                }
              },
              icon: Icon(icon),
            ),
          ),
        ),
        Text(title),
      ],
    );
  }
}
