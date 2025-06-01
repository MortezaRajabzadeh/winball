import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:level_repository/level_repository.dart';
import 'package:transaction_repository/transaction_repository.dart';
import 'package:user_bet_repository/user_bet_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball/bloc/app_bloc/app_bloc.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/utils/functions.dart';
import 'package:winball/widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final UserModel currentUser;
  late final AppBloc appBloc;
  late final ValueNotifier<bool> isLoadingLevelsValueNotifier;
  late final ValueNotifier<List<LevelModel>> listOfLevelsValueNotifier;
  late final LevelRepositoryFunctions levelRepositoryFunctions;
  late final UserBetRepositoryFunctions userBetRepositoryFunctions;
  late final TransactionRepositoryFunctions transactionRepositoryFunctions;
  late final Functions functions;
  late final ValueNotifier<bool> isAscendingOrder;
  
  // تابع برای فرمت بندی بهتر موجودی
  String formatInventory(String inventory) {
    // استفاده از متد getCoinAmountPerCoinType از functions برای فرمت یکسان با صفحه اصلی
    return functions.getCoinAmountPerCoinType(
      amount: inventory,
      coinType: CoinType.ton,
    );
  }
  
  Future<void> initializeDatas() async {
    functions = const Functions();
    levelRepositoryFunctions = const LevelRepositoryFunctions();
    isLoadingLevelsValueNotifier = ValueNotifier<bool>(true);
    listOfLevelsValueNotifier = ValueNotifier<List<LevelModel>>([]);
    isAscendingOrder = ValueNotifier<bool>(false);
    appBloc = context.readAppBloc;
    currentUser = appBloc.state.currentUser;
    userBetRepositoryFunctions = const UserBetRepositoryFunctions();
    transactionRepositoryFunctions = const TransactionRepositoryFunctions();
    changeListOfLevelsValueNotifier(
      levels: await levelRepositoryFunctions.getLevels(
        token: currentUser.token ?? '',
      ),
    );
    changeIsLoadingValueNotifier(isLoading: false);
  }

  void changeIsLoadingValueNotifier({bool? isLoading}) {
    isLoadingLevelsValueNotifier.value =
        isLoading ?? !isLoadingLevelsValueNotifier.value;
  }

  void changeListOfLevelsValueNotifier({required List<LevelModel> levels}) {
    listOfLevelsValueNotifier.value = levels;
  }

  void dispositionalDatas() {
    isLoadingLevelsValueNotifier.dispose();
    listOfLevelsValueNotifier.dispose();
    isAscendingOrder.dispose();
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
    // برای تعیین اندازه مناسب نسبت به صفحه
    final Size screenSize = MediaQuery.of(context).size;
    final double iconSize = screenSize.width * 0.05; // سایز استاندارد آیکون‌ها
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          AppTexts.profile,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              size: iconSize,
            ),
            onPressed: context.pop,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConfigs.mediumVisualDensity,
        ),
        child: Column(
          children: [
            // شناسه کاربر با آیکون متناسب
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(
                horizontal: 16, 
                vertical: 8
              ),
              decoration: BoxDecoration(
                color: AppConfigs.appShadowColor,
                borderRadius: BorderRadius.circular(AppConfigs.mediumVisualDensity),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    AppTexts.id,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  SelectableText(
                    currentUser.username ?? currentUser.userUniqueNumber,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      size: iconSize,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: currentUser.username ??
                              currentUser.userUniqueNumber,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const CustomSpaceWidget(),
            const SizedBox(height: 16),
            Row(
              children: [
                // آواتار با اندازه متناسب با صفحه
                Expanded(
                  child: CircleAvatar(
                    radius: screenSize.width * 0.1, // اندازه متناسب با عرض صفحه
                    backgroundImage: currentUser.userProfile == null ||
                            (currentUser.userProfile ?? '').isEmpty
                        ? const AssetImage(
                            AppConfigs.userProfilePicture,
                          )
                        : NetworkImage(
                            '${BaseConfigs.serveImage}${currentUser.userProfile}'),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppConfigs.appShadowColor,
                      borderRadius: BorderRadius.circular(
                        AppConfigs.largeVisualDensity,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isLoadingLevelsValueNotifier,
                        builder: (context, isLoading, child) {
                          return isLoading ? const LoadingWidget() : child!;
                        },
                        child: ValueListenableBuilder<List<LevelModel>>(
                          valueListenable: listOfLevelsValueNotifier,
                          builder: (context, levels, _) {
                            return Column(
                              children: [
                                LinearProgressIndicator(
                                  value: currentUser.levelId / levels.length,
                                  backgroundColor:
                                      AppConfigs.appBackgroundColor,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      currentUser.level.levelTag,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '${currentUser.levelId}/${levels.length} XP',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const CustomSpaceWidget(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16, 
                vertical: 12
              ),
              decoration: BoxDecoration(
                color: AppConfigs.appShadowColor,
                borderRadius: BorderRadius.circular(AppConfigs.mediumVisualDensity),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppTexts.walletBalance,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "${formatInventory(currentUser.tonInventory)} TON",
                    style: const TextStyle(
                      color: AppConfigs.greenColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 4.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  AppTexts.balanceDecimalPlaces,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppTexts.withdrawalsCount,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  FutureBuilder<List<TransactionModel>>(
                    future: transactionRepositoryFunctions.getTransactionsByCreatorId(
                      token: currentUser.token ?? '',
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 20, 
                          height: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      } else if (snapshot.hasData) {
                        // فیلتر کردن تراکنش‌های برداشت
                        final withdrawTransactions = snapshot.data!
                            .where((tx) => tx.transactionType == TransactionType.withdraw)
                            .toList();
                        
                        return Text(
                          "${withdrawTransactions.length}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      } else {
                        return const Text("0");
                      }
                    },
                  ),
                ],
              ),
            ),
            const CustomSpaceWidget(),
            const SizedBox(height: 24),
            // بخش آمار با استایل استاندارد
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ListTile(
                leading: Icon(
                  Icons.insert_chart_outlined_outlined,
                  size: iconSize * 1.2,
                  color: AppConfigs.yellowColor,
                ),
                title: const Text(
                  AppTexts.statistics,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // باکس آمار بردها - سمت چپ
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConfigs.mediumVisualDensity,
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
                          horizontal: AppConfigs.minVisualDensity,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const ListTile(
                              leading: Icon(
                                Icons.emoji_events,
                                color: AppConfigs.yellowColor,
                                size: 28,
                              ),
                              title: Text(
                                AppTexts.totalWins,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const CustomSpaceWidget(),
                            FutureBuilder<int>(
                              future: userBetRepositoryFunctions
                                  .getUserTotalWinsCount(
                                token: currentUser.token ?? '',
                              ),
                              builder: (
                                context,
                                snapshot,
                              ) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const LoadingWidget();
                                } else if (snapshot.hasData &&
                                    snapshot.data != null) {
                                  int winCount = snapshot.data ?? 0;
                                  
                                  return SizedBox(
                                    height: 40,
                                    child: Text(
                                      "$winCount",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: AppConfigs.yellowColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
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
                      ),
                    ),
                  ),
                ),
                // باکس موجودی کیف پول - سمت راست
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConfigs.mediumVisualDensity,
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
                          horizontal: AppConfigs.minVisualDensity,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const ListTile(
                              leading: Icon(
                                Icons.account_balance_wallet,
                                color: AppConfigs.greenColor,
                                size: 28,
                              ),
                              title: Text(
                                AppTexts.wallet,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const CustomSpaceWidget(),
                            SizedBox(
                              height: 40,
                              child: Text(
                                "${formatInventory(currentUser.tonInventory)} TON",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: AppConfigs.greenColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const CustomSpaceWidget(
              size: AppConfigs.largeVisualDensity,
            ),
            const SizedBox(height: 32),
            // بخش تاریخچه تراکنش‌ها
            const Text(
              AppTexts.transactionHistory,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: FutureBuilder<List<TransactionModel>>(
                future:
                    transactionRepositoryFunctions.getTransactionsByCreatorId(
                  token: currentUser.token ?? '',
                ),
                builder:
                    (context, AsyncSnapshot<List<TransactionModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingWidget();
                  } else if (snapshot.hasError) {
                    return CustomErrorWidget(
                      error: snapshot.error.toString(),
                    );
                  } else if (snapshot.hasData &&
                      snapshot.data != null &&
                      (snapshot.data?.isNotEmpty ?? false)) {
                    final List<TransactionModel> transactions =
                        snapshot.data as List<TransactionModel>;
                    
                    // محاسبه مجموع تراکنش‌های موفق
                    double totalSuccessfulTransactions = 0;
                    for (final transaction in transactions) {
                      if (transaction.transactionStatus == TransactionStatus.success) {
                        totalSuccessfulTransactions += double.parse(
                          functions.getCoinAmountPerCoinType(
                            amount: transaction.amount,
                            coinType: transaction.coinType
                          )
                        );
                      }
                    }
                    
                    return ValueListenableBuilder<bool>(
                      valueListenable: isAscendingOrder,
                      builder: (context, isAscending, _) {
                        // مرتب‌سازی تراکنش‌ها بر اساس تاریخ
                        final sortedTransactions = List<TransactionModel>.from(transactions);
                        sortedTransactions.sort((a, b) {
                          return isAscending 
                            ? a.createdAt.compareTo(b.createdAt)
                            : b.createdAt.compareTo(a.createdAt);
                        });
                        
                        return Column(
                          children: [
                            // نمایش مجموع تراکنش‌های موفق
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${AppTexts.totalSuccessful}: ${totalSuccessfulTransactions.toStringAsFixed(3)}',
                                    style: const TextStyle(
                                      color: AppConfigs.greenColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // دکمه تغییر ترتیب مرتب‌سازی
                                  InkWell(
                                    onTap: () {
                                      isAscendingOrder.value = !isAscendingOrder.value;
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          isAscending ? AppTexts.newest : AppTexts.oldest,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(
                                          isAscending
                                              ? Icons.arrow_upward
                                              : Icons.arrow_downward,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // هدر جدول
                            Container(
                              decoration: BoxDecoration(
                                color: AppConfigs.appShadowColor,
                                borderRadius: BorderRadius.circular(
                                  AppConfigs.mediumVisualDensity,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: AppConfigs.mediumVisualDensity,
                                horizontal: AppConfigs.largeVisualDensity,
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  // برای صفحه‌های کوچک
                                  if (constraints.maxWidth < 340) {
                                    return Column(
                                      children: const [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppTexts.action,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              AppTexts.amount,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppTexts.status,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              AppTexts.date,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }
                                  
                                  // برای صفحه‌های بزرگتر
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          AppTexts.action,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          AppTexts.amount,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          AppTexts.status,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          AppTexts.date,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              ),
                            ),
                            const CustomSpaceWidget(),
                            // لیست تراکنش‌ها
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: sortedTransactions.length,
                              itemBuilder: (context, index) {
                                final TransactionModel transactionModel =
                                    sortedTransactions[index];
                                    
                                // تعیین رنگ براساس وضعیت تراکنش
                                Color statusColor;
                                switch (transactionModel.transactionStatus) {
                                  case TransactionStatus.success:
                                    statusColor = AppConfigs.greenColor;
                                    break;
                                  case TransactionStatus.failed:
                                    statusColor = AppConfigs.redColor;
                                    break;
                                  case TransactionStatus.pending:
                                    statusColor = AppConfigs.yellowColor;
                                    break;
                                  default:
                                    statusColor = Colors.white;
                                }
                                
                                // بررسی اگر رفرال است
                                final bool isReferral = 
                                  transactionModel.transactionType == TransactionType.deposit && 
                                  (transactionModel.moreInfo?.toLowerCase().contains('referal') ?? false);
                                
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      // برای صفحه‌های کوچک
                                      if (constraints.maxWidth < 340) {
                                        return Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  isReferral ? "referral" : transactionModel.transactionType.name,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isReferral ? Colors.purple[300] : Colors.white,
                                                    fontWeight: isReferral ? FontWeight.bold : FontWeight.normal,
                                                  ),
                                                ),
                                                Text(
                                                  functions.getCoinAmountPerCoinType(
                                                    amount: transactionModel.amount,
                                                    coinType: transactionModel.coinType
                                                  ),
                                                  style: const TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  transactionModel.transactionStatus.name,
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  functions.convertDateTimeToDateAndTime(
                                                    dateTime: transactionModel.createdAt
                                                  ),
                                                  style: const TextStyle(fontSize: 13),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              color: Colors.white24,
                                            ),
                                          ],
                                        );
                                      }
                                      
                                      // برای صفحه‌های بزرگتر
                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  isReferral ? "referral" : transactionModel.transactionType.name,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isReferral ? Colors.purple[300] : Colors.white,
                                                    fontWeight: isReferral ? FontWeight.bold : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  functions.getCoinAmountPerCoinType(
                                                    amount: transactionModel.amount,
                                                    coinType: transactionModel.coinType
                                                  ),
                                                  style: const TextStyle(fontSize: 14),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  transactionModel.transactionStatus.name,
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  functions.convertDateTimeToDateAndTime(
                                                    dateTime: transactionModel.createdAt
                                                  ),
                                                  style: const TextStyle(fontSize: 13),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(
                                            color: Colors.white24,
                                          ),
                                        ],
                                      );
                                    }
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // حالت خالی بودن تراکنش‌ها
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined, 
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No transactions found",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


