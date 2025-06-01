import 'dart:async';

import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:site_settings_repository/site_settings_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball/bloc/app_bloc/app_bloc.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/utils/functions.dart';
import 'package:winball/widgets/widgets.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  late final AppBloc appBloc;
  late final UserModel currentUser;
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController amountToPayTextEditingController;
  late final Functions functions;
  late final ValueNotifier<bool> canCheckForPayValueNotifier;
  Timer? checkForPayTimer;

  void initializeDatas() {
    canCheckForPayValueNotifier = ValueNotifier<bool>(true);
    functions = const Functions();
    appBloc = context.readAppBloc;
    currentUser = appBloc.state.currentUser;
    amountToPayTextEditingController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  void startTimer() {
    checkForPayTimer?.cancel();
    checkForPayTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      changeCanCheckForPayValueNotifier(check: true);
    });
  }

  void dispositionalDatas() {
    checkForPayTimer?.cancel();
    canCheckForPayValueNotifier.dispose();
    amountToPayTextEditingController.dispose();
  }

  void changeCanCheckForPayValueNotifier({required bool check}) {
    canCheckForPayValueNotifier.value = check;
  }

  @override
  void initState() {
    super.initState();
    initializeDatas();
  }

  @override
  void dispose() {
    dispositionalDatas();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppTexts.deposit),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppConfigs.mediumVisualDensity,
              horizontal: AppConfigs.largeVisualDensity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${AppTexts.depositMoreInfo}${currentUser.userUniqueNumber}',
                ),
                const CustomSpaceWidget(),
                Text(
                  '${AppTexts.depositPayAttention} ${context.readAppBloc.state.siteSettingModel.minDepositAmount} ${AppTexts.minDepositWarning}',
                  style: AppConfigs.boldTextStyle,
                ),
                const CustomSpaceWidget(),
                TextFormField(
                  validator: (String? value) {
                    final SiteSettingModel siteSettingModel =
                        appBloc.state.siteSettingModel;
                    return (value ?? '0').convertToNum.toDouble() >=
                            siteSettingModel.minDepositAmount.convertToNum
                                .toDouble()
                        ? null
                        : '${AppTexts.minDepositAmountIs}${siteSettingModel.minDepositAmount}';
                  },
                  controller: amountToPayTextEditingController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: AppConfigs.customInputDecoration.copyWith(
                    labelText: AppTexts.amount,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9.,]'),
                      replacementString: '0',
                    ),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      // تبدیل ویرگول به نقطه
                      return TextEditingValue(
                        text: newValue.text.replaceAll(',', '.'),
                        selection: newValue.selection,
                      );
                    }),
                  ],
                ),
                const CustomSpaceWidget(),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppConfigs.appShadowColor,
                    borderRadius: BorderRadius.circular(
                      AppConfigs.mediumVisualDensity,
                    ),
                  ),
                  child: ListTile(
                    leading: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(
                          const ClipboardData(
                            text: AppConfigs.casinoWalletAddress,
                          ),
                        );
                      },
                    ),
                    title: const Text(
                      '${AppTexts.casinoWalletAddress}${AppConfigs.casinoWalletAddress}',
                    ),
                  ),
                ),
                const CustomSpaceWidget(
                  size: AppConfigs.largeVisualDensity,
                ),
                SizedBox(
                  height: 100.0,
                  child: Center(
                    child: QrImageView(
                      backgroundColor: Colors.white,
                      data: functions.getTonPaymentLinkUrl(
                        amount:
                            '${amountToPayTextEditingController.text.convertToNum.toDouble() * AppConfigs.tonBaseFactor}',
                        walletAddress: AppConfigs.casinoWalletAddress,
                        userId: currentUser.userUniqueNumber,
                      ),
                    ),
                  ),
                ),
                const CustomSpaceWidget(
                  size: AppConfigs.largeVisualDensity,
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: canCheckForPayValueNotifier,
                  builder: (context, check, _) {
                    return ElevatedButton(
                      onPressed: check
                          ? () {
                              context.readAppBloc.add(
                                const CheckTonTransactionEvent(),
                              );
                              changeCanCheckForPayValueNotifier(check: false);
                              startTimer();
                            }
                          : null,
                      child: const Text(AppTexts.checkYourPay),
                    );
                  },
                ),
                // const CustomSpaceWidget(),
                // ElevatedButton(
                //   child: const Text(AppTexts.payStars),
                //   onPressed: () {
                //     context.readAppBloc.add(
                //       GetStarsPaymentEvent(
                //         amount: amountToPayTextEditingController.text,
                //       ),
                //     );
                //   },
                // ),
                const CustomSpaceWidget(),
                ElevatedButton(
                  child: const Text(AppTexts.pay),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await launchUrl(
                        Uri.parse(
                          functions.getTonPaymentLinkUrl(
                            amount:
                                '${amountToPayTextEditingController.text.convertToNum.toDouble() * AppConfigs.tonBaseFactor}',
                            walletAddress: AppConfigs.casinoWalletAddress,
                            userId: currentUser.userUniqueNumber,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
