import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/widgets/widgets.dart';
import 'dart:js' as js;
import 'package:url_launcher/url_launcher.dart';

class CopyInvitationCodeWidget extends StatelessWidget {
  const CopyInvitationCodeWidget({
    super.key,
    required this.currentUser,
  });
  final UserModel currentUser;
  
  static Future<void> shareLink({
    required String title,
    required String text,
    required String link,
    required BuildContext context,
  }) async {
    try {
      final telegramUrl = Uri.parse('https://t.me/share/url?url=$link&text=$text');
      
      final canLaunch = await canLaunchUrl(telegramUrl);
      
      if (canLaunch) {
        await launchUrl(telegramUrl, mode: LaunchMode.externalApplication);
      } else {
        js.context.callMethod('shareLink', [title, text, link]);
      }
    } catch (e) {
      try {
        TelegramWebApp.instance.showAlert('Error sharing link');
      } catch (alertError) {
        // debugPrint('Error showing alert: $alertError');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InvitationBackgroundTemplateWidget(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  AppTexts.invitationCode,
                ),
              ),
              Expanded(
                child: ListTile(
                  onTap: () {
                    try {
                      Clipboard.setData(
                        ClipboardData(
                          text:
                              '${AppConfigs.invitationBaseUrl}${currentUser.invitationCode}',
                        ),
                      );
                      TelegramWebApp.instance.showAlert(AppTexts.copied);
                    } catch (e) {
                      // debugPrint('Copy error: $e');
                    }
                  },
                  title: Text(
                    '${AppConfigs.invitationBaseUrl}${currentUser.invitationCode}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.copy),
                ),
              ),
            ],
          ),
          const Divider(height: 1, color: Colors.white12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppConfigs.largeVisualDensity),
                bottomRight: Radius.circular(AppConfigs.largeVisualDensity),
              ),
            ),
            child: TextButton.icon(
              icon: const Icon(Icons.telegram, color: Colors.white),
              label: const Text(
                'Share on Telegram',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                CopyInvitationCodeWidget.shareLink(
                  title: AppTexts.inviteLink,
                  link: '${AppConfigs.invitationBaseUrl}${currentUser.invitationCode}',
                  text: AppTexts.joinToBot,
                  context: context,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
