import 'package:flutter/material.dart';
import 'package:winball_admin_panel/bloc/app_bloc/app_bloc.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/extensions/extensions.dart';
import 'package:winball_admin_panel/widgets/global/custom_space_widget.dart';

class CreateEditActivityModelWidget extends StatelessWidget {
  const CreateEditActivityModelWidget({
    super.key,
    required this.changeUploadedImageValueNotifier,
    required this.descriptionTextEditingController,
    required this.formKey,
    required this.titleTextEditingController,
    required this.uploadedImagePathValueNotifier,
  });
  final GlobalKey<FormState> formKey;
  final TextEditingController titleTextEditingController,
      descriptionTextEditingController;
  final void Function({required String path}) changeUploadedImageValueNotifier;
  final ValueNotifier<String> uploadedImagePathValueNotifier;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            AppTexts.createActivity,
            style: AppConfigs.titleTextStyle,
            textAlign: TextAlign.center,
          ),
          const Divider(),
          const CustomSpaceWidget(),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  validator: (String? value) {
                    return (value ?? '').length < 3
                        ? AppTexts.titleIsTooShort
                        : null;
                  },
                  controller: titleTextEditingController,
                  decoration: AppConfigs.customInputDecoration.copyWith(
                    labelText: AppTexts.title,
                  ),
                ),
              ),
              ValueListenableBuilder<String>(
                valueListenable: uploadedImagePathValueNotifier,
                builder: (context, imagePath, _) {
                  return Expanded(
                    child: TextButton(
                      child: Text(
                        imagePath.isEmpty
                            ? AppTexts.chooseImage
                            : imagePath.split('/').last,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: () {
                        context.readAppBloc.add(
                          UploadImageEvent(
                            afterFileUploaded: changeUploadedImageValueNotifier,
                          ),
                        );
                      },
                    ),
                  );
                },
              )
            ],
          ),
          const CustomSpaceWidget(),
          TextFormField(
            controller: descriptionTextEditingController,
            minLines: 5,
            maxLines: 7,
            validator: (String? value) {
              return (value ?? '').length < 10
                  ? AppTexts.descriptionIsTooShort
                  : null;
            },
            decoration: AppConfigs.customInputDecoration.copyWith(
              labelText: AppTexts.description,
            ),
          ),
        ],
      ),
    );
  }
}
