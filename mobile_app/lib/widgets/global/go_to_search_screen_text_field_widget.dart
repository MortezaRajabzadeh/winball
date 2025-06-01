import 'package:flutter/material.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/extensions/extensions.dart';

class GoToSearchScreenTextFieldWidget extends StatelessWidget {
  const GoToSearchScreenTextFieldWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.tonamed(
          name: AppPages.searchScreen,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppConfigs.appShadowColor,
          borderRadius: BorderRadius.circular(
            AppConfigs.largeVisualDensity,
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConfigs.largeVisualDensity,
            vertical: AppConfigs.largeVisualDensity,
          ),
          child: Row(
            children: [
              Icon(Icons.search),
              Text(
                AppTexts.findAGame,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
