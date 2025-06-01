import 'package:flutter/material.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/widgets/global/custom_space_widget.dart';
import 'package:winball/widgets/global/loading_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.toggleLoginRegisterPageValueNotifier,
  });
  final void Function() toggleLoginRegisterPageValueNotifier;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final GlobalKey<FormState> _formKey;
  late final ValueNotifier<bool> showPasswordValueNotifier,
      isLoadingValueNotifier;
  late final TextEditingController usernameTextEditingController,
      passwordTextEditingController,
      firstnameTextEditingController,
      lastnameTextEditingController,
      invitationTextEditingController;
  late final UserRepositoryFunctions userRepositoryFunctions;
  void initializeDatas() {
    _formKey = GlobalKey<FormState>();
    userRepositoryFunctions = const UserRepositoryFunctions();
    showPasswordValueNotifier = ValueNotifier<bool>(false);
    isLoadingValueNotifier = ValueNotifier<bool>(false);
    usernameTextEditingController = TextEditingController();
    passwordTextEditingController = TextEditingController();
    firstnameTextEditingController = TextEditingController();
    lastnameTextEditingController = TextEditingController();
    invitationTextEditingController = TextEditingController();
  }

  void dispositionalDatas() {
    showPasswordValueNotifier.dispose();
    isLoadingValueNotifier.dispose();
    usernameTextEditingController.dispose();
    passwordTextEditingController.dispose();
    firstnameTextEditingController.dispose();
    lastnameTextEditingController.dispose();
    invitationTextEditingController.dispose();
  }

  void changeShowPasswordValueNotifier({bool? show}) {
    showPasswordValueNotifier.value = show ?? !showPasswordValueNotifier.value;
  }

  void toggleIsLoadingValueNotifier({bool? isLoading}) {
    isLoadingValueNotifier.value = isLoading ?? !isLoadingValueNotifier.value;
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
    final Size size = context.getSize;
    final bool isMobile = size.width.isMobile;

    return Scaffold(
      body: Center(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppConfigs.appShadowColor,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppConfigs.mediumVisualDensity,
              horizontal: AppConfigs.largeVisualDensity,
            ),
            child: Form(
              key: _formKey,
              child: SizedBox(
                width: isMobile ? size.width * 0.95 : size.width / 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      AppTexts.register,
                      style: AppConfigs.titleTextStyle,
                    ),
                    const Divider(),
                    const CustomSpaceWidget(),
                    TextFormField(
                      validator: (String? value) {
                        return (value ?? '').length > 2
                            ? null
                            : AppTexts.pleaseEnterValidFirstname;
                      },
                      controller: firstnameTextEditingController,
                      decoration: AppConfigs.customInputDecoration
                          .copyWith(labelText: AppTexts.firstname),
                    ),
                    const CustomSpaceWidget(),
                    TextFormField(
                      validator: (String? value) {
                        return (value ?? '').length > 2
                            ? null
                            : AppTexts.pleaseEnterValidLastname;
                      },
                      controller: lastnameTextEditingController,
                      decoration: AppConfigs.customInputDecoration
                          .copyWith(labelText: AppTexts.lastname),
                    ),
                    const CustomSpaceWidget(),
                    TextFormField(
                      validator: (String? value) {
                        return (value ?? '').length > 4
                            ? null
                            : AppTexts.pleaseEnterValidUsername;
                      },
                      controller: usernameTextEditingController,
                      decoration: AppConfigs.customInputDecoration
                          .copyWith(labelText: AppTexts.username),
                    ),
                    const CustomSpaceWidget(),
                    ValueListenableBuilder<bool>(
                      valueListenable: showPasswordValueNotifier,
                      builder: (context, showPassword, _) {
                        return TextFormField(
                          obscureText: !showPassword,
                          validator: (String? value) {
                            return (value ?? '').length > 4
                                ? null
                                : AppTexts.pleaseEnterValidPassword;
                          },
                          controller: passwordTextEditingController,
                          decoration: AppConfigs.customInputDecoration.copyWith(
                            labelText: AppTexts.password,
                            suffix: IconButton(
                              onPressed: () {
                                changeShowPasswordValueNotifier(
                                  show: !showPasswordValueNotifier.value,
                                );
                              },
                              icon: showPassword
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(Icons.visibility),
                            ),
                          ),
                        );
                      },
                    ),
                    const CustomSpaceWidget(),
                    TextFormField(
                      controller: invitationTextEditingController,
                      decoration: AppConfigs.customInputDecoration.copyWith(
                        labelText: AppTexts.invitationCode,
                      ),
                    ),
                    // const CustomSpaceWidget(),
                    // Align(
                    //   alignment: Alignment.centerLeft,
                    //   child: TextButton(
                    //     onPressed: () {
                    //       widget.toggleLoginRegisterPageValueNotifier();
                    //     },
                    //     child: const Text(
                    //       AppTexts.haveAnAccountLogin,
                    //     ),
                    //   ),
                    // ),
                    const CustomSpaceWidget(
                      size: AppConfigs.largeVisualDensity,
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: isLoadingValueNotifier,
                      builder: (context, isLoading, child) {
                        return isLoading ? const LoadingWidget() : child!;
                      },
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            toggleIsLoadingValueNotifier(isLoading: true);
                            context.readAuthBloc.add(
                              RegisterEvent(
                                username: usernameTextEditingController.text,
                                password: passwordTextEditingController.text,
                                firstname: firstnameTextEditingController.text,
                                lastname: lastnameTextEditingController.text,
                                userIdentifier: TelegramWebApp
                                    .instance.initData.user.id
                                    .toString(),
                                invitationCode:
                                    invitationTextEditingController.text,
                                onLoginPassed: () {
                                  toggleIsLoadingValueNotifier(
                                    isLoading: false,
                                  );
                                },
                              ),
                            );
                          }
                        },
                        child: const Text(AppTexts.register),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
