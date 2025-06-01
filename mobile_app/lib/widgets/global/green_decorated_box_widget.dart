import 'package:flutter/material.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/widgets/widgets.dart';

class GreenDecoratedBoxWidget extends StatelessWidget {
  const GreenDecoratedBoxWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomGreenDecoratedBoxWidget(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConfigs.largeVisualDensity,
          horizontal: AppConfigs.mediumVisualDensity,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppTexts.claimableEarnings,
                  style: AppConfigs.greenTextStyle,
                ),
                const CircleAvatar(
                  backgroundImage: AssetImage(
                    AppConfigs.tonCoin,
                  ),
                  radius: AppConfigs.mediumVisualDensity,
                ),
                BlueBackgroundWidget(
                  borderRadius: BorderRadius.circular(
                    AppConfigs.mediumVisualDensity,
                  ),
                  child: const ElevatedButton(
                    onPressed: null,
                    child: Text(
                      AppTexts.claimEarnings,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              '0.0',
              style: AppConfigs.whiteBoldTextStyle,
            ),
          ],
        ),
      ),
    );
  }
}
