import 'package:flutter/material.dart';
import 'package:winball_admin_panel/configs/configs.dart';

class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({super.key, this.error = AppTexts.datasNotFound});
  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(error),
    );
  }
}
