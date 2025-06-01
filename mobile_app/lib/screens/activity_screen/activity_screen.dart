import 'package:activity_repository/activity_repository.dart';
import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/utils/functions.dart';
import 'package:winball/widgets/widgets.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final ValueNotifier<List<ActivityModel>> listOfActivitiesValueNotifier;
  late final ActivityRepositoryFunctions activityRepositoryFunctions;
  late final Functions functions;
  Future<void> initializeDatas() async {
    isLoadingValueNotifier = ValueNotifier<bool>(false);
    listOfActivitiesValueNotifier =
        ValueNotifier<List<ActivityModel>>(const []);
    activityRepositoryFunctions = const ActivityRepositoryFunctions();
    functions = const Functions();
    final List<ActivityModel> activities =
        await activityRepositoryFunctions.getActivities(
      token: context.readAppBloc.state.currentUser.token ?? '',
    );
    changeListOfActivitiesValueNotifier(
      activities: activities,
    );
  }

  void dispositionalDatas() {
    isLoadingValueNotifier.dispose();
    listOfActivitiesValueNotifier.dispose();
  }

  void changeIsLoadingValueNotifier({bool? isLoading}) {
    isLoadingValueNotifier.value = isLoading ?? !isLoadingValueNotifier.value;
  }

  void changeListOfActivitiesValueNotifier({
    required List<ActivityModel> activities,
  }) {
    listOfActivitiesValueNotifier.value = activities;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppTexts.activity,
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: isLoadingValueNotifier,
        builder: (context, isLoading, child) {
          return isLoading ? const LoadingWidget() : child!;
        },
        child: ValueListenableBuilder(
          valueListenable: listOfActivitiesValueNotifier,
          builder: (context, activities, _) {
            return activities.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      final ActivityModel activityModel = activities[index];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(
                                AppConfigs.minVisualDensity,
                              ),
                            ),
                            child: Text(
                              functions.convertDateTimeToDateAndTime(
                                dateTime: activityModel.createdAt,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: size.height / 4,
                            child: Image.network(
                              '${BaseConfigs.serveImage}${activityModel.bannerUrl}',
                            ),
                          ),
                          const Divider(),
                          ListTile(
                            onTap: () {
                              showAdaptiveDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog.adaptive(
                                    actions: [
                                      TextButton(
                                        onPressed: context.pop,
                                        child: const Text(AppTexts.close),
                                      ),
                                    ],
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activityModel.title,
                                          style: AppConfigs.boldTextStyle,
                                        ),
                                        const CustomSpaceWidget(),
                                        Text(
                                          functions
                                              .convertDateTimeToDateAndTime(
                                            dateTime: activityModel.createdAt,
                                          ),
                                        ),
                                        const Divider(),
                                        Image.network(
                                          '${BaseConfigs.serveImage}${activityModel.bannerUrl}',
                                          fit: BoxFit.cover,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            title: Text(activityModel.title),
                            trailing: const Icon(Icons.arrow_forward_ios),
                          ),
                        ],
                      );
                    },
                  )
                : const CustomErrorWidget();
          },
        ),
      ),
    );
  }
}
