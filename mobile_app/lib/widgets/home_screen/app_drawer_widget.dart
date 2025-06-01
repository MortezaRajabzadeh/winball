import 'package:flutter/material.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/enums/enums.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/models/models.dart';
import 'package:winball/widgets/widgets.dart';

class AppDrawerWidget extends StatelessWidget {
  const AppDrawerWidget({
    super.key,
    required this.changeSelectedCryptoValueNotifier,
    required this.selectedCryptoValueNotifier,
  });
  final ValueNotifier<CryptoModel> selectedCryptoValueNotifier;
  final void Function({required CryptoModel cryptoModel})
      changeSelectedCryptoValueNotifier;
  @override
  Widget build(BuildContext context) {
    final Size size = context.getSize;
    return Drawer(
      width: size.width.isMobile ? size.width : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConfigs.largeVisualDensity,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      Scaffold.of(context).closeDrawer();
                    },
                  ),
                  const Spacer(),
                  ManageWalletWidget(
                    changeSelectedCryptoValueNotifier:
                        changeSelectedCryptoValueNotifier,
                    selectedCryptoValueNotifier: selectedCryptoValueNotifier,
                  ),
                  // const WalletIconButtonWidget(),
                  // const UserProfileCircleAvatarWidget(),
                  const CustomSpaceWidget(
                    sizeDirection: SizeDirection.horizontal,
                  ),
                ],
              ),
              const CustomSpaceWidget(),
              const GoToSearchScreenTextFieldWidget(),
              const CustomSpaceWidget(
                size: AppConfigs.largeVisualDensity,
              ),
              Text(
                AppTexts.games.toUpperCase(),
                style: AppConfigs.subtitleTextStyle,
              ),
              const CustomSpaceWidget(),
              TextButton.icon(
                onPressed: () {
                  context.tonamed(
                    name: AppPages.listOfGamesScreen,
                  );
                },
                label: const Text(AppTexts.casino),
                icon: const Icon(Icons.casino_outlined),
              ),
              const CustomSpaceWidget(),
              Text(
                AppTexts.more.toUpperCase(),
                style: AppConfigs.subtitleTextStyle,
              ),
              const CustomSpaceWidget(),
              TextButton.icon(
                onPressed: () {
                  context.tonamed(name: AppPages.earnScreen);
                },
                label: const Text(AppTexts.earn),
                icon: const Icon(Icons.diamond_outlined),
              ),
              const CustomSpaceWidget(),
              Text(
                AppTexts.user.toUpperCase(),
                style: AppConfigs.subtitleTextStyle,
              ),
              const CustomSpaceWidget(),
              TextButton.icon(
                onPressed: () {
                  context.tonamed(name: AppPages.profileScreen);
                },
                label: const Text(AppTexts.profile),
                icon: const Icon(Icons.supervised_user_circle_outlined),
              ),
              const CustomSpaceWidget(),
              // TextButton.icon(
              //   onPressed: () {},
              //   label: const Text(AppTexts.wallet),
              //   icon: const Icon(Icons.account_balance_wallet),
              // ),
              const CustomSpaceWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
