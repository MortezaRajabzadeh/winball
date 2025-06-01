import 'package:flutter/material.dart';
import 'package:help_repository/help_repository.dart';
import 'package:winball/bloc/app_bloc/app_bloc.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/models/orgnzied_helps_by_title_model.dart';
import 'package:winball/utils/functions.dart';
import 'package:winball/widgets/widgets.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final ValueNotifier<List<HelpModel>> helpsValueNotifier;
  late final HelpRepositoryFunctions helpRepositoryFunctions;
  late final Functions functions;
  Future<void> initializeDatas() async {
    isLoadingValueNotifier = ValueNotifier<bool>(true);
    helpsValueNotifier = ValueNotifier<List<HelpModel>>(const []);
    helpRepositoryFunctions = const HelpRepositoryFunctions();
    functions = const Functions();
    final AppBloc appBloc = context.readAppBloc;
    changeListOfHelpsValueNotifier(
      helps: await helpRepositoryFunctions.getHelps(
        token: appBloc.state.currentUser.token ?? '',
      ),
    );
    changeIsLoadingValueNotifier(isLoading: false);
  }

  void changeIsLoadingValueNotifier({bool? isLoading}) {
    isLoadingValueNotifier.value = isLoading ?? !isLoadingValueNotifier.value;
  }

  void changeListOfHelpsValueNotifier({required List<HelpModel> helps}) {
    helpsValueNotifier.value = helps;
  }

  void dispositionalDatas() {
    isLoadingValueNotifier.dispose();
    helpsValueNotifier.dispose();
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
        title: const Text(AppTexts.help),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          AppConfigs.mediumVisualDensity,
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: isLoadingValueNotifier,
          builder: (context, isLoading, child) {
            return isLoading ? const LoadingWidget() : child!;
          },
          child: ValueListenableBuilder<List<HelpModel>>(
            valueListenable: helpsValueNotifier,
            builder: (context, helps, _) {
              final List<OrgnziedHelpsByTitleModel> orgnizedHelpsList =
                  functions.getOrgnizedHelpsByListOfHelps(helps: helps);
              return orgnizedHelpsList.isEmpty
                  ? const CustomErrorWidget()
                  : Column(
                      children: List.generate(
                        orgnizedHelpsList.length,
                        (outerIndex) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                orgnizedHelpsList[outerIndex].title,
                                style: AppConfigs.titleTextStyle,
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                itemCount:
                                    orgnizedHelpsList[outerIndex].helps.length,
                                itemBuilder: (context, index) {
                                  final HelpModel help =
                                      orgnizedHelpsList[outerIndex]
                                          .helps[index];
                                  return ListTile(
                                    onTap: () {
                                      showAdaptiveDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog.adaptive(
                                            actions: [
                                              TextButton(
                                                child:
                                                    const Text(AppTexts.gotit),
                                                onPressed: () {
                                                  context.pop();
                                                },
                                              ),
                                            ],
                                            content: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    help.title,
                                                    style: AppConfigs
                                                        .titleTextStyle,
                                                  ),
                                                  const CustomSpaceWidget(),
                                                  Text(
                                                    functions
                                                        .convertDateTimeToDateAndTime(
                                                      dateTime: help.createdAt,
                                                    ),
                                                  ),
                                                  const Divider(),
                                                  const CustomSpaceWidget(
                                                    size: AppConfigs
                                                        .mediumVisualDensity,
                                                  ),
                                                  Text(help.description)
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    title: Text(help.subsection),
                                    subtitle: Text(
                                      functions.convertDateTimeToDateAndTime(
                                        dateTime: help.createdAt,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    );
            },
          ),
        ),
      ),
    );
  }
}
