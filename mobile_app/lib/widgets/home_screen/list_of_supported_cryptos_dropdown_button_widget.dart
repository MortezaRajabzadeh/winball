import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/enums/enums.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/models/models.dart';
import 'package:winball/utils/functions.dart';
import 'package:winball/widgets/global/custom_space_widget.dart';

class ListOfSupportedCryptosDropdownButtonWidget extends StatelessWidget {
  const ListOfSupportedCryptosDropdownButtonWidget({
    super.key,
    required this.selectedCryptoValueNotifier,
    required this.changeSelectedCryptoValueNotifier,
  });
  final ValueNotifier<CryptoModel> selectedCryptoValueNotifier;
  final void Function({required CryptoModel cryptoModel})
      changeSelectedCryptoValueNotifier;

  @override
  Widget build(BuildContext context) {
    final UserModel currentUser = context.watchAppBloc.state.currentUser;
    return SizedBox(
      width: AppConfigs.xxxLargeVisualDensity * 2.5,
      child: ValueListenableBuilder<CryptoModel>(
        valueListenable: selectedCryptoValueNotifier,
        builder: (context, selectedCrypto, _) {
          return DropdownButton(
            dropdownColor: AppConfigs.appShadowColor,
            underline: const SizedBox.shrink(),
            value: selectedCrypto,
            icon: const Icon(Icons.keyboard_arrow_down_sharp),
            onChanged: (CryptoModel? cryptoModel) {
              changeSelectedCryptoValueNotifier(
                cryptoModel:
                    cryptoModel ?? AppConfigs.listOfSupportedCryptoModels.first,
              );
            },
            items: List.generate(
              AppConfigs.listOfSupportedCryptoModels.length,
              (index) {
                final CryptoModel cryptoModel =
                    AppConfigs.listOfSupportedCryptoModels.elementAt(index);
                return DropdownMenuItem(
                  value: cryptoModel,
                  child: SizedBox(
                    width: AppConfigs.xxxLargeVisualDensity * 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          const Functions().getUserInventoryByCoinType(
                            coinType: cryptoModel.coinType,
                            userModel: currentUser,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              (cryptoModel.coinType == CoinType.stars
                                      ? AppTexts.stars
                                      : cryptoModel.coinType.name)
                                  .toUpperCase(),
                            ),
                            const CustomSpaceWidget(
                              sizeDirection: SizeDirection.horizontal,
                            ),
                            CircleAvatar(
                              backgroundImage: AssetImage(
                                cryptoModel.pictureUrl,
                              ),
                              radius: 9,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
