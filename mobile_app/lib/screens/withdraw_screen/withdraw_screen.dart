import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball/bloc/app_bloc/app_bloc.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/utils/functions.dart';
import 'package:winball/widgets/global/custom_error_widget.dart';
import 'package:winball/widgets/global/custom_space_widget.dart';
import 'package:winball/widgets/global/loading_widget.dart';
import 'package:withdraw_repository/withdraw_repository.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  late final Functions functions;
  late final GlobalKey<FormState> _formKey;
  late final AppBloc appBloc;
  late final TextEditingController amountTextEditingController,
      walletAddressTextEditingController;
  late final WithdrawRepositoryFunctions withdrawRepositoryFunctions;
  void initializeDatas() {
    appBloc = context.readAppBloc;
    amountTextEditingController = TextEditingController();
    walletAddressTextEditingController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    functions = const Functions();
    withdrawRepositoryFunctions = const WithdrawRepositoryFunctions();
  }

  void dispositionalDatas() {
    amountTextEditingController.dispose();
    walletAddressTextEditingController.dispose();
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
        title: const Text(AppTexts.withdraw),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConfigs.mediumVisualDensity,
          horizontal: AppConfigs.mediumVisualDensity,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(AppTexts.withdrawMoreInfo),
              const CustomSpaceWidget(),
              TextFormField(
                controller: amountTextEditingController,
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
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (String? value) {
                  final double minWithdrawAmount = appBloc
                      .state.siteSettingModel.minWithdrawAmount.convertToNum
                      .toDouble();
                  return (value ?? '0').convertToNum.toDouble() >=
                          minWithdrawAmount
                      ? null
                      : '${AppTexts.minWithdrawAmountIs}${appBloc.state.siteSettingModel.minWithdrawAmount}';
                },
                decoration: AppConfigs.customInputDecoration.copyWith(
                    labelText:
                        '${AppTexts.withdrawAmount} (${appBloc.state.selectedCoinType.coinName})'),
              ),
              const CustomSpaceWidget(),
              TextFormField(
                controller: walletAddressTextEditingController,
                validator: (String? value) {
                  return (value ?? '').isNotEmpty
                      ? null
                      : AppTexts.walletAddressIsRequired;
                },
                decoration: AppConfigs.customInputDecoration.copyWith(
                  labelText: AppTexts.walletAddress,
                ),
              ),
              const CustomSpaceWidget(
                size: AppConfigs.largeVisualDensity,
              ),
              const Text(
                AppTexts.yourInventoryIs,
                style: AppConfigs.boldTextStyle,
              ),
              const CustomSpaceWidget(),
              Row(
                children: [
                  const Text(AppTexts.tonInventory),
                  const Spacer(),
                  Builder(builder: (context) {
                    final UserModel currentUser =
                        context.watchAppBloc.state.currentUser;
                    return Text(
                      functions.getUserInventoryByCoinType(
                        userModel: currentUser,
                        coinType: CoinType.ton,
                      ),
                    );
                  }),
                ],
              ),
              const CustomSpaceWidget(),
              // Row(
              //   children: [
              //     const Text(AppTexts.starsInventory),
              //     const Spacer(),
              //     Text(
              //       functions.getUserInventoryByCoinType(
              //         userModel: appBloc.state.currentUser,
              //         coinType: CoinType.stars,
              //       ),
              //     ),
              //   ],
              // ),
              // const CustomSpaceWidget(),
              Row(
                children: [
                  const Text(AppTexts.minWithdrawAmount),
                  const Spacer(),
                  Text(appBloc.state.siteSettingModel.minWithdrawAmount),
                ],
              ),
              const CustomSpaceWidget(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      trailing: IconButton(
                        icon: const Icon(Icons.question_mark_rounded),
                        onPressed: () {
                          showAdaptiveDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog.adaptive(
                                actions: [
                                  TextButton(
                                    child: const Text(AppTexts.confirm),
                                    onPressed: () {
                                      context.pop();
                                    },
                                  ),
                                ],
                                title: const Text(
                                  AppTexts.tips,
                                  style: AppConfigs.titleTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                                content: const SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Text(
                                        AppTexts.unfinishedFlowTops,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        style: const ButtonStyle(
                          padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
                            EdgeInsets.zero,
                          ),
                          iconSize: WidgetStatePropertyAll<double>(
                            AppConfigs.largeVisualDensity,
                          ),
                          iconColor: WidgetStatePropertyAll<Color>(
                            AppConfigs.yellowColor,
                          ),
                        ),
                      ),
                      title: const Text(
                        AppTexts.unfinishedFlow,
                        style: AppConfigs.subtitleTextStyle,
                      ),
                    ),
                  ),
                  const Spacer(),
                  FutureBuilder<double>(
                    future: withdrawRepositoryFunctions.getWithdrawableAmount(
                      coinType: context.readAppBloc.state.selectedCoinType,
                      token: context.readAppBloc.state.currentUser.token ?? '',
                    ),
                    builder: (context, AsyncSnapshot<double> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingWidget();
                      } else if (snapshot.hasData && snapshot.data != null) {
                        final double withdrawableAmount = snapshot.data ?? 0;
                        // here is the unfinished flow : 0.0000019073486
                        return Text(
                          withdrawableAmount < 0
                              ? '0'
                              : withdrawableAmount.toStringAsFixed(2),
                        );
                      } else if (snapshot.hasError) {
                        return CustomErrorWidget(
                          error: snapshot.error.toString(),
                        );
                      } else {
                        return const CustomErrorWidget();
                      }
                    },
                  ),
                ],
              ),

              const CustomSpaceWidget(),
              const Spacer(),
              ElevatedButton(
                child: const Text(AppTexts.createWithdraw),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    appBloc.add(
                      CreateWithdrawEvent(
                        address: walletAddressTextEditingController.text,
                        amount: appBloc.state.selectedCoinType == CoinType.ton
                            ? ((double.tryParse(
                                            amountTextEditingController.text) ??
                                        0) *
                                    AppConfigs.tonBaseFactor)
                                .toString()
                            : amountTextEditingController.text,
                        coinType: appBloc.state.selectedCoinType,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
