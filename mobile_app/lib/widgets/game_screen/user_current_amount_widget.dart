import 'package:flutter/material.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball/bloc/app_bloc/app_bloc.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/utils/functions.dart';

class UserCurrentAmountWidget extends StatelessWidget {
  const UserCurrentAmountWidget({
    super.key,
    required this.updateUserFromServer,
  });
  final void Function() updateUserFromServer;

  @override
  Widget build(BuildContext context) {
    final UserModel currentUser = context.watchAppBloc.state.currentUser;
    final AppBloc appBloc = context.readAppBloc;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        '${AppTexts.balance} ${const Functions().getUserInventoryByCoinType(userModel: currentUser, coinType: appBloc.state.selectedCoinType)}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () {
          updateUserFromServer();
        },
      ),
    );
  }
}
