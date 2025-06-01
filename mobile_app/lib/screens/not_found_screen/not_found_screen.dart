import 'package:flutter/material.dart';
import 'package:winball/configs/configs.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({
    super.key,
    required this.data,
  });
  final String data;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppTexts.error404,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Text(
            data,
          ),
        ),
      ),
    );
  }
}
