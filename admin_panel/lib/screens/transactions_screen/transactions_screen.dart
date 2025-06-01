import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:transaction_repository/transaction_repository.dart';
import 'package:winball_admin_panel/bloc/app_bloc/app_bloc.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/extensions/extensions.dart';
import 'package:winball_admin_panel/widgets/global/custom_error_widget.dart';
import 'package:winball_admin_panel/widgets/global/loading_widget.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool hasMoreData = true;
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final ValueNotifier<List<TransactionModel>> transactionsValueNotifier;
  late final TransactionRepositoryFunctions transactionRepositoryFunctions;
  late final ValueNotifier<TransactionType> transactionTypeValueNotifier;
  late final ValueNotifier<TransactionStatus> transactionStatusValueNotifier;
  late final ScrollController scrollController;
  int page = 1;
  Future<void> initializeDatas() async {
    scrollController = ScrollController();
    scrollController.addListener(scrollControllerListener);
    transactionTypeValueNotifier = ValueNotifier<TransactionType>(
      TransactionType.withdraw,
    );
    transactionStatusValueNotifier = ValueNotifier<TransactionStatus>(
      TransactionStatus.faild,
    );
    isLoadingValueNotifier = ValueNotifier<bool>(true);
    transactionsValueNotifier = ValueNotifier<List<TransactionModel>>([]);
    transactionRepositoryFunctions = const TransactionRepositoryFunctions();
    await loadTransactionByTransactionTypeAndTransactionStatusAndPage();
  }

  Future<void>
      loadTransactionByTransactionTypeAndTransactionStatusAndPage() async {
    if (hasMoreData) {
      final AppBloc appBloc = context.readAppBloc;
      try {
        if (transactionsValueNotifier.value.isNotEmpty) {
          if (transactionsValueNotifier.value.first.transactionType !=
                  transactionTypeValueNotifier.value ||
              transactionsValueNotifier.value.first.transactionStatus !=
                  transactionStatusValueNotifier.value) {
            page = 1;
          }
        }
        changeIsLoadingValueNotifier(isLoading: true);
        final List<TransactionModel> transactions =
            await transactionRepositoryFunctions
                .getTransactionsByTransactionTypeAndStatusAndPage(
          transactionType: transactionTypeValueNotifier.value,
          status: transactionStatusValueNotifier.value,
          token: appBloc.state.currentUser.token ?? '',
          page: page,
        );
        hasMoreData = transactions.isNotEmpty;
        page++;
        if (transactionsValueNotifier.value.isNotEmpty) {
          if (transactionsValueNotifier.value.first.transactionType !=
                  transactionTypeValueNotifier.value ||
              transactionsValueNotifier.value.first.transactionStatus !=
                  transactionStatusValueNotifier.value) {
            changeTransactionsValueNotifier(
              transactions: transactions,
            );
          }
        } else {
          addTransactionsListToTransactionsValueNotifier(
            transactions: transactions,
          );
        }
        changeIsLoadingValueNotifier(isLoading: false);
      } catch (e) {
        appBloc.addError(e);
      }
    }
  }

  void addTransactionsListToTransactionsValueNotifier(
      {required List<TransactionModel> transactions}) {
    final List<TransactionModel> transactionList =
        transactionsValueNotifier.value;
    changeTransactionsValueNotifier(
      transactions: [],
    );
    transactionList.addAll(transactions);
    changeTransactionsValueNotifier(transactions: transactionList);
  }

  void changeIsLoadingValueNotifier({bool? isLoading}) {
    isLoadingValueNotifier.value = isLoading ?? !isLoadingValueNotifier.value;
  }

  void changeTransactionsValueNotifier({
    required List<TransactionModel> transactions,
  }) {
    transactionsValueNotifier.value = transactions;
  }

  void changeTransactionStatusValueNotifier(
      {required TransactionStatus status}) {
    page = 1;
    hasMoreData = true;
    transactionStatusValueNotifier.value = status;
    loadTransactionByTransactionTypeAndTransactionStatusAndPage();
  }

  void changeTransactionTypeValueNotifier(
      {required TransactionType transactionType}) {
    page = 1;
    hasMoreData = true;
    transactionTypeValueNotifier.value = transactionType;
    loadTransactionByTransactionTypeAndTransactionStatusAndPage();
  }

  void scrollControllerListener() {
    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      loadTransactionByTransactionTypeAndTransactionStatusAndPage();
    }
  }

  void dispositionalDatas() {
    scrollController.removeListener(scrollControllerListener);
    scrollController.dispose();
    transactionTypeValueNotifier.dispose();
    transactionStatusValueNotifier.dispose();
    isLoadingValueNotifier.dispose();
    transactionsValueNotifier.dispose();
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
              ValueListenableBuilder<TransactionStatus>(
                valueListenable: transactionStatusValueNotifier,
                builder: (context, status, _) {
                  return Row(
                    children: [
                      const Text(AppTexts.transactionStatus),
                      Expanded(
                        child: RadioListTile.adaptive(
                          value: TransactionStatus.faild,
                          title: Text(TransactionStatus.faild.name),
                          groupValue: status,
                          onChanged: (selected) {
                            changeTransactionStatusValueNotifier(
                              status: TransactionStatus.faild,
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile.adaptive(
                          value: TransactionStatus.pending,
                          title: Text(TransactionStatus.pending.name),
                          groupValue: status,
                          onChanged: (selected) {
                            changeTransactionStatusValueNotifier(
                                status: TransactionStatus.pending);
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile.adaptive(
                          value: TransactionStatus.success,
                          title: Text(TransactionStatus.success.name),
                          groupValue: status,
                          onChanged: (selected) {
                            changeTransactionStatusValueNotifier(
                              status: TransactionStatus.success,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              ValueListenableBuilder<TransactionType>(
                valueListenable: transactionTypeValueNotifier,
                builder: (context, transactionType, _) {
                  return Row(
                    children: [
                      const Text(AppTexts.transactionType),
                      Expanded(
                        child: RadioListTile.adaptive(
                          value: TransactionType.deposit,
                          title: Text(TransactionType.deposit.name),
                          groupValue: transactionType,
                          onChanged: (selected) {
                            changeTransactionTypeValueNotifier(
                              transactionType: TransactionType.deposit,
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile.adaptive(
                          value: TransactionType.withdraw,
                          title: Text(TransactionType.withdraw.name),
                          groupValue: transactionType,
                          onChanged: (selected) {
                            changeTransactionTypeValueNotifier(
                              transactionType: TransactionType.withdraw,
                            );
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
              child: ValueListenableBuilder<List<TransactionModel>>(
                valueListenable: transactionsValueNotifier,
                builder: (context, transactions, _) {
                  return transactions.isEmpty
                      ? const CustomErrorWidget()
                      : ListView.builder(
                          shrinkWrap: true,
                          controller: scrollController,
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final TransactionModel transactionModel =
                                transactions[index];
                            final TextStyle style =
                                transactionModel.transactionType ==
                                        TransactionType.withdraw
                                    ? AppConfigs.redTextStyle
                                    : AppConfigs.greenTextStyle;
                            final double tonTransactionAmount =
                                double.tryParse(transactionModel.amount) ?? 0;
                            return ListTile(
                              title: Text(
                                transactionModel.coinType == CoinType.ton
                                    ? '${tonTransactionAmount / AppConfigs.tonBaseFactory}'
                                    : transactionModel.amount,
                                style: style,
                              ),
                              subtitle: SelectableText(
                                '${AppTexts.userId}${transactionModel.creator.userUniqueNumber}',
                                style: style,
                              ),
                              trailing: Text(
                                transactionModel.transactionStatus.name,
                                style: style,
                              ),
                              leading: Text(
                                transactionModel.transactionType.name,
                                style: style,
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
