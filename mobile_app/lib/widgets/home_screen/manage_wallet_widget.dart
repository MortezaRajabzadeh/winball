import 'package:flutter/material.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/models/models.dart';
import 'package:winball/widgets/widgets.dart';

class ManageWalletWidget extends StatelessWidget {
  const ManageWalletWidget({
    super.key,
    required this.changeSelectedCryptoValueNotifier,
    required this.selectedCryptoValueNotifier,
  });
  final void Function({required CryptoModel cryptoModel})
      changeSelectedCryptoValueNotifier;
  final ValueNotifier<CryptoModel> selectedCryptoValueNotifier;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
        AppConfigs.mediumVisualDensity,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppConfigs.appShadowColor,
          borderRadius: BorderRadius.circular(
            AppConfigs.mediumVisualDensity,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppConfigs.mediumVisualDensity,
            horizontal: AppConfigs.largeVisualDensity,
          ),
          child: Row(
            children: [
              ListOfSupportedCryptosDropdownButtonWidget(
                changeSelectedCryptoValueNotifier:
                    changeSelectedCryptoValueNotifier,
                selectedCryptoValueNotifier: selectedCryptoValueNotifier,
              ),
              const AddAmountIconButtonWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
