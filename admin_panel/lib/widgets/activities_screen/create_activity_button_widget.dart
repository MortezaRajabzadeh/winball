import 'package:flutter/material.dart';
import 'package:winball_admin_panel/bloc/app_bloc/app_bloc.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/extensions/extensions.dart';
import 'package:activity_repository/activity_repository.dart';
import 'package:winball_admin_panel/widgets/widgets.dart';

class CreateActivityButtonWidget extends StatelessWidget {
  const CreateActivityButtonWidget({
    super.key,
    required this.addActivityToListOfActivities,
    required this.changeUploadedImageValueNotifier,
    required this.descriptionTextEditingController,
    required this.formKey,
    required this.titleTextEditingController,
    required this.uploadedImagePathValueNotifier,
  });
  final GlobalKey<FormState> formKey;
  final ValueNotifier<String> uploadedImagePathValueNotifier;
  final TextEditingController titleTextEditingController,
      descriptionTextEditingController;
  final void Function({required ActivityModel activityModel})
      addActivityToListOfActivities;
  final void Function({required String path}) changeUploadedImageValueNotifier;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
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
                TextButton(
                  onPressed: () {
                    final AppBloc appBloc = context.readAppBloc;
                    if (formKey.currentState!.validate()) {
                      if (uploadedImagePathValueNotifier.value.isNotEmpty) {
                        context.readAppBloc.add(
                          CreateActivityEvent(
                            title: titleTextEditingController.text,
                            details: descriptionTextEditingController.text,
                            bannerUrl: uploadedImagePathValueNotifier.value,
                            afterActivityCreated: addActivityToListOfActivities,
                          ),
                        );
                      } else {
                        appBloc.addError(
                          AppTexts.pleaseChooseAnImage,
                        );
                      }
                    }
                  },
                  child: const Text(
                    AppTexts.createActivity,
                  ),
                ),
              ],
              content: CreateEditActivityModelWidget(
                changeUploadedImageValueNotifier:
                    changeUploadedImageValueNotifier,
                descriptionTextEditingController:
                    descriptionTextEditingController,
                formKey: formKey,
                titleTextEditingController: titleTextEditingController,
                uploadedImagePathValueNotifier: uploadedImagePathValueNotifier,
              ),
            );
          },
        );
      },
      icon: const Icon(Icons.add_outlined),
    );
  }
}
