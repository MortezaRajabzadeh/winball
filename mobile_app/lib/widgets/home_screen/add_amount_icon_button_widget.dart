import 'package:flutter/material.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/widgets/widgets.dart';

class AddAmountIconButtonWidget extends StatelessWidget {
  const AddAmountIconButtonWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlueBackgroundWidget(
      borderRadius: BorderRadius.circular(AppConfigs.minVisualDensity),
      child: IconButton(
        style: const ButtonStyle(
          padding: WidgetStatePropertyAll(
            EdgeInsets.zero,
          ),
        ),
        onPressed: () {
          context.tonamed(name: AppPages.depositScreen);
        },
        icon: const Icon(Icons.add),
      ),
    );
  }
}
