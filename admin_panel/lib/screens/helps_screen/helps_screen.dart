import 'package:flutter/material.dart';
import 'package:help_repository/help_repository.dart';
import 'package:winball_admin_panel/bloc/app_bloc/app_bloc.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/enums/enums.dart';
import 'package:winball_admin_panel/extensions/extensions.dart';
import 'package:winball_admin_panel/widgets/widgets.dart';

class HelpsScreen extends StatefulWidget {
  const HelpsScreen({super.key});

  @override
  State<HelpsScreen> createState() => _HelpsScreenState();
}

class _HelpsScreenState extends State<HelpsScreen> {
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final ValueNotifier<List<HelpModel>> listOfHelpsValueNotifier;
  late final HelpRepositoryFunctions helpRepositoryFunctions;
  late final TextEditingController titleTextEditingController,
      subsectionTextEditingController,
      descriptionTextEditingController;
  late final GlobalKey<FormState> _formKey;
  Future<void> initializeDatas() async {
    titleTextEditingController = TextEditingController();
    descriptionTextEditingController = TextEditingController();
    subsectionTextEditingController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    helpRepositoryFunctions = const HelpRepositoryFunctions();
    isLoadingValueNotifier = ValueNotifier<bool>(true);
    listOfHelpsValueNotifier = ValueNotifier<List<HelpModel>>([]);
    final AppBloc appBloc = context.readAppBloc;
    try {
      changeListOfHelpsValueNotifier(
        helps: await helpRepositoryFunctions.getHelps(
          token: appBloc.state.currentUser.token ?? '',
        ),
      );
      changeIsLoadingValueNotifier(isLoading: false);
    } catch (e) {
      changeIsLoadingValueNotifier(isLoading: false);
      appBloc.addError(e);
    }
  }

  void changeIsLoadingValueNotifier({bool? isLoading}) {
    isLoadingValueNotifier.value = isLoading ?? !isLoadingValueNotifier.value;
  }

  void changeListOfHelpsValueNotifier({required List<HelpModel> helps}) {
    listOfHelpsValueNotifier.value = helps;
  }

  void dispositionalDatas() {
    titleTextEditingController.dispose();
    descriptionTextEditingController.dispose();
    subsectionTextEditingController.dispose();
    isLoadingValueNotifier.dispose();
    listOfHelpsValueNotifier.dispose();
  }

  void addHelpToListOfHelpsValueNotifier({required HelpModel helpModel}) {
    final List<HelpModel> helps = listOfHelpsValueNotifier.value;
    changeListOfHelpsValueNotifier(helps: []);
    helps.add(helpModel);
    changeListOfHelpsValueNotifier(helps: helps);
  }

  void setValuesForEditHelp({required HelpModel helpModel}) {
    titleTextEditingController.text = helpModel.title;
    descriptionTextEditingController.text = helpModel.description;
    subsectionTextEditingController.text = helpModel.subsection;
  }

  void afterHelpEdited({required HelpModel helpModel}) {
    final List<HelpModel> helps = listOfHelpsValueNotifier.value;
    final int index = helps.indexWhere((e) => e.id == helpModel.id);
    if (index != -1) {
      changeListOfHelpsValueNotifier(helps: []);
      helps.removeAt(index);
      helps.insert(index, helpModel);
      changeListOfHelpsValueNotifier(helps: helps);
    }
  }

  void afterHelpDeleted({required int helpId}) {
    final List<HelpModel> helps = listOfHelpsValueNotifier.value;
    changeListOfHelpsValueNotifier(helps: []);
    helps.removeWhere((e) => e.id == helpId);
    changeListOfHelpsValueNotifier(
      helps: helps,
    );
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
        actions: [
          IconButton(
            onPressed: () {
              showAdaptiveDialog(
                builder: (context) {
                  return AlertDialog.adaptive(
                    content: CreateEditHelpWidget(
                      formKey: _formKey,
                      titleTextEditingController: titleTextEditingController,
                      subsectionTextEditingController:
                          subsectionTextEditingController,
                      descriptionTextEditingController:
                          descriptionTextEditingController,
                    ),
                    actions: [
                      TextButton(
                        onPressed: context.pop,
                        child: const Text(
                          AppTexts.close,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.readAppBloc.add(
                              CreateHelpModelEvent(
                                title: titleTextEditingController.text,
                                subsection:
                                    subsectionTextEditingController.text,
                                details: descriptionTextEditingController.text,
                                afterHelpModelCreated:
                                    addHelpToListOfHelpsValueNotifier,
                              ),
                            );
                          }
                        },
                        child: const Text(AppTexts.createHelp),
                      ),
                    ],
                  );
                },
                context: context,
              );
            },
            icon: const Icon(
              Icons.add_outlined,
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoadingValueNotifier,
        builder: (context, isLoading, child) {
          return isLoading ? const LoadingWidget() : child!;
        },
        child: ValueListenableBuilder<List<HelpModel>>(
          valueListenable: listOfHelpsValueNotifier,
          builder: (context, helps, _) {
            return helps.isEmpty
                ? const CustomErrorWidget()
                : ListView.builder(
                    itemCount: helps.length,
                    itemBuilder: (context, index) {
                      final HelpModel helpModel = helps[index];
                      return ListTile(
                        title: Text(helpModel.title),
                        subtitle: Text(helpModel.description),
                        trailing: PopupMenuButton(
                          onSelected: (PopupMenuItemOptions selectedOptions) {
                            setValuesForEditHelp(
                              helpModel: helpModel,
                            );
                            showAdaptiveDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog.adaptive(
                                  actions: [
                                    TextButton(
                                      onPressed: context.pop,
                                      child: const Text(
                                        AppTexts.close,
                                      ),
                                    ),
                                    if (selectedOptions ==
                                        PopupMenuItemOptions.edit) ...{
                                      TextButton(
                                        child: const Text(AppTexts.edit),
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            context.readAppBloc.add(
                                              EditHelpModelEvent(
                                                afterHelpModelEdited:
                                                    afterHelpEdited,
                                                helpId: helpModel.id,
                                                subsection:
                                                    subsectionTextEditingController
                                                        .text,
                                                details:
                                                    descriptionTextEditingController
                                                        .text,
                                                title:
                                                    titleTextEditingController
                                                        .text,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    },
                                    if (selectedOptions ==
                                        PopupMenuItemOptions.remove) ...{
                                      TextButton(
                                        onPressed: () {
                                          context.readAppBloc.add(
                                            RemoveHelpModelEvent(
                                              afterHelpModelRemoved: (
                                                  {required int helpId}) {
                                                afterHelpDeleted(
                                                    helpId: helpId);
                                                context.pop();
                                              },
                                              helpId: helpModel.id,
                                            ),
                                          );
                                        },
                                        child: const Text(AppTexts.remove),
                                      ),
                                    },
                                  ],
                                  content: selectedOptions ==
                                          PopupMenuItemOptions.details
                                      ? SingleChildScrollView(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                AppTexts.details,
                                                style:
                                                    AppConfigs.titleTextStyle,
                                              ),
                                              const Divider(),
                                              const CustomSpaceWidget(),
                                              Text(
                                                helpModel.description,
                                              ),
                                            ],
                                          ),
                                        )
                                      : selectedOptions ==
                                              PopupMenuItemOptions.edit
                                          ? CreateEditHelpWidget(
                                              descriptionTextEditingController:
                                                  descriptionTextEditingController,
                                              subsectionTextEditingController:
                                                  subsectionTextEditingController,
                                              formKey: _formKey,
                                              titleTextEditingController:
                                                  titleTextEditingController,
                                            )
                                          : const Text(AppTexts.areYouSure),
                                );
                              },
                            );
                          },
                          itemBuilder: (context) {
                            return List.generate(
                              PopupMenuItemOptions.values.length,
                              (index) {
                                final PopupMenuItemOptions options =
                                    PopupMenuItemOptions.values
                                        .elementAt(index);
                                return PopupMenuItem<PopupMenuItemOptions>(
                                  value: options,
                                  child: Text(options.name),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
          },
        ),
      ),
    );
  }
}

class CreateEditHelpWidget extends StatelessWidget {
  const CreateEditHelpWidget({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.titleTextEditingController,
    required this.descriptionTextEditingController,
    required this.subsectionTextEditingController,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final TextEditingController titleTextEditingController;
  final TextEditingController descriptionTextEditingController;
  final TextEditingController subsectionTextEditingController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            AppTexts.createHelp,
            style: AppConfigs.titleTextStyle,
          ),
          const Divider(),
          const CustomSpaceWidget(),
          TextFormField(
            validator: (String? value) {
              return (value ?? '').length < 3 ? AppTexts.titleIsTooShort : null;
            },
            controller: titleTextEditingController,
            decoration: AppConfigs.customInputDecoration.copyWith(
              labelText: AppTexts.title,
            ),
          ),
          const CustomSpaceWidget(),
          TextFormField(
            validator: (String? value) {
              return (value ?? '').length < 10
                  ? AppTexts.subsectionIsTooShort
                  : null;
            },
            controller: subsectionTextEditingController,
            minLines: 2,
            maxLines: 4,
            decoration: AppConfigs.customInputDecoration.copyWith(
              labelText: AppTexts.subsection,
            ),
          ),
          const CustomSpaceWidget(),
          TextFormField(
            validator: (String? value) {
              return (value ?? '').length < 10
                  ? AppTexts.descriptionIsTooShort
                  : null;
            },
            controller: descriptionTextEditingController,
            minLines: 5,
            maxLines: 7,
            decoration: AppConfigs.customInputDecoration.copyWith(
              labelText: AppTexts.details,
            ),
          ),
        ],
      ),
    );
  }
}
