part of 'app_bloc.dart';

abstract class AppEvent {
  const AppEvent();
}

class LoginRegisterEvent extends AppEvent {
  final UserModel currentUser;
  const LoginRegisterEvent({
    required this.currentUser,
  });
}

class UpdateUserEvent extends AppEvent {
  const UpdateUserEvent();
}

class CreateUserBetEvent extends AppEvent {
  final int gameId;
  final List<UserBetOptions> userChoices;
  final CoinType coinType;
  final String amount;
  final void Function() afterUserBetCreated;
  final void Function()? onError;
  const CreateUserBetEvent({
    required this.amount,
    required this.gameId,
    required this.userChoices,
    required this.coinType,
    required this.afterUserBetCreated,
    this.onError,
  });
}

class UpdateUserInventoryEvent extends AppEvent {
  final double inventory;
  final CoinType coinType;
  const UpdateUserInventoryEvent({
    required this.inventory,
    required this.coinType,
  });
}

class ChangeSelectedCoinTypeEvent extends AppEvent {
  final CoinType coinType;
  const ChangeSelectedCoinTypeEvent({
    required this.coinType,
  });
}

class CheckTonTransactionEvent extends AppEvent {
  const CheckTonTransactionEvent();
}

class CreateWithdrawEvent extends AppEvent {
  final String amount, address;
  final CoinType coinType;

  const CreateWithdrawEvent({
    required this.amount,
    required this.address,
    required this.coinType,
  });
}

class GetStarsPaymentEvent extends AppEvent {
  final String amount;
  const GetStarsPaymentEvent({
    required this.amount,
  });
}

class CreateInvitationEvent extends AppEvent {
  final int invitedId;
  final String invitationCode;
  const CreateInvitationEvent({
    required this.invitedId,
    required this.invitationCode,
  });
}
