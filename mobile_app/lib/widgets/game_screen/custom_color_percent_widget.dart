import 'package:flutter/material.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/utils/functions.dart';
import 'package:winball/widgets/global/custom_space_widget.dart';

class CustomColorPercentWidget extends StatelessWidget {
  const CustomColorPercentWidget({
    super.key,
    required this.percent,
    required this.title,
    required this.userBetOptions,
    required this.onTap,
    required this.listOfSelectedUserBetOptionsValueNotifier,
  });
  final String title;
  final double percent;
  final UserBetOptions userBetOptions;
  final void Function({required UserBetOptions userBetOptions}) onTap;
  final ValueNotifier<List<UserBetOptions>>
      listOfSelectedUserBetOptionsValueNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<UserBetOptions>>(
      valueListenable: listOfSelectedUserBetOptionsValueNotifier,
      builder: (context, options, _) {
        final bool isSelected = options.contains(userBetOptions);
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConfigs.mediumVisualDensity,
          ),
          child: GestureDetector(
            onTap: () {
              onTap(userBetOptions: userBetOptions);
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isSelected
                    ? const Functions()
                        .getColorsByUserBetOptions(options: userBetOptions)
                    : AppConfigs.appShadowColor,
                borderRadius: BorderRadius.circular(
                  AppConfigs.mediumVisualDensity,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConfigs.minVisualDensity,
                  horizontal: AppConfigs.largeVisualDensity,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: isSelected ? AppConfigs.blackTextStyle : null,
                    ),
                    const CustomSpaceWidget(),
                    Text(
                      '${percent}x',
                      style: isSelected ? AppConfigs.blackTextStyle : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
