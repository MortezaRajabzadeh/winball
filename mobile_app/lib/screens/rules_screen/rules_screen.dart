import 'package:flutter/material.dart';
import 'package:winball/configs/configs.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppTexts.rules,
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: AppConfigs.mediumVisualDensity,
          horizontal: AppConfigs.largeVisualDensity,
        ),
        child: Text(
          AppTexts.oneMinGameRules,
        ),
      ),
    );
  }
}
