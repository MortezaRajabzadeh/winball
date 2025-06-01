import 'package:announcement_repository/announcement_repository.dart';
import 'package:flutter/material.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/models/dialog_model.dart';
import 'package:winball/utils/functions.dart';
import 'package:winball/widgets/widgets.dart';
import 'package:winball/enums/enums.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> {
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final ValueNotifier<List<AnnouncementModel>> announcementsValueNotifier;
  late final AnnouncementRepositoryFunctions announcementRepositoryFunctions;
  late final Functions functions;

  Future<void> initializeDatas() async {
    isLoadingValueNotifier = ValueNotifier<bool>(true);
    announcementsValueNotifier = ValueNotifier<List<AnnouncementModel>>([]);
    functions = const Functions();
    announcementRepositoryFunctions = const AnnouncementRepositoryFunctions();

    changeListOfAnnouncementValueNotifier(
      announcements: await announcementRepositoryFunctions.getAnnouncements(
        token: context.readAppBloc.state.currentUser.token ?? '',
      ),
    );

    changeIsLoadingValueNotifier(isLoading: false);
  }

  void dispositionalDatas() {
    isLoadingValueNotifier.dispose();
    announcementsValueNotifier.dispose();
  }

  void changeIsLoadingValueNotifier({bool? isLoading}) {
    isLoadingValueNotifier.value = isLoading ?? !isLoadingValueNotifier.value;
  }

  void changeListOfAnnouncementValueNotifier(
      {required List<AnnouncementModel> announcements}) {
    announcementsValueNotifier.value = announcements;
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
          AppTexts.announcement,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConfigs.mediumVisualDensity),
        child: ValueListenableBuilder<bool>(
          valueListenable: isLoadingValueNotifier,
          builder: (context, isLoading, child) {
            return isLoading ? const LoadingWidget() : child!;
          },
          child: ValueListenableBuilder<List<AnnouncementModel>>(
            valueListenable: announcementsValueNotifier,
            builder: (context, announcements, _) {
              return announcements.isEmpty
                  ? const CustomErrorWidget()
                  : SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(
                          AppConfigs.mediumVisualDensity,
                        ),
                        itemCount: announcements.length,
                        itemBuilder: (context, index) {
                          final AnnouncementModel announcementModel =
                              announcements[index];
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppConfigs.minVisualDensity,
                                  ),
                                  color: Colors.black,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    AppConfigs.minVisualDensity,
                                  ),
                                  child: Text(
                                    functions.convertDateTimeToDateAndTime(
                                      dateTime: announcementModel.createdAt,
                                    ),
                                  ),
                                ),
                              ),
                              const CustomSpaceWidget(),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppConfigs.mediumVisualDensity,
                                  ),
                                  color: AppConfigs.appShadowColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    AppConfigs.largeVisualDensity,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        announcementModel.title,
                                        style: AppConfigs.boldTextStyle,
                                        textAlign: TextAlign.right,
                                      ),
                                      const Divider(),
                                      ListTile(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(announcementModel.title),
                                                content: SingleChildScrollView(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        functions.convertDateTimeToDateAndTime(
                                                          dateTime: announcementModel.createdAt,
                                                        ),
                                                      ),
                                                      const Divider(),
                                                      const CustomSpaceWidget(
                                                        size: AppConfigs.mediumVisualDensity,
                                                      ),
                                                      Text(announcementModel.details),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: const Text(AppTexts.gotit),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          AppTexts.details,
                                        ),
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (index < announcements.length - 1)
                                const CustomSpaceWidget(
                                  size: AppConfigs.largeVisualDensity,
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
