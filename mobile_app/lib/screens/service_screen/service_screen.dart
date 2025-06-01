import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:winball/configs/app_configs.dart';
import 'package:winball/configs/app_texts.dart';

class ServiceScreen extends StatelessWidget {
  const ServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppTexts.services,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConfigs.mediumVisualDensity,
          horizontal: AppConfigs.mediumVisualDensity,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              AppTexts.servicesDescription,
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                launchUrl(
                  Uri.parse(
                    AppConfigs.supportAdminUsername,
                  ),
                );
              },
              label: const Text(
                AppTexts.contactSupport,
              ),
              icon: const Icon(
                Icons.support_agent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
