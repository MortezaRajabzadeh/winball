import 'package:flutter/material.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/enums/enums.dart';
import 'package:winball/widgets/global/custom_space_widget.dart';

class CustomLabelAndGamesWidget extends StatelessWidget {
  const CustomLabelAndGamesWidget({
    super.key,
    required this.icon,
    required this.listOfGames,
    required this.title,
    required this.iconColor,
  });
  final String title;
  final IconData icon;
  final List<String> listOfGames;
  final Color iconColor;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppConfigs.xxxLargeVisualDensity * 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
              ),
              const CustomSpaceWidget(
                sizeDirection: SizeDirection.horizontal,
              ),
              Text(
                title,
                style: AppConfigs.boldTextStyle,
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {},
                child: const Text(AppTexts.viewAll),
              ),
            ],
          ),
          const CustomSpaceWidget(
            size: AppConfigs.largeVisualDensity,
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AppConfigs.sliderImages.length,
              itemBuilder: (context, index) {
                final String imagePath = AppConfigs.sliderImages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConfigs.mediumVisualDensity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                imagePath,
                              ),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppConfigs.mediumVisualDensity,
                            ),
                          ),
                          child: const SizedBox(
                            width: AppConfigs.xxxLargeVisualDensity * 2,
                          ),
                        ),
                      ),
                      const CustomSpaceWidget(),
                      const Text(
                        'Game name',
                        style: AppConfigs.boldTextStyle,
                      ),
                      const Text(
                        'publisher',
                        style: AppConfigs.subtitleTextStyle,
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
