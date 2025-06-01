import 'package:announcement_repository/announcement_repository.dart';
import 'package:flutter/material.dart';
import 'package:winball_admin_panel/bloc/app_bloc/app_bloc.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/enums/enums.dart';
import 'package:winball_admin_panel/extensions/extensions.dart';
import 'package:winball_admin_panel/widgets/widgets.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final ValueNotifier<List<AnnouncementModel>>
      listOfAnnouncementsValueNotifier;
  late final AnnouncementRepositoryFunctions announcementRepositoryFunctions;
  late final TextEditingController titleTextEditingController,
      descriptionTextEditingController;
  late final GlobalKey<FormState> _formKey;
  Future<void> initializeDatas() async {
    titleTextEditingController = TextEditingController();
    descriptionTextEditingController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    announcementRepositoryFunctions = const AnnouncementRepositoryFunctions();
    isLoadingValueNotifier = ValueNotifier<bool>(true);
    listOfAnnouncementsValueNotifier =
        ValueNotifier<List<AnnouncementModel>>([]);
    final AppBloc appBloc = context.readAppBloc;
    try {
      changeListOfAnnouncementsValueNotifier(
        announcements: await announcementRepositoryFunctions.getAnnouncements(
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

  void changeListOfAnnouncementsValueNotifier(
      {required List<AnnouncementModel> announcements}) {
    listOfAnnouncementsValueNotifier.value = announcements;
  }

  void dispositionalDatas() {
    titleTextEditingController.dispose();
    descriptionTextEditingController.dispose();
    isLoadingValueNotifier.dispose();
    listOfAnnouncementsValueNotifier.dispose();
  }

  void addAnnouncementToListOfAnnouncementsValueNotifier(
      {required AnnouncementModel announcementModel}) {
    final List<AnnouncementModel> announcements =
        listOfAnnouncementsValueNotifier.value;
    changeListOfAnnouncementsValueNotifier(announcements: []);
    announcements.add(announcementModel);
    changeListOfAnnouncementsValueNotifier(announcements: announcements);
  }

  void setValuesForEditAnnouncement(
      {required AnnouncementModel announcementModel}) {
    titleTextEditingController.text = announcementModel.title;
    descriptionTextEditingController.text = announcementModel.details;
  }

  void afterAnnouncementEdited({required AnnouncementModel announcementModel}) {
    final List<AnnouncementModel> announcements =
        listOfAnnouncementsValueNotifier.value;
    final int index =
        announcements.indexWhere((e) => e.id == announcementModel.id);
    if (index != -1) {
      changeListOfAnnouncementsValueNotifier(announcements: []);
      announcements.removeAt(index);
      announcements.insert(index, announcementModel);
      changeListOfAnnouncementsValueNotifier(announcements: announcements);
    }
  }

  void afterAnnouncementDeleted({required int announcementId}) {
    final List<AnnouncementModel> announcements =
        listOfAnnouncementsValueNotifier.value;
    changeListOfAnnouncementsValueNotifier(announcements: []);
    announcements.removeWhere((e) => e.id == announcementId);
    changeListOfAnnouncementsValueNotifier(
      announcements: announcements,
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
                    content: CreateEditAnnouncementWidget(
                      formKey: _formKey,
                      titleTextEditingController: titleTextEditingController,
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
                          context.readAppBloc.add(
                            CreateAnnouncementModelEvent(
                              title: titleTextEditingController.text,
                              details: descriptionTextEditingController.text,
                              afterAnnouncementCreated:
                                  addAnnouncementToListOfAnnouncementsValueNotifier,
                            ),
                          );
                        },
                        child: const Text(AppTexts.createAnnouncement),
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
        child: ValueListenableBuilder<List<AnnouncementModel>>(
          valueListenable: listOfAnnouncementsValueNotifier,
          builder: (context, announcements, _) {
            return announcements.isEmpty
                ? const CustomErrorWidget()
                : ListView.builder(
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final AnnouncementModel announcementModel =
                          announcements[index];
                      return ListTile(
                        title: Text(announcementModel.title),
                        subtitle: Text(announcementModel.details),
                        trailing: PopupMenuButton(
                          onSelected: (PopupMenuItemOptions selectedOptions) {
                            setValuesForEditAnnouncement(
                              announcementModel: announcementModel,
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
                                            EditAnnouncementModelEvent(
                                              afterAnnouncementModelEdited:
                                                  afterAnnouncementEdited,
                                              announcementId:
                                                  announcementModel.id,
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
                                            RemoveAnnouncementModelEvent(
                                              afterAnnouncementRemoved: (
                                                  {required int
                                                      announcementId}) {
                                                afterAnnouncementDeleted(
                                                    announcementId:
                                                        announcementId);
                                                context.pop();
                                              },
                                              announcementId:
                                                  announcementModel.id,
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
                                                announcementModel.details,
                                              ),
                                            ],
                                          ),
                                        )
                                      : selectedOptions ==
                                              PopupMenuItemOptions.edit
                                          ? CreateEditAnnouncementWidget(
                                              descriptionTextEditingController:
                                                  descriptionTextEditingController,
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

class CreateEditAnnouncementWidget extends StatelessWidget {
  const CreateEditAnnouncementWidget({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.titleTextEditingController,
    required this.descriptionTextEditingController,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final TextEditingController titleTextEditingController;
  final TextEditingController descriptionTextEditingController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            AppTexts.createAnnouncement,
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
