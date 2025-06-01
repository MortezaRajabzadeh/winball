import 'dart:async';
import 'dart:convert';

import 'package:base_repository/base_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invitation_repository/invitation_repository.dart';
import 'package:network_repository/network_repository.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:site_settings_repository/site_settings_repository.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:transaction_repository/transaction_repository.dart';
import 'package:user_bet_repository/user_bet_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/models/dialog_model.dart';
import 'package:withdraw_repository/withdraw_repository.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  late final StreamController<DialogModel> dialogStreamController;
  late final UserRepositoryFunctions userRepositoryFunctions;
  late final UserBetRepositoryFunctions userBetRepositoryFunctions;
  late final SiteSettingRepositoryFunctions siteSettingRepositoryFunctions;
  // late final DatabaseRepositoryFunctions databaseRepositoryFunctions;
  late final WithdrawRepositoryFunctions withdrawRepositoryFunctions;
  late final TransactionRepositoryFunctions transactionRepositoryFunctions;
  late final InvitationRepositoryFunctions invitationRepositoryFunctions;
  static final AppBloc _shared = AppBloc._internal();
  factory AppBloc() => _shared;
  AppBloc._internal()
      : super(InitializingState.initializing(
          selectedCoinType: CoinType.ton,
          currentUser: UserModel.empty,
          siteSettingModel: SiteSettingModel.empty,
        )) {
    on<LoginRegisterEvent>(_onLoginRegisterEvent);
    on<UpdateUserEvent>(_onUpdateUserEvent);
    on<CreateUserBetEvent>(_onCreateUserBetEvent);
    on<UpdateUserInventoryEvent>(_onUpdateUserInventoryEvent);
    on<CheckTonTransactionEvent>(_onCheckTonTransactionEvent);
    on<ChangeSelectedCoinTypeEvent>(_onChangeSelectedCoinTypeEvent);
    on<CreateWithdrawEvent>(_onCreateWithdrawEvent);
    on<GetStarsPaymentEvent>(_onGetStarsPaymentEvent);
    on<CreateInvitationEvent>(_onCreateInvitationEvent);
    transactionRepositoryFunctions = const TransactionRepositoryFunctions();
    dialogStreamController = StreamController<DialogModel>.broadcast();
    userRepositoryFunctions = const UserRepositoryFunctions();
    userBetRepositoryFunctions = const UserBetRepositoryFunctions();
    siteSettingRepositoryFunctions = const SiteSettingRepositoryFunctions();
    // databaseRepositoryFunctions = const DatabaseRepositoryFunctions();
    withdrawRepositoryFunctions = const WithdrawRepositoryFunctions();
    invitationRepositoryFunctions = const InvitationRepositoryFunctions();
  }
  Future<void> _onCreateInvitationEvent(
    CreateInvitationEvent event,
    Emitter<AppState> emit,
  ) async {
    try {
      await invitationRepositoryFunctions.createInvitation(
        invitationCode: event.invitationCode,
        invitedId: event.invitedId,
      );
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onGetStarsPaymentEvent(
      GetStarsPaymentEvent event, Emitter<AppState> emit) async {
    try {
      if (event.amount.isNotEmpty) {
        final String paymentLink =
            await transactionRepositoryFunctions.getStarsPaymentLink(
          amount: event.amount,
          creatorId: state.currentUser.id.toString(),
        );
        if (paymentLink.isNotEmpty) {
          TelegramWebApp.instance.openInvoice(
            paymentLink,
            (InvoiceStatus status) {
              if (status == InvoiceStatus.paid) {
                showErrorDialog(
                  error: AppTexts.starsPaidSuccessfully,
                  title: AppTexts.paymentInfo,
                );
              }
            },
          );
        }
      } else {
        addError(
          AppTexts.amountIsRequired,
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onCreateWithdrawEvent(
      CreateWithdrawEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final WithdrawModel withdraw =
          await withdrawRepositoryFunctions.createWithdraw(
        amount: event.amount,
        address: event.address,
        coinType: event.coinType,
        token: state.currentUser.token ?? '',
      );
      closeDialog();
      if (withdraw.id > 0) {
        showErrorDialog(
          error: AppTexts.withdrawCreated,
          title: AppTexts.message,
        );
        final UserModel currentUser = state.currentUser;
        final double newUserTon =
            ((double.tryParse(currentUser.tonInventory) ?? 0)) -
                (double.tryParse(withdraw.amount) ?? 0);
        final UserModel newUserModelWithNewTon = currentUser.copyWith(
          tonInventory: newUserTon.toString(),
          token: currentUser.token,
        );
        emit(
          state.copyWith(
            currentUser: newUserModelWithNewTon,
          ),
        );
      }
    } catch (e) {
      addError(e);
    }
  }

  void _onChangeSelectedCoinTypeEvent(
      ChangeSelectedCoinTypeEvent event, Emitter<AppState> emit) {
    emit(
      state.copyWith(
        selectedCoinType: event.coinType,
      ),
    );
  }

  Future<void> _onCheckTonTransactionEvent(
      CheckTonTransactionEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      await checkTonTransaction(
        token: state.currentUser.token ?? '',
      );
      closeDialog();
      add(const UpdateUserEvent());
    } catch (e) {
      addError(e);
    }
  }

  void _onUpdateUserInventoryEvent(
    UpdateUserInventoryEvent event,
    Emitter<AppState> emit,
  ) {
    final UserModel currentUser = state.currentUser;
    String inventory = '0.0';
    switch (event.coinType) {
      case CoinType.ton:
        inventory = currentUser.tonInventory;
        inventory = (inventory.convertToNum.toDouble() +
                (event.inventory * AppConfigs.tonBaseFactor))
            .toString();
        final UserModel updatedUser = currentUser.copyWith(
          tonInventory: inventory,
          token: currentUser.token,
        );
        emit(
          state.copyWith(
            currentUser: updatedUser,
          ),
        );
      case CoinType.stars:
        inventory = currentUser.starsInventory;
        inventory =
            (inventory.convertToNum.toDouble() + event.inventory).toString();
        final UserModel updatedUser = currentUser.copyWith(
          starsInventory: inventory,
          token: currentUser.token,
        );
        emit(
          state.copyWith(
            currentUser: updatedUser,
          ),
        );
      // case CoinType.usdt:
      //   inventory = currentUser.usdtInventory;
      //   inventory =
      //       (inventory.convertToNum.toDouble() + event.inventory).toString();
      //   final UserModel updatedUser = currentUser.copyWith(
      //     tonInventory: inventory,
      //   );
      //   emit(
      //     state.copyWith(
      //       currentUser: updatedUser,
      //     ),
      //   );
      // case CoinType.btc:
      //   inventory = currentUser.btcInventory;
      //   inventory =
      //       (inventory.convertToNum.toDouble() + event.inventory).toString();
      //   final UserModel updatedUser = currentUser.copyWith(
      //     tonInventory: inventory,
      //   );
      //   emit(
      //     state.copyWith(
      //       currentUser: updatedUser,
      //     ),
      //   );
      // case CoinType.cusd:
      //   inventory = currentUser.cusdInventory;
      //   inventory =
      //       (inventory.convertToNum.toDouble() + event.inventory).toString();
      //   final UserModel updatedUser = currentUser.copyWith(
      //     tonInventory: inventory,
      //   );
      //   emit(
      //     state.copyWith(
      //       currentUser: updatedUser,
      //     ),
      //   );
    }
  }

  Future<void> _onCreateUserBetEvent(
      CreateUserBetEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      final UserModel currentUser = state.currentUser;
      final String token = currentUser.token ?? '';
      await userBetRepositoryFunctions.createUserBet(
        gameId: event.gameId,
        coinType: event.coinType,
        userChoices: jsonEncode(
          event.userChoices.map((e) => e.name).toList(),
        ),
        amount: event.amount,
        token: token,
      );
      event.afterUserBetCreated();
      double newInventory = '0.0'.convertToNum.toDouble();

      switch (event.coinType) {
        case CoinType.ton:
          newInventory = currentUser.tonInventory.convertToNum.toDouble() -
              ((event.amount.convertToNum * AppConfigs.tonBaseFactor));
          emit(
            state.copyWith(
              currentUser: currentUser.copyWith(
                token: token,
                tonInventory: '$newInventory',
              ),
            ),
          );
        case CoinType.stars:
          newInventory = currentUser.starsInventory.convertToNum.toDouble() -
              event.amount.convertToNum;
          emit(
            state.copyWith(
              currentUser: currentUser.copyWith(
                token: token,
                starsInventory: '$newInventory',
              ),
            ),
          );
        // case CoinType.usdt:
        //   newInventory = currentUser.usdtInventory.convertToNum.toDouble() -
        //       event.userChoices.length * event.amount.convertToNum;
        //   emit(
        //     state.copyWith(
        //       currentUser: currentUser.copyWith(
        //         token: token,
        //         usdtInventory: '$newInventory',
        //       ),
        //     ),
        //   );
        // case CoinType.btc:
        //   newInventory = currentUser.btcInventory.convertToNum.toDouble() -
        //       event.userChoices.length * event.amount.convertToNum;
        //   emit(
        //     state.copyWith(
        //       currentUser: currentUser.copyWith(
        //         token: token,
        //         btcInventory: '$newInventory',
        //       ),
        //     ),
        //   );
        // case CoinType.cusd:
        //   newInventory = currentUser.cusdInventory.convertToNum.toDouble() -
        //       event.userChoices.length * event.amount.convertToNum;
        //   emit(
        //     state.copyWith(
        //       currentUser: currentUser.copyWith(
        //         token: token,
        //         cusdInventory: '$newInventory',
        //       ),
        //     ),
        //   );
      }
      closeDialog();
    } catch (e) {
      closeDialog(); // اضافه کردن این خط برای بستن dialog در صورت خطا
      event.onError?.call(); // بستن confirmation dialog
      addError(e);
    }
  }

  Future<void> _onUpdateUserEvent(
      UpdateUserEvent event, Emitter<AppState> emit) async {
    try {
      final UserModel currentUser = await userRepositoryFunctions.updateUser(
        token: state.currentUser.token ?? '',
      );
      // await databaseRepositoryFunctions.saveUsersToDb(
      //   userJson: currentUser.toJson,
      // );
      emit(
        state.copyWith(
          currentUser:
              currentUser.copyWith(token: state.currentUser.token ?? ''),
        ),
      );
    } catch (e) {
      addError(e);
    }
  }

  Future<void> _onLoginRegisterEvent(
      LoginRegisterEvent event, Emitter<AppState> emit) async {
    try {
      showLoadingDialog();
      SiteSettingModel siteSettingModel = SiteSettingModel.empty;
      emit(state.copyWith(
        currentUser: event.currentUser,
        siteSettingModel: siteSettingModel,
      ));
      final List<SiteSettingModel> settings =
          await siteSettingRepositoryFunctions.getSiteSettings();
      if (settings.isNotEmpty) {
        siteSettingModel = settings.first;
      }
      emit(state.copyWith(
        currentUser: event.currentUser,
        siteSettingModel: siteSettingModel,
      ));
      closeDialog();
      // userRepositoryFunctions.loginRegisterEntry(
      //   firstname: event.telegramUser.firstname ?? '',
      //   lastname: event.telegramUser.lastname ?? '',
      //   userIdentifier: event.telegramUser.id.toString(),
      //   username: event.telegramUser.username ?? '',
      //   token: event.token,
      // );
    } catch (e) {
      addError(e);
    }
  }

  void showErrorDialog({String? title, required String error}) {
    dialogStreamController.sink.add(
      DialogModel.error(
        title: title ?? AppTexts.error,
        description: error,
      ),
    );
  }

  void showLoadingDialog() {
    dialogStreamController.sink.add(
      const DialogModel.loading(),
    );
  }

  void closeDialog() {
    dialogStreamController.sink.add(
      const DialogModel.closed(),
    );
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    closeDialog();
    if (error is BaseExceptions) {
      showErrorDialog(error: error.error);
    } else {
      showErrorDialog(error: error.toString());
    }
    super.addError(error, stackTrace);
  }

  @override
  Future<void> close() {
    dialogStreamController.sink.close();
    dialogStreamController.close();
    return super.close();
  }

  Future<void> checkTonTransaction({required String token}) async {
    try {
      const String checkTonUrl =
          '${BaseConfigs.baseUrl}/check-ton-transactions';
      await const NetworkRepositoryFunctions().sendGetRequest(
        endpointUrl: checkTonUrl,
        token: token,
      );
    } catch (e) {
      addError(e);
    }
  }
}
