import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball_admin_panel/bloc/app_bloc/app_bloc.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/widgets/widgets.dart';

class UsersDetailsScreen extends StatefulWidget {
  const UsersDetailsScreen({
    super.key,
    required this.userModel,
  });
  final UserModel userModel;
  @override
  State<UsersDetailsScreen> createState() => _UsersDetailsScreenState();
}

class _UsersDetailsScreenState extends State<UsersDetailsScreen> {
  late final TextEditingController
      // starsInventoryTextEditingController,
      tonInventoryTextEditingController;
  late final ValueNotifier<bool> isUserBlockedValueNotifier,
      isDemoValueNotifier;

  void initializeDatas() {
    isUserBlockedValueNotifier =
        ValueNotifier<bool>(widget.userModel.userType == UserType.blocked);
    isDemoValueNotifier = ValueNotifier<bool>(widget.userModel.isDemoAccount);
    // starsInventoryTextEditingController =
    //     TextEditingController(text: widget.userModel.starsInventory);
    tonInventoryTextEditingController = TextEditingController(
      text: ((double.tryParse(widget.userModel.tonInventory) ?? 0) /
              AppConfigs.tonBaseFactory)
          .toString(),
    );
  }

  void changeIsUserBlockedValueNotifier({required bool isBlocked}) {
    isUserBlockedValueNotifier.value = isBlocked;
    context.read<AppBloc>().add(
      ChangeUserTypeEvent(
        userId: widget.userModel.id,
        userType: isBlocked ? UserType.blocked : UserType.normal,
      ),
    );
  }

  void changeIsDemoAccountValueNotifier({required bool isDemoAccount}) {
    isDemoValueNotifier.value = isDemoAccount;
    context.read<AppBloc>().add(
      ChangeIsDemoAccountEvent(
        userId: widget.userModel.id,
        isDemoAccount: isDemoAccount,
      ),
    );
  }

  void updateUser() {
    context.read<AppBloc>().add(
      ChangeUserInventoryEvent(
        starsInventory: 0,
        tonInventory: double.parse(tonInventoryTextEditingController.text),
        userId: widget.userModel.id,
      ),
    );
  }

  void dispositionalDatas() {
    isUserBlockedValueNotifier.dispose();
    isDemoValueNotifier.dispose();
    // starsInventoryTextEditingController.dispose();
    tonInventoryTextEditingController.dispose();
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
      appBar: AppBar(
        title: const Text(AppTexts.userDetails),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          vertical: AppConfigs.mediumVisualDensity,
          horizontal: AppConfigs.minVisualDensity,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CustomTextFieldWithLabelWidget(
            //   label: AppTexts.starsInventory,
            //   textEditingController: starsInventoryTextEditingController,
            // ),
            // const CustomSpaceWidget(
            //   size: AppConfigs.largeVisualDensity,
            // ),
            CustomTextFieldWithLabelWidget(
              textEditingController: tonInventoryTextEditingController,
              label: AppTexts.tonInventory,
            ),
            const CustomSpaceWidget(
              size: AppConfigs.xxxLargeVisualDensity,
            ),
            ElevatedButton.icon(
              label: const Text(AppTexts.save),
              icon: const Icon(
                Icons.save,
              ),
              onPressed: () {
                updateUser();
              },
            ),
            const CustomSpaceWidget(
              size: AppConfigs.xxxLargeVisualDensity,
            ),
            ValueListenableBuilder<bool>(
              valueListenable: isUserBlockedValueNotifier,
              builder: (context, blocked, _) {
                return SwitchListTile.adaptive(
                  title: const Text(AppTexts.isBlocked),
                  value: blocked,
                  onChanged: (value) {
                    changeIsUserBlockedValueNotifier(
                      isBlocked: value,
                    );
                  },
                );
              },
            ),
            const CustomSpaceWidget(),
            ValueListenableBuilder<bool>(
              valueListenable: isDemoValueNotifier,
              builder: (context, isDemo, _) {
                return SwitchListTile.adaptive(
                  title: const Text(AppTexts.isDemoAccount),
                  value: isDemo,
                  onChanged: (value) {
                    changeIsDemoAccountValueNotifier(
                      isDemoAccount: value,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
