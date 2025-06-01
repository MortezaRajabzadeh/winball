import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:winball/bloc/app_bloc/app_bloc.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/models/websocket_server_model.dart';
import 'package:winball/utils/functions.dart';
import 'package:winball/widgets/global/custom_space_widget.dart';

class CreateUserBetButtonWidget extends StatelessWidget {
  const CreateUserBetButtonWidget({
    super.key,
    required this.currentWebsocketServerModelValueNotifier,
    required this.canChangeSelectedOptionsValueNotifier,
    required this.listOfSelectedUserBetOptionsValueNotifier,
    required this.currentGameTimerValueNotifier,
    required this.functions,
    required this.amountPerOptionsValueNotifier,
    required this.amount,
    required this.changeCanChangeSelectedOptionsValueNotifier,
    required this.onBetSubmitted,
  });
  final void Function({required bool canChange})
      changeCanChangeSelectedOptionsValueNotifier;
  final ValueNotifier<bool> canChangeSelectedOptionsValueNotifier;
  final ValueNotifier<WebsocketServerModel>
      currentWebsocketServerModelValueNotifier;
  final ValueNotifier<List<UserBetOptions>>
      listOfSelectedUserBetOptionsValueNotifier;
  final Functions functions;
  final ValueNotifier<double> amountPerOptionsValueNotifier;
  final ValueNotifier<int> currentGameTimerValueNotifier;
  final String amount;
  final VoidCallback onBetSubmitted;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: canChangeSelectedOptionsValueNotifier,
      builder: (context, canChange, child) {
        return canChange
            ? child!
            : const ElevatedButton(
                onPressed: null,
                child: Text(AppTexts.confirm),
              );
      },
      child: ElevatedButton(
        onPressed: () {
          if (listOfSelectedUserBetOptionsValueNotifier.value.isNotEmpty &&
              amount.convertToNum >= 0.01 &&
              currentGameTimerValueNotifier.value > 15) {
            showAdaptiveDialog(
              context: context,
              builder: (context) {
                return AlertDialog.adaptive(
                  actions: [
                    Center(
                      child: OutlinedButton(
                        style: AppConfigs.outlinedButtonThemeData.style,
                        onPressed: () {
                          if (listOfSelectedUserBetOptionsValueNotifier
                                  .value.isNotEmpty &&
                              amount.convertToNum >= 0.01 &&
                              currentGameTimerValueNotifier.value > 15) {
                            context.readAppBloc.add(
                              CreateUserBetEvent(
                                coinType:
                                    context.readAppBloc.state.selectedCoinType,
                                afterUserBetCreated: () {
                                  changeCanChangeSelectedOptionsValueNotifier(
                                      canChange: false);
                                  onBetSubmitted();
                                  context.pop();
                                },
                                onError: () {
                                  // بستن confirmation dialog در صورت خطا
                                  context.pop();
                                },
                                amount: amount,
                                gameId: currentWebsocketServerModelValueNotifier
                                    .value.oneMinGame.id,
                                userChoices:
                                    listOfSelectedUserBetOptionsValueNotifier
                                        .value,
                              ),
                            );
                          } else {
                            TelegramWebApp.instance.showAlert(
                              AppTexts.pleaseCheckOneOfTheBelowToCreateBet,
                            );
                          }
                        },
                        child: const Text(
                          AppTexts.confirm,
                        ),
                      ),
                    ),
                  ],
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(AppTexts.confirm),
                      const Divider(),
                      const CustomSpaceWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(AppTexts.randomNo),
                          ValueListenableBuilder<WebsocketServerModel>(
                            valueListenable:
                                currentWebsocketServerModelValueNotifier,
                            builder: (context, currentWebsocket, _) {
                              return Text(
                                currentWebsocket.oneMinGame.eachGameUniqueNumber
                                    .toString(),
                              );
                            },
                          ),
                        ],
                      ),
                      const CustomSpaceWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(AppTexts.bettingOptions),
                          ValueListenableBuilder<List<UserBetOptions>>(
                            valueListenable:
                                listOfSelectedUserBetOptionsValueNotifier,
                            builder: (context, listOfUserBetOptions, _) {
                              return Text(
                                functions.convertListOfUserBetOptionsToString(
                                  listOfUserBetOptions: listOfUserBetOptions,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const CustomSpaceWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(AppTexts.amountPerOption),
                          ValueListenableBuilder<double>(
                            valueListenable: amountPerOptionsValueNotifier,
                            builder: (context, amountPerOptions, _) {
                              return Text(
                                amountPerOptions.toString(),
                              );
                            },
                          ),
                        ],
                      ),
                      const CustomSpaceWidget(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(AppTexts.totalAmount),
                          ValueListenableBuilder<double>(
                            valueListenable: amountPerOptionsValueNotifier,
                            builder: (context, amountPerOptions, _) {
                              return Text(
                                (amountPerOptions *
                                        listOfSelectedUserBetOptionsValueNotifier
                                            .value.length)
                                    .toString(),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            TelegramWebApp.instance.showAlert(
              AppTexts.pleaseCheckOneOfTheBelowToCreateBet,
            );
          }
        },
        child: const Text(AppTexts.confirm),
      ),
    );
  }
}
