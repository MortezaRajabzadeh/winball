import 'package:flutter/material.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/widgets/global/custom_space_widget.dart';
import 'package:winball/widgets/global/loading_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.toggleLoginRegisterPageValueNotifier,
  });
  final void Function() toggleLoginRegisterPageValueNotifier;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final GlobalKey<FormState> _formKey;
  late final ValueNotifier<bool> showPasswordValueNotifier,
      isLoadingValueNotifier;
  late final TextEditingController usernameTextEditingController,
      passwordTextEditingController;
  late final UserRepositoryFunctions userRepositoryFunctions;
  void initializeDatas() {
    _formKey = GlobalKey<FormState>();
    userRepositoryFunctions = const UserRepositoryFunctions();
    showPasswordValueNotifier = ValueNotifier<bool>(false);
    isLoadingValueNotifier = ValueNotifier<bool>(false);
    usernameTextEditingController = TextEditingController();
    passwordTextEditingController = TextEditingController();
  }

  void dispositionalDatas() {
    showPasswordValueNotifier.dispose();
    isLoadingValueNotifier.dispose();
    usernameTextEditingController.dispose();
    passwordTextEditingController.dispose();
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
                      AppTexts.login,
                      style: AppConfigs.titleTextStyle,
                    ),
                    const Divider(),
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          widget.toggleLoginRegisterPageValueNotifier();
                        },
                        child: const Text(AppTexts.didnotHaveAnAccountRegister),
                      ),
                    ),
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
                              LoginEvent(
                                username: usernameTextEditingController.text,
                                password: passwordTextEditingController.text,
                                onLoginPassed: () {
                                  toggleIsLoadingValueNotifier(
                                      isLoading: false);
                                },
                              ),
                            );
                          }
                        },
                        child: const Text(AppTexts.login),
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
