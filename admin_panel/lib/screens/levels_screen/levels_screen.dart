import 'package:flutter/material.dart';
import 'package:level_repository/level_repository.dart';
import 'package:winball_admin_panel/bloc/app_bloc/app_bloc.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/enums/enums.dart';
import 'package:winball_admin_panel/extensions/extensions.dart';
import 'package:winball_admin_panel/widgets/widgets.dart';

class LevelsScreen extends StatefulWidget {
  const LevelsScreen({super.key});

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final ValueNotifier<List<LevelModel>> listOfLevelsValueNotifier;
  late final LevelRepositoryFunctions levelRepositoryFunctions;
  late final TextEditingController titleTextEditingController,
      expToUpgradeTextEditingController;
  late final GlobalKey<FormState> _formKey;
  Future<void> initializeDatas() async {
    titleTextEditingController = TextEditingController();
    expToUpgradeTextEditingController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    levelRepositoryFunctions = const LevelRepositoryFunctions();
    isLoadingValueNotifier = ValueNotifier<bool>(true);
    listOfLevelsValueNotifier = ValueNotifier<List<LevelModel>>([]);
    final AppBloc appBloc = context.readAppBloc;
    try {
      changeListOfLevelsValueNotifier(
        levels: await levelRepositoryFunctions.getLevels(
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

  void changeListOfLevelsValueNotifier({required List<LevelModel> levels}) {
    listOfLevelsValueNotifier.value = levels;
  }

  void dispositionalDatas() {
    titleTextEditingController.dispose();
    expToUpgradeTextEditingController.dispose();
    isLoadingValueNotifier.dispose();
    listOfLevelsValueNotifier.dispose();
  }

  void addLevelToListOfLevelsValueNotifier({required LevelModel levelModel}) {
    final List<LevelModel> levels = listOfLevelsValueNotifier.value;
    changeListOfLevelsValueNotifier(levels: []);
    levels.add(levelModel);
    changeListOfLevelsValueNotifier(levels: levels);
  }

  void setValuesForEditLevel({required LevelModel levelModel}) {
    titleTextEditingController.text = levelModel.levelTag;
    expToUpgradeTextEditingController.text = levelModel.expToUpgrade;
  }

  void afterLevelEdited({required LevelModel levelModel}) {
    final List<LevelModel> levels = listOfLevelsValueNotifier.value;
    final int index = levels.indexWhere((e) => e.id == levelModel.id);
    if (index != -1) {
      changeListOfLevelsValueNotifier(levels: []);
      levels.removeAt(index);
      levels.insert(index, levelModel);
      changeListOfLevelsValueNotifier(levels: levels);
    }
  }

  void afterLevelDeleted({required int levelId}) {
    final List<LevelModel> levels = listOfLevelsValueNotifier.value;
    changeListOfLevelsValueNotifier(levels: []);
    levels.removeWhere((e) => e.id == levelId);
    changeListOfLevelsValueNotifier(
      levels: levels,
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
                    content: CreateEditLevelWidget(
                      formKey: _formKey,
                      titleTextEditingController: titleTextEditingController,
                      expToUpgradeTextEditingController:
                          expToUpgradeTextEditingController,
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
                              CreateLevelModelEvent(
                                title: titleTextEditingController.text,
                                expToUpgrade:
                                    expToUpgradeTextEditingController.text,
                                afterLevelModelCreated:
                                    addLevelToListOfLevelsValueNotifier,
                              ),
                            );
                          }
                        },
                        child: const Text(AppTexts.createLevel),
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
        child: ValueListenableBuilder<List<LevelModel>>(
          valueListenable: listOfLevelsValueNotifier,
          builder: (context, levels, _) {
            return levels.isEmpty
                ? const CustomErrorWidget()
                : ListView.builder(
                    itemCount: levels.length,
                    itemBuilder: (context, index) {
                      final LevelModel levelModel = levels[index];
                      return ListTile(
                        title: Text(levelModel.levelTag),
                        subtitle: Text(levelModel.expToUpgrade),
                        trailing: PopupMenuButton(
                          onSelected: (PopupMenuItemOptions selectedOptions) {
                            setValuesForEditLevel(
                              levelModel: levelModel,
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
                                              EditLevelModelEvent(
                                                afterLevelModelEdited:
                                                    afterLevelEdited,
                                                expToUpgrade:
                                                    expToUpgradeTextEditingController
                                                        .text,
                                                levelId: levelModel.id,
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
                                            RemoveLevelModelEvent(
                                              levelId: levelModel.id,
                                              afterLevelModelRemoved: (
                                                  {required int levelId}) {
                                                afterLevelDeleted(
                                                  levelId: levelId,
                                                );
                                                context.pop();
                                              },
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
                                                '${AppTexts.levelTag}:${levelModel.levelTag} - \n${AppTexts.expToUpgrade}:${levelModel.expToUpgrade}',
                                              ),
                                            ],
                                          ),
                                        )
                                      : selectedOptions ==
                                              PopupMenuItemOptions.edit
                                          ? CreateEditLevelWidget(
                                              expToUpgradeTextEditingController:
                                                  expToUpgradeTextEditingController,
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

class CreateEditLevelWidget extends StatelessWidget {
  const CreateEditLevelWidget({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.titleTextEditingController,
    required this.expToUpgradeTextEditingController,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final TextEditingController titleTextEditingController;
  final TextEditingController expToUpgradeTextEditingController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            AppTexts.createLevel,
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
              labelText: AppTexts.levelTag,
            ),
          ),
          const CustomSpaceWidget(),
          TextFormField(
            validator: (String? value) {
              return (value ?? '').isEmpty ? AppTexts.expIsNotValid : null;
            },
            controller: expToUpgradeTextEditingController,
            decoration: AppConfigs.customInputDecoration.copyWith(
              labelText: AppTexts.expToUpgrade,
            ),
          ),
        ],
      ),
    );
  }
}
