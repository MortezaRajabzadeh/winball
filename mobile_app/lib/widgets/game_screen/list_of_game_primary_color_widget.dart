import 'package:flutter/material.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/widgets/widgets.dart';

class ListOfGamePrimaryColorWidget extends StatelessWidget {
  const ListOfGamePrimaryColorWidget({
    super.key,
    required this.addOrRemoveUserBetOptionsInListOfUserBetOptions,
    required this.listOfSelectedUserBetOptionsValueNotifier,
  });
  final ValueNotifier<List<UserBetOptions>>
      listOfSelectedUserBetOptionsValueNotifier;
  final void Function({required UserBetOptions userBetOptions})
      addOrRemoveUserBetOptionsInListOfUserBetOptions;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomColorPercentWidget(
            title: AppTexts.red,
            listOfSelectedUserBetOptionsValueNotifier:
                listOfSelectedUserBetOptionsValueNotifier,
            onTap: addOrRemoveUserBetOptionsInListOfUserBetOptions,
            percent: 1.95,
            userBetOptions: UserBetOptions.red,
          ),
        ),
        Expanded(
          child: CustomColorPercentWidget(
            title: AppTexts.purple,
            listOfSelectedUserBetOptionsValueNotifier:
                listOfSelectedUserBetOptionsValueNotifier,
            onTap: addOrRemoveUserBetOptionsInListOfUserBetOptions,
            percent: 4.87,
            userBetOptions: UserBetOptions.purple,
          ),
        ),
        Expanded(
          child: CustomColorPercentWidget(
            title: AppTexts.green,
            listOfSelectedUserBetOptionsValueNotifier:
                listOfSelectedUserBetOptionsValueNotifier,
            onTap: addOrRemoveUserBetOptionsInListOfUserBetOptions,
            percent: 1.95,
            userBetOptions: UserBetOptions.green,
          ),
        ),
      ],
    );
  }
}
