import 'package:flutter/material.dart';
import 'package:winball/configs/configs.dart';

class SliderIndicatorWidget extends StatelessWidget {
  const SliderIndicatorWidget({
    super.key,
    required this.sliderLength,
    required this.currentSliderIndex,
  });
  final int sliderLength;
  final int currentSliderIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        sliderLength,
        (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConfigs.minVisualDensity / 2,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index == currentSliderIndex ? Colors.white : Colors.grey,
              ),
              child: const SizedBox.square(
                dimension: AppConfigs.mediumVisualDensity,
              ),
            ),
          );
        },
      ),
    );
  }
}
