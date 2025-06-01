import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:help_repository/help_repository.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:transaction_repository/transaction_repository.dart';
import 'package:user_bet_repository/user_bet_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/enums/enums.dart';
import 'package:winball_admin_panel/extensions/extensions.dart';
import 'package:winball_admin_panel/models/dialog_model.dart';
import 'package:winball_admin_panel/models/orgnzied_helps_by_title_model.dart';
import 'package:winball_admin_panel/widgets/global/custom_space_widget.dart';

class Functions {
  const Functions();
  String convertDateTimeToDateAndTime({required DateTime dateTime}) {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} / ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  OverlayEntry? showOverlayDialog({
    required DialogModel dialogModel,
    required BuildContext context,
  }) {
    final OverlayState overlayState = Overlay.of(context);
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: context.getSize.height / 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConfigs.largeVisualDensity,
                  ),
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppConfigs.appBackgroundColor,
                        borderRadius: BorderRadius.circular(
                          AppConfigs.minVisualDensity,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppConfigs.mediumVisualDensity,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(dialogModel.title),
                            const Divider(),
                            const CustomSpaceWidget(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SingleChildScrollView(
                                  child: Text(
                                    dialogModel.description,
                                  ),
                                ),
                                if (dialogModel.dialogType ==
                                    DialogType.loading) ...[
                                  const CustomSpaceWidget(
                                    sizeDirection: SizeDirection.horizontal,
                                  ),
                                  const CircularProgressIndicator(),
                                ],
                              ],
                            ),
                            const CustomSpaceWidget(
                              size: AppConfigs.largeVisualDensity,
                            ),
                            const Divider(),
                            Row(
                              children: [
                                if (dialogModel.dialogType ==
                                    DialogType.error) ...[
                                  ...(dialogModel.buttons ?? []),
                                ],
                                TextButton(
                                  onPressed: entry?.remove,
                                  child: const Text(
                                    AppTexts.gotit,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      opaque: false,
    );
    overlayState.insert(entry);
    return entry;
  }

  List<OrgnziedHelpsByTitleModel> getOrgnizedHelpsByListOfHelps(
      {required List<HelpModel> helps}) {
    final List<OrgnziedHelpsByTitleModel> orgnizedHelps = [];
    final Set<String> titles = {};
    for (final HelpModel help in helps) {
      titles.add(help.title);
    }
    for (final String title in titles) {
      orgnizedHelps.add(
        OrgnziedHelpsByTitleModel(
          title: title,
          helps: helps.where((e) => e.title == title).toList(),
        ),
      );
    }
    return orgnizedHelps;
  }

  String convertSecondsToHoursAndMinutes({required int seconds}) {
    int allSeconds = seconds;
    int hours = 0;
    hours = (allSeconds / 3600).floor();
    allSeconds -= hours * 3600;
    int minutes = (allSeconds / 60).floor();
    allSeconds -= minutes * 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${allSeconds.toString().padLeft(2, '0')}';
  }

  int getNumberByGameResult({required OneMinGameResult oneMinGameResult}) {
    switch (oneMinGameResult) {
      case OneMinGameResult.redPurple0:
        return 0;
      case OneMinGameResult.green1:
        return 1;
      case OneMinGameResult.red2:
        return 2;
      case OneMinGameResult.green3:
        return 3;
      case OneMinGameResult.red4:
        return 4;
      case OneMinGameResult.greenPurple5:
        return 5;
      case OneMinGameResult.red6:
        return 6;
      case OneMinGameResult.green7:
        return 7;
      case OneMinGameResult.red8:
        return 8;
      case OneMinGameResult.green9:
        return 9;
    }
  }

  List<Color> getListOfColorsByGameResult(
      {required OneMinGameResult oneMinGameResult}) {
    switch (oneMinGameResult) {
      case OneMinGameResult.redPurple0:
        return [Colors.red, Colors.purple];
      case OneMinGameResult.green1:
        return [Colors.green];
      case OneMinGameResult.red2:
        return [Colors.red];
      case OneMinGameResult.green3:
        return [Colors.green];
      case OneMinGameResult.red4:
        return [Colors.red];
      case OneMinGameResult.greenPurple5:
        return [Colors.green, Colors.purple];
      case OneMinGameResult.red6:
        return [Colors.red];
      case OneMinGameResult.green7:
        return [Colors.green];
      case OneMinGameResult.red8:
        return [Colors.red];
      case OneMinGameResult.green9:
        return [Colors.green];
    }
  }

  Color getColorsByUserBetOptions({required UserBetOptions options}) {
    switch (options) {
      case UserBetOptions.redPurple0:
        return Colors.purple;
      case UserBetOptions.green1:
        return Colors.green;
      case UserBetOptions.red2:
        return Colors.red;
      case UserBetOptions.green3:
        return Colors.green;
      case UserBetOptions.red4:
        return Colors.red;
      case UserBetOptions.greenPurple5:
        return Colors.green;
      case UserBetOptions.red6:
        return Colors.red;
      case UserBetOptions.green7:
        return Colors.green;
      case UserBetOptions.red8:
        return Colors.red;
      case UserBetOptions.green9:
        return Colors.green;
      case UserBetOptions.green:
        return Colors.green;
      case UserBetOptions.red:
        return Colors.red;
      case UserBetOptions.purple:
        return Colors.purple;
    }
  }

  String convertListOfUserBetOptionsToString(
      {required List<UserBetOptions> listOfUserBetOptions}) {
    String optionsString = '';
    for (final UserBetOptions options in listOfUserBetOptions) {
      optionsString += ' ${convertUserBetOptionsToString(options: options)}';
    }
    return optionsString;
  }

  String convertUserBetOptionsToString({required UserBetOptions options}) {
    switch (options) {
      case UserBetOptions.redPurple0:
        return '0';
      case UserBetOptions.green1:
        return '1';
      case UserBetOptions.red2:
        return '2';
      case UserBetOptions.green3:
        return '3';
      case UserBetOptions.red4:
        return '4';
      case UserBetOptions.greenPurple5:
        return '5';
      case UserBetOptions.red6:
        return '6';
      case UserBetOptions.green7:
        return '7';
      case UserBetOptions.red8:
        return '8';
      case UserBetOptions.green9:
        return '9';
      case UserBetOptions.green:
        return 'Green';
      case UserBetOptions.red:
        return 'Red';
      case UserBetOptions.purple:
        return 'Purple';
    }
  }

  double calculateBetResultByGameResultAndListOfSelectedOptions({
    required OneMinGameResult gameResult,
    required List<UserBetOptions> options,
    required double amountPerOption,
  }) {
    double totalAmount = 0.0;
    for (final UserBetOptions ubo in options) {
      if (gameResult.name.toLowerCase() == ubo.name.toLowerCase()) {
        totalAmount += (amountPerOption) * 9.75;
      } else if (gameResult.name
          .toLowerCase()
          .contains(ubo.name.toLowerCase())) {
        if (ubo.name.toLowerCase() == 'purple') {
          totalAmount += (amountPerOption) * 4.87;
        } else {
          totalAmount += (amountPerOption) * 1.95;
        }
      }
    }
    return totalAmount;
  }

  List<UserBetOptions> convertUserBetStringToListUserBetOptions(
      {required String userBets}) {
    if (userBets.isValidJson) {
      return userBets
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '')
          .split(',')
          .map(
            (String e) =>
                const OneMinGameFunctions().convertStringToUserBetOptions(
              option: e,
            ),
          )
          .toList();
    }
    return [];
  }

  String handleUserBetsStringToListOfBetsString({required String userBet}) {
    return convertUserBetStringToListUserBetOptions(userBets: userBet)
        .map((UserBetOptions e) => e.name)
        .join(' ');
  }

  Color isColorExistsInGameResult(
      {required UserBetOptions userBetOptions,
      required OneMinGameResult oneMinGameResult}) {
    if (userBetOptions.name.toLowerCase() ==
        oneMinGameResult.name.toLowerCase()) {
      return AppConfigs.yellowColor;
    } else {
      if (oneMinGameResult.name
          .toLowerCase()
          .contains(userBetOptions.name.toLowerCase())) {
        return AppConfigs.yellowColor;
      }
    }
    return Colors.white;
  }

  String? getUserInventoryByCoinType(
      {required UserModel? userModel, required CoinType coinType}) {
    switch (coinType) {
      case CoinType.ton:
        return userModel?.tonInventory.convertToNum
            .toDouble()
            .toStringAsFixed(2);
      case CoinType.stars:
        return userModel?.starsInventory.convertToNum
            .toDouble()
            .toStringAsFixed(2);
      case CoinType.usdt:
        return userModel?.usdtInventory.convertToNum
            .toDouble()
            .toStringAsFixed(2);
      case CoinType.btc:
        return userModel?.btcInventory.convertToNum
            .toDouble()
            .toStringAsFixed(2);
      case CoinType.cusd:
        return userModel?.cusdInventory.convertToNum
            .toDouble()
            .toStringAsFixed(2);
    }
  }

  double getWholeStarsAmountWithListOfTransactions(
      {required List<TransactionModel> transactions}) {
    double wholeStarsAmount = 0;
    for (final TransactionModel transactionModel in transactions) {
      if (transactionModel.coinType == CoinType.stars &&
          transactionModel.transactionStatus == TransactionStatus.success) {
        wholeStarsAmount += transactionModel.amount.convertToNum.toInt();
      }
    }
    return wholeStarsAmount;
  }

  double getWholeTonAmountWithListOfTransactions(
      {required List<TransactionModel> transactions}) {
    double wholeTonAmount = 0;
    for (final TransactionModel transactionModel in transactions) {
      if (transactionModel.coinType == CoinType.ton &&
          transactionModel.transactionStatus == TransactionStatus.success) {
        wholeTonAmount += (double.tryParse(transactionModel.amount) ?? 0);
      }
    }
    return wholeTonAmount / AppConfigs.tonBaseFactory;
  }

  double addEndGameResultOfUserBets({required List<UserBetModel> userBets}) {
    double totalAmount = 0;
    for (final UserBetModel userBetModel in userBets) {
      totalAmount += double.parse(userBetModel.endGameResult);
      // totalAmount -= double.parse(userBetModel.amount);
    }
    return totalAmount;
  }

  double addAmountOfUserBets({required List<UserBetModel> userBets}) {
    double totalAmount = 0;
    for (final UserBetModel userBetModel in userBets) {
      totalAmount += double.parse(userBetModel.amount);
    }
    return totalAmount;
  }
}
