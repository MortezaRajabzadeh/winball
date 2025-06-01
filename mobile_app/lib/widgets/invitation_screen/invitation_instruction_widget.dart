import 'package:flutter/material.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/widgets/widgets.dart';

class InvitationInstructionWidget extends StatelessWidget {
  const InvitationInstructionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InvitationBackgroundTemplateWidget(
      child: ListTile(
        trailing: const Icon(
          Icons.arrow_forward_ios,
        ),
        title: const Text(AppTexts.invitationInstructions),
        leading: IconButton(
          icon: const Icon(
            Icons.integration_instructions,
            color: AppConfigs.yellowColor,
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}
