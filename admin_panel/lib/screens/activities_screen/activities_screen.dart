import 'package:activity_repository/activity_repository.dart';
import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:winball_admin_panel/bloc/app_bloc/app_bloc.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/enums/enums.dart';
import 'package:winball_admin_panel/extensions/extensions.dart';
import 'package:winball_admin_panel/widgets/widgets.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final ValueNotifier<List<ActivityModel>> listOfActivitiesValueNotifier;
  late final ActivityRepositoryFunctions activityRepositoryFunctions;
  late final ValueNotifier<String> uploadedImagePathValueNotifier;
  late final TextEditingController titleTextEditingController,
      descriptionTextEditingController;
  late final GlobalKey<FormState> _formKey;
  Future<void> initializeDatas() async {
    titleTextEditingController = TextEditingController();
    descriptionTextEditingController = TextEditingController();
    uploadedImagePathValueNotifier = ValueNotifier<String>('');
    _formKey = GlobalKey<FormState>();
    activityRepositoryFunctions = const ActivityRepositoryFunctions();
    isLoadingValueNotifier = ValueNotifier<bool>(true);
    listOfActivitiesValueNotifier = ValueNotifier<List<ActivityModel>>([]);
    final AppBloc appBloc = context.readAppBloc;
    try {
      changeListOfActivitesValueNotifier(
        activities: await activityRepositoryFunctions.getActivities(
          token: appBloc.state.currentUser.token ?? '',
        ),
      );
      changeIsLoadingValueNotifier(isLoading: false);
    } catch (e) {
      changeIsLoadingValueNotifier(isLoading: false);
      appBloc.addError(e);
    }
  }

  void changeUploadedImageValueNotifier({required String path}) {
    uploadedImagePathValueNotifier.value = path;
  }

  void changeIsLoadingValueNotifier({bool? isLoading}) {
    isLoadingValueNotifier.value = isLoading ?? !isLoadingValueNotifier.value;
  }

  void changeListOfActivitesValueNotifier(
      {required List<ActivityModel> activities}) {
    listOfActivitiesValueNotifier.value = activities;
  }

  void dispositionalDatas() {
    titleTextEditingController.dispose();
    descriptionTextEditingController.dispose();
    isLoadingValueNotifier.dispose();
    listOfActivitiesValueNotifier.dispose();
  }

  void addActivityToListOfActivities({required ActivityModel activityModel}) {
    final List<ActivityModel> activities = listOfActivitiesValueNotifier.value;
    changeListOfActivitesValueNotifier(activities: []);
    activities.add(activityModel);
    changeListOfActivitesValueNotifier(activities: activities);
  }

  void setValuesForEditActivity({required ActivityModel activityModel}) {
    titleTextEditingController.text = activityModel.title;
    descriptionTextEditingController.text = activityModel.details;
    changeUploadedImageValueNotifier(path: activityModel.bannerUrl);
  }

  void afterActivityEdited({required ActivityModel activityModel}) {
    final List<ActivityModel> activities = listOfActivitiesValueNotifier.value;
    final int index = activities.indexWhere((e) => e.id == activityModel.id);
    if (index != -1) {
      changeListOfActivitesValueNotifier(activities: []);
      activities.removeAt(index);
      activities.insert(index, activityModel);
      changeListOfActivitesValueNotifier(activities: activities);
    }
  }

  void afterActivityDeleted({required int activityId}) {
    final List<ActivityModel> activities = listOfActivitiesValueNotifier.value;
    changeListOfActivitesValueNotifier(activities: []);
    activities.removeWhere((e) => e.id == activityId);
    changeListOfActivitesValueNotifier(
      activities: activities,
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
          CreateActivityButtonWidget(
            addActivityToListOfActivities: addActivityToListOfActivities,
            changeUploadedImageValueNotifier: changeUploadedImageValueNotifier,
            descriptionTextEditingController: descriptionTextEditingController,
            formKey: _formKey,
            titleTextEditingController: titleTextEditingController,
            uploadedImagePathValueNotifier: uploadedImagePathValueNotifier,
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoadingValueNotifier,
        builder: (context, isLoading, child) {
          return isLoading ? const LoadingWidget() : child!;
        },
        child: ValueListenableBuilder<List<ActivityModel>>(
          valueListenable: listOfActivitiesValueNotifier,
          builder: (context, activities, _) {
            return activities.isEmpty
                ? const CustomErrorWidget()
                : ListView.builder(
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final ActivityModel activityModel = activities[index];
                      return ListTile(
                        title: Text(activityModel.title),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            '${BaseConfigs.serveImage}${activityModel.bannerUrl}',
                          ),
                        ),
                        trailing: PopupMenuButton(
                          onSelected: (PopupMenuItemOptions selectedOptions) {
                            setValuesForEditActivity(
                              activityModel: activityModel,
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
                                          context.readAppBloc.add(
                                            EditActivityEvent(
                                              afterActivityEdited:
                                                  afterActivityEdited,
                                              activityId: activityModel.id,
                                              bannerUrl:
                                                  uploadedImagePathValueNotifier
                                                      .value,
                                              details:
                                                  descriptionTextEditingController
                                                      .text,
                                              title: titleTextEditingController
                                                  .text,
                                            ),
                                          );
                                        },
                                      ),
                                    },
                                    if (selectedOptions ==
                                        PopupMenuItemOptions.remove) ...{
                                      TextButton(
                                        onPressed: () {
                                          context.readAppBloc.add(
                                            RemoveActivityModelEvent(
                                              activityId: activityModel.id,
                                              afterActivityDeleted: (
                                                  {required int activityId}) {
                                                afterActivityDeleted(
                                                  activityId: activityId,
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
                                      ? ActivityDetailsWidget(
                                          activityModel: activityModel)
                                      : selectedOptions ==
                                              PopupMenuItemOptions.edit
                                          ? CreateEditActivityModelWidget(
                                              changeUploadedImageValueNotifier:
                                                  changeUploadedImageValueNotifier,
                                              descriptionTextEditingController:
                                                  descriptionTextEditingController,
                                              formKey: _formKey,
                                              titleTextEditingController:
                                                  titleTextEditingController,
                                              uploadedImagePathValueNotifier:
                                                  uploadedImagePathValueNotifier,
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
