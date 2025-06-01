import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:winball/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:winball/enums/enums.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/models/dialog_model.dart';
import 'package:winball/screens/screens.dart';
import 'package:winball/utils/functions.dart';

class AuthenticationControllerScreen extends StatefulWidget {
  const AuthenticationControllerScreen({super.key});

  @override
  State<AuthenticationControllerScreen> createState() =>
      _AuthenticationControllerScreenState();
}

class _AuthenticationControllerScreenState
    extends State<AuthenticationControllerScreen> {
  late final ValueNotifier<bool> isLoginPageValueNotifier;
  OverlayEntry? entry;
  late final Functions functions;
  late final StreamSubscription<DialogModel> dialogStreamSubscription;
  void initializeDatas() {
    isLoginPageValueNotifier = ValueNotifier<bool>(true);
    functions = const Functions();
    dialogStreamSubscription =
        context.readAppBloc.dialogStreamController.stream.listen(
      (DialogModel dialogModel) {
        if (dialogModel.dialogStatus == DialogStatus.open) {
          entry = functions.showOverlayDialog(
            dialogModel: dialogModel,
            context: context,
          );
        } else {
          entry?.remove();
        }
      },
    );
    final TelegramUser telegramUser = TelegramWebApp.instance.initData.user;
    // final List<String> listOfTelegramInitDatas =
    //     TelegramWebApp.instance.initData.toString().split('&');
    // final int paramIndex =
    //     listOfTelegramInitDatas.indexWhere((e) => e.contains('start_param'));
    // if (paramIndex != -1) {
    //   final String paramString =
    //       listOfTelegramInitDatas[paramIndex].split('=').last.trim();
    //   context.readAppBloc.add(
    //     CreateInvitationEvent(
    //       invitedId: telegramUser.id,
    //       invitationCode: paramString,
    //     ),
    //   );
    // }
    TelegramWebApp.instance.disableVerticalSwipes();
    context.readAuthBloc.add(
      GetUserWithUniqueNumberEvent(
        userUniqueNumber:
            //  '80270326',
            telegramUser.id.toString(),
      ),
    );
  }

  void dispositionalDatas() {
    isLoginPageValueNotifier.dispose();
  }

  void toggleLoginRegisterPageValueNotifier() {
    isLoginPageValueNotifier.value = !isLoginPageValueNotifier.value;
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
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        return (state.currentUser == null || state.currentUser?.id == -1)
            ? const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : const HomeScreen();
      },
    );
  }
}
