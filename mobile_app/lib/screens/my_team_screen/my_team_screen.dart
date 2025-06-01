import 'package:flutter/material.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball/bloc/app_bloc/app_bloc.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/utils/functions.dart';
import 'package:winball/widgets/global/loading_widget.dart';

class MyTeamScreen extends StatefulWidget {
  const MyTeamScreen({super.key});

  @override
  State<MyTeamScreen> createState() => _MyTeamScreenState();
}

class _MyTeamScreenState extends State<MyTeamScreen> {
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final ValueNotifier<TeamReportModel> teamReportModelValueNotifier;
  late final UserRepositoryFunctions userRepositoryFunctions;
  late final Functions functions;
  Future<void> initializeDatas() async {
    isLoadingValueNotifier = ValueNotifier<bool>(true);
    teamReportModelValueNotifier =
        ValueNotifier<TeamReportModel>(TeamReportModel.empty);
    userRepositoryFunctions = const UserRepositoryFunctions();
    functions = const Functions();
    final AppBloc appBloc = context.readAppBloc;
    final UserModel currentUser = appBloc.state.currentUser;
    changeIsLoadingValueNotifier(isLoading: false);
    changeTeamReportModelValueNotifier(
      teamReportModel: await userRepositoryFunctions.getTeamReportModel(
        token: currentUser.token ?? '',
      ),
    );
  }

  void changeIsLoadingValueNotifier({bool? isLoading}) {
    isLoadingValueNotifier.value = isLoading ?? !isLoadingValueNotifier.value;
  }

  void changeTeamReportModelValueNotifier(
      {required TeamReportModel teamReportModel}) {
    teamReportModelValueNotifier.value = teamReportModel;
  }

  void dispositionalDatas() {
    isLoadingValueNotifier.dispose();
    teamReportModelValueNotifier.dispose();
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
        title: const Text(
          AppTexts.teamReport,
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoadingValueNotifier,
        builder: (context, isLoading, child) {
          return isLoading ? const LoadingWidget() : child!;
        },
        child: ValueListenableBuilder<TeamReportModel>(
          valueListenable: teamReportModelValueNotifier,
          builder: (context, teamReportModel, _) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: AppConfigs.appShadowColor,
                borderRadius: BorderRadius.circular(
                  AppConfigs.minVisualDensity,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConfigs.mediumVisualDensity,
                  horizontal: AppConfigs.mediumVisualDensity,
                ),
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppConfigs.mediumVisualDensity,
                  ),
                  children: [
                    ListTile(
                      title: const Text(
                        AppTexts.registerationUsers,
                      ),
                      subtitle: Text(
                        teamReportModel.registerationUsers.toString(),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        AppTexts.firstDepositUsers,
                      ),
                      subtitle: Text(
                        '${teamReportModel.firstDepositTonUsers / AppConfigs.tonBaseFactor} ${AppTexts.tonAmount}',
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        AppTexts.depositUsers,
                      ),
                      subtitle: Text(
                        '${teamReportModel.depositsTonUsers / AppConfigs.tonBaseFactor} ${AppTexts.tonAmount}',
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        AppTexts.withdrawalUsers,
                      ),
                      subtitle: Text(
                        '${teamReportModel.withdrawTonUsers / AppConfigs.tonBaseFactor} ${AppTexts.tonAmount}',
                      ),
                    ),
                  ],
                ),
              ),
            );
            // return users.isNotEmpty
            //     ? ListView.builder(
            //         itemCount: users.length,
            //         itemBuilder: (context, index) {
            //           final UserModel user = users[index];
            //           return ListTile(
            //             title: Text(
            //               user.firstname ?? AppTexts.noname,
            //             ),
            //             trailing: Text(
            //               '${AppTexts.joinAt} ${functions.convertDateTimeToDateAndTime(
            //                 dateTime: user.createdAt,
            //               )}',
            //             ),
            //           );
            //         },
            //       )
            //     : const CustomErrorWidget();
          },
        ),
      ),
    );
  }
}
