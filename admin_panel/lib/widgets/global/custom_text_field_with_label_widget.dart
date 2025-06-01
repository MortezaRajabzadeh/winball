import 'package:flutter/material.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/enums/enums.dart';
import 'package:winball_admin_panel/widgets/global/custom_space_widget.dart';

class CustomTextFieldWithLabelWidget extends StatelessWidget {
  const CustomTextFieldWithLabelWidget({
    super.key,
    required this.textEditingController,
    required this.label,
  });
  final String label;

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
        ),
        const CustomSpaceWidget(
          sizeDirection: SizeDirection.horizontal,
        ),
        Expanded(
          child: TextField(
            controller: textEditingController,
            decoration: AppConfigs.customInputDecoration.copyWith(
              labelText: label,
            ),
          ),
        ),
      ],
    );
  }
}
