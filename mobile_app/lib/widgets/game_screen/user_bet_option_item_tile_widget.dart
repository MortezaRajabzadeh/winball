import 'package:flutter/material.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/widgets/global/custom_space_widget.dart';

class UserBetOptionItemTileWidget extends StatelessWidget {
  const UserBetOptionItemTileWidget({
    super.key,
    required this.colors,
    required this.optionIndex,
    required this.userBetOptions,
    required this.onTap,
    required this.listOfUserBetsValueNotifier,
  });
  final UserBetOptions userBetOptions;
  final List<Color> colors;
  final int optionIndex;
  final void Function({required UserBetOptions userBetOptions}) onTap;
  final ValueNotifier<List<UserBetOptions>> listOfUserBetsValueNotifier;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<UserBetOptions>>(
      valueListenable: listOfUserBetsValueNotifier,
      builder: (context, options, _) {
        final bool isSelected = options.contains(userBetOptions);
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppConfigs.mediumVisualDensity,
            horizontal: AppConfigs.mediumVisualDensity,
          ),
          child: GestureDetector(
            onTap: () {
              onTap(userBetOptions: userBetOptions);
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppConfigs.yellowColor
                    : AppConfigs.appShadowColor,
                borderRadius: BorderRadius.circular(
                  AppConfigs.mediumVisualDensity,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConfigs.mediumVisualDensity,
                  horizontal: AppConfigs.largeVisualDensity * 1.3,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$optionIndex',
                      style: isSelected ? AppConfigs.blackTextStyle : null,
                    ),
                    const CustomSpaceWidget(),
                    Text(
                      '9.75x',
                      style: isSelected ? AppConfigs.blackTextStyle : null,
                    ),
                    const CustomSpaceWidget(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.length == 1 ? colors.first : null,
                        gradient: colors.length > 1
                            ? LinearGradient(
                                colors: colors,
                                tileMode: TileMode.clamp,
                                begin: Alignment.centerRight,
                                end: Alignment.centerLeft,
                                stops: const [
                                  0.5,
                                  0.5,
                                ],
                              )
                            : null,
                      ),
                      child: const SizedBox(
                        width: 30,
                        height: 2,
                      ),
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
