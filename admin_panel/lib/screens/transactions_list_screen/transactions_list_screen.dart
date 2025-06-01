import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:transaction_repository/transaction_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/extensions/extensions.dart';
import 'package:winball_admin_panel/utils/functions.dart';
import 'package:winball_admin_panel/widgets/global/custom_error_widget.dart';
import 'package:winball_admin_panel/widgets/global/loading_widget.dart';

class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({
    super.key,
    required this.userId,
  });
  final int userId;
  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  late final TransactionRepositoryFunctions transactionRepositoryFunctions;
  late final Functions functions;
  late final UserModel currentUser;
  void initializeDatas() {
    functions = const Functions();
    transactionRepositoryFunctions = const TransactionRepositoryFunctions();
    currentUser = context.readAppBloc.state.currentUser;
  }

  void dispositionalDatas() {}
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
        title: const Text(
          AppTexts.transactionsList,
        ),
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: transactionRepositoryFunctions.getTransactionsByUserId(
          userId: widget.userId,
          token: currentUser.token ?? '',
        ),
        builder: (context, AsyncSnapshot<List<TransactionModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          } else if (snapshot.hasData &&
              snapshot.data != null &&
              (snapshot.data ?? []).isNotEmpty) {
            final List<TransactionModel> transactions = snapshot.data ?? [];
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          '${AppTexts.wholeDepositAmount}  ${functions.getWholeTonAmountWithListOfTransactions(transactions: transactions.where((t) => t.transactionType == TransactionType.deposit).toList()).toStringAsFixed(2)} (${AppTexts.ton})'),
                    ),
                    Expanded(
                        child: Text(
                            '${AppTexts.wholeWithdrawAmount} ${functions.getWholeTonAmountWithListOfTransactions(transactions: transactions.where((t) => t.transactionType == TransactionType.withdraw).toList()).toStringAsFixed(2)} (${AppTexts.ton})')),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final TransactionModel transactionModel =
                          transactions[index];
                      return ListTile(
                        trailing: Tooltip(
                          message:
                              '${AppTexts.coinType} ${transactionModel.coinType.name}',
                          child: Icon(
                            transactionModel.coinType == CoinType.stars
                                ? Icons.star
                                : Icons.attach_money,
                          ),
                        ),
                        title: Text(
                          '${AppTexts.amount} ${((double.tryParse(transactionModel.amount) ?? 0) / AppConfigs.tonBaseFactory).toStringAsFixed(2)}',
                        ),
                        leading: Tooltip(
                          message: transactionModel.transactionType ==
                                  TransactionType.deposit
                              ? AppTexts.deposit
                              : AppTexts.withdraw,
                          child: Icon(
                            transactionModel.transactionType ==
                                    TransactionType.deposit
                                ? Icons.arrow_drop_down
                                : Icons.arrow_drop_up,
                            color: transactionModel.transactionStatus ==
                                    TransactionStatus.faild
                                ? AppConfigs.redColor
                                : transactionModel.transactionStatus ==
                                        TransactionStatus.pending
                                    ? AppConfigs.yellowColor
                                    : AppConfigs.greenColor,
                          ),
                        ),
                        subtitle: SelectableText(
                            '${AppTexts.transactionId} ${transactionModel.transactionId} - ${AppTexts.dateTime} ${functions.convertDateTimeToDateAndTime(dateTime: transactionModel.createdAt)} - ${AppTexts.userId}${transactionModel.creator.userUniqueNumber}'),
                      );
                    },
                  ),
                ),
              ],
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
    );
  }
}
