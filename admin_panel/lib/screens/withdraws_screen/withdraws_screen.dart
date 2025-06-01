import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_repository/transaction_repository.dart';
import 'package:winball_admin_panel/bloc/app_bloc/app_bloc.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/widgets/global/custom_error_widget.dart';
import 'package:winball_admin_panel/widgets/global/loading_widget.dart';
import 'package:withdraw_repository/withdraw_repository.dart';

class WithdrawsScreen extends StatefulWidget {
  const WithdrawsScreen({super.key});

  @override
  State<WithdrawsScreen> createState() => _WithdrawsScreenState();
}

class _WithdrawsScreenState extends State<WithdrawsScreen> {
  bool hasMoreData = true;
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final ValueNotifier<List<WithdrawModel>> withdrawsValueNotifier;
  late final WithdrawRepositoryFunctions withdrawsRepositoryFunctions;
  late final ValueNotifier<WithdrawStatus> withdrawStatusValueNotifier;
  late final ScrollController scrollController;
  int page = 1;
  Future<void> initializeDatas() async {
    scrollController = ScrollController();
    scrollController.addListener(scrollControllerListener);
    withdrawStatusValueNotifier = ValueNotifier<WithdrawStatus>(
      WithdrawStatus.faild,
    );
    isLoadingValueNotifier = ValueNotifier<bool>(true);
    withdrawsValueNotifier = ValueNotifier<List<WithdrawModel>>([]);
    withdrawsRepositoryFunctions = const WithdrawRepositoryFunctions();
    await loadWithdrawsByStatus();
  }

  Future<void> loadWithdrawsByStatus() async {
    if (hasMoreData) {
      final AppBloc appBloc = BlocProvider.of<AppBloc>(context);
      try {
        if (withdrawsValueNotifier.value.isNotEmpty) {
          if (withdrawsValueNotifier.value.first.status !=
              withdrawStatusValueNotifier.value) {
            page = 1;
          }
        }
        changeIsLoadingValueNotifier(isLoading: true);
        final List<WithdrawModel> withdraws =
            await withdrawsRepositoryFunctions.getWithDrawsByStatusAndPage(
          status: withdrawStatusValueNotifier.value,
          token: BlocProvider.of<AppBloc>(context).state.currentUser.token ?? '',
          page: page,
        );
        hasMoreData = withdraws.isNotEmpty;
        page++;
        if (withdrawsValueNotifier.value.isNotEmpty) {
          if (withdrawsValueNotifier.value.first.status !=
              withdrawStatusValueNotifier.value) {
            changeWithdrawsValueNotifier(
              withdraws: withdraws,
            );
          }
        } else {
          addWithdrawsListToWithdrawsValueNotifier(
            withdraws: withdraws,
          );
        }
        changeIsLoadingValueNotifier(isLoading: false);
      } catch (e) {
        appBloc.addError(e);
      }
    }
  }

  void addWithdrawsListToWithdrawsValueNotifier(
      {required List<WithdrawModel> withdraws}) {
    final List<WithdrawModel> withdrawList = withdrawsValueNotifier.value;
    changeWithdrawsValueNotifier(
      withdraws: [],
    );
    withdrawList.addAll(withdraws);
    changeWithdrawsValueNotifier(withdraws: withdrawList);
  }

  void changeIsLoadingValueNotifier({bool? isLoading}) {
    isLoadingValueNotifier.value = isLoading ?? !isLoadingValueNotifier.value;
  }

  void changeWithdrawsValueNotifier({
    required List<WithdrawModel> withdraws,
  }) {
    withdrawsValueNotifier.value = withdraws;
  }

  void changeWithdrawStatusValueNotifier({required WithdrawStatus status}) {
    page = 1;
    hasMoreData = true;
    withdrawStatusValueNotifier.value = status;
    loadWithdrawsByStatus();
  }

  void scrollControllerListener() {
    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      loadWithdrawsByStatus();
    }
  }

  void removeWithdrawFromList({required int withdrawId}) {
    final List<WithdrawModel> withdraws = withdrawsValueNotifier.value;
    changeWithdrawsValueNotifier(withdraws: []);
    withdraws.removeWhere((e) => e.id == withdrawId);
    changeWithdrawsValueNotifier(withdraws: withdraws);
  }

  void dispositionalDatas() {
    scrollController.removeListener(scrollControllerListener);
    scrollController.dispose();
    withdrawStatusValueNotifier.dispose();
    isLoadingValueNotifier.dispose();
    withdrawsValueNotifier.dispose();
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
      body: Column(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<WithdrawStatus>(
                valueListenable: withdrawStatusValueNotifier,
                builder: (context, status, _) {
                  return Row(
                    children: [
                      const Text(AppTexts.transactionStatus),
                      Expanded(
                        child: RadioListTile.adaptive(
                          value: WithdrawStatus.faild,
                          title: Text(TransactionStatus.faild.name),
                          groupValue: status,
                          onChanged: (selected) {
                            changeWithdrawStatusValueNotifier(
                              status: WithdrawStatus.faild,
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile.adaptive(
                          value: WithdrawStatus.pending,
                          title: Text(WithdrawStatus.pending.name),
                          groupValue: status,
                          onChanged: (selected) {
                            changeWithdrawStatusValueNotifier(
                                status: WithdrawStatus.pending);
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile.adaptive(
                          value: WithdrawStatus.success,
                          title: Text(WithdrawStatus.success.name),
                          groupValue: status,
                          onChanged: (selected) {
                            changeWithdrawStatusValueNotifier(
                                status: WithdrawStatus.success);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: isLoadingValueNotifier,
              builder: (context, isLoading, child) {
                return isLoading ? const LoadingWidget() : child!;
              },
              child: ValueListenableBuilder<List<WithdrawModel>>(
                valueListenable: withdrawsValueNotifier,
                builder: (context, withdraws, _) {
                  return withdraws.isEmpty
                      ? const CustomErrorWidget()
                      : ListView.builder(
                          shrinkWrap: true,
                          controller: scrollController,
                          itemCount: withdraws.length,
                          itemBuilder: (context, index) {
                            final WithdrawModel withdrawModel =
                                withdraws[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 4.0, 
                                horizontal: 8.0
                              ),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Amount: ${((double.tryParse(withdrawModel.amount) ?? 0) / AppConfigs.tonBaseFactory).toStringAsFixed(3)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'User: ${withdrawModel.creator.firstname ?? ''} ${withdrawModel.creator.lastname ?? ''} ${withdrawModel.creator.username ?? 'Unknown'}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8, 
                                            vertical: 4
                                          ),
                                          decoration: BoxDecoration(
                                            color: withdrawModel.status == WithdrawStatus.pending 
                                                ? AppConfigs.yellowColor
                                                : withdrawModel.status == WithdrawStatus.success
                                                    ? AppConfigs.greenColor
                                                    : AppConfigs.redColor,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            withdrawModel.status.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'ID: ${withdrawModel.creator.userUniqueNumber}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            GestureDetector(
                                              onTap: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text: withdrawModel.creator.userUniqueNumber,
                                                  ),
                                                );
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('User ID copied'),
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                              },
                                              child: const Icon(
                                                Icons.copy,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                      'Coin Type: ${withdrawModel.coinType == CoinType.stars ? AppTexts.stars : withdrawModel.coinType.name}',
                                    ),
                                    Text(
                                      'Wallet Address: ${withdrawModel.walletAddress}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'Date: ${withdrawModel.createdAt.toString().split('.')[0]}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: withdraws.first.status == WithdrawStatus.pending
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.copy),
                                            tooltip: AppTexts.copyWalletAddress,
                                            onPressed: () {
                                              Clipboard.setData(
                                                ClipboardData(
                                                  text: withdrawModel.walletAddress,
                                                ),
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Wallet address copied'),
                                                  duration: Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            style: const ButtonStyle(
                                              iconColor: WidgetStatePropertyAll(
                                                AppConfigs.greenColor,
                                              ),
                                            ),
                                            tooltip: AppTexts.paid,
                                            onPressed: () async {
                                              try {
                                                final bool success = await withdrawsRepositoryFunctions.changeWithdrawStatus(
                                                  status: WithdrawStatus.success,
                                                  withdrawId: withdrawModel.id,
                                                  token: BlocProvider.of<AppBloc>(context).state.currentUser.token ?? '',
                                                );
                                                
                                                if (success) {
                                                  removeWithdrawFromList(withdrawId: withdrawModel.id);
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Error confirming withdrawal. Please check wallet balance.'),
                                                      backgroundColor: AppConfigs.redColor,
                                                      duration: Duration(seconds: 5),
                                                    ),
                                                  );
                                                }
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error: ${e.toString()}'),
                                                    backgroundColor: AppConfigs.redColor,
                                                    duration: const Duration(seconds: 5),
                                                  ),
                                                );
                                                context.read<AppBloc>().addError(e);
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.done,
                                            ),
                                          ),
                                          IconButton(
                                            style: const ButtonStyle(
                                              iconColor: WidgetStatePropertyAll(
                                                AppConfigs.redColor,
                                              ),
                                            ),
                                            tooltip: AppTexts.rejected,
                                            onPressed: () {
                                              context.read<AppBloc>().add(
                                                RejectWithdrawEvent(
                                                  withdrawId: withdrawModel.id,
                                                  removeWithdrawFromList: removeWithdrawFromList,
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.close,
                                            ),
                                          ),
                                        ],
                                      )
                                    : null,
                              ),
                            );
                          },
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
