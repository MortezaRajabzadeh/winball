import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invitation_repository/invitation_repository.dart';
import 'package:user_bet_repository/user_bet_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball/bloc/app_bloc/app_bloc.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/enums/enums.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/widgets/widgets.dart';
import 'dart:js' as js;
import 'package:url_launcher/url_launcher.dart';

class EarnScreen extends StatefulWidget {
  const EarnScreen({super.key});

  @override
  State<EarnScreen> createState() => _EarnScreenState();
}

class _EarnScreenState extends State<EarnScreen> {
  late final InvitationRepositoryFunctions invitationRepositoryFunctions;
  late final UserBetRepositoryFunctions userBetRepositoryFunctions;
  late final UserModel currentUser;
  late final AppBloc appBloc;
  void initializeDatas() {
    invitationRepositoryFunctions = const InvitationRepositoryFunctions();
    userBetRepositoryFunctions = const UserBetRepositoryFunctions();
    appBloc = AppBloc();
    currentUser = appBloc.state.currentUser;
  }

  void shareLink({
    required String title,
    required String text,
    required String link,
  }) async {
    try {
      final telegramUrl = Uri.parse('https://t.me/share/url?url=$link&text=$text');
      if (await canLaunchUrl(telegramUrl)) {
        await launchUrl(telegramUrl, mode: LaunchMode.externalApplication);
      } else {
        // If can't open Telegram, use the previous method
        js.context.callMethod('shareLink', [title, text, link]);
      }
    } catch (e) {
      context.readAppBloc.addError(e);
    }
  }

  void dispositionalDatas() {}
  @override
  void initState() {
    super.initState();
    initializeDatas();
  }

  @override
  void dispose() {
    dispositionalDatas();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          AppTexts.rewards,
        ),
        actions: [
          IconButton(
            onPressed: context.pop,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConfigs.largeVisualDensity,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: AppConfigs.sliderHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    AppConfigs.sliderImages.first,
                  ),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(
                  AppConfigs.largeVisualDensity,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
            ),
            const CustomSpaceWidget(
              size: AppConfigs.largeVisualDensity,
            ),
            const Text(
              AppTexts.inviteFriendsEarnTokens,
              style: AppConfigs.whiteBoldTextStyle,
            ),
            const CustomSpaceWidget(),
            const Text(
              AppTexts.reward_text,
              overflow: TextOverflow.fade,
            ),
            const CustomSpaceWidget(
              size: AppConfigs.largeVisualDensity,
            ),
            const Divider(),
            const CustomSpaceWidget(),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.link, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      AppTexts.yourReferralLink,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const CustomSpaceWidget(),
                Container(
                  decoration: BoxDecoration(
                    color: AppConfigs.appShadowColor,
                    borderRadius: BorderRadius.circular(
                      AppConfigs.largeVisualDensity,
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          '${AppConfigs.invitationBaseUrl}${currentUser.invitationCode}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.copy,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(
                                text:
                                    '${AppConfigs.invitationBaseUrl}${currentUser.invitationCode}',
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Referral link copied'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
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
                            shareLink(
                              title: AppTexts.inviteLink,
                              link:
                                  '${AppConfigs.invitationBaseUrl}${currentUser.invitationCode}',
                              text: AppTexts.joinToBot,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const CustomSpaceWidget(
              size: AppConfigs.largeVisualDensity,
            ),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: AppTexts.referrals,
                    icon: Icons.people,
                    future: invitationRepositoryFunctions.getInvitedUsersCount(
                      token: currentUser.token ?? '',
                    ),
                  ),
                ),
                Expanded(
                  child: _buildStatCard(
                    title: AppTexts.referralWagered,
                    icon: Icons.monetization_on,
                    future: userBetRepositoryFunctions.getUserBetCount(
                      token: currentUser.token ?? '',
                    ),
                  ),
                ),
              ],
            ),
            
            const CustomSpaceWidget(
              size: AppConfigs.largeVisualDensity,
            ),

            const Text(
              AppTexts.rewards_text1,
              overflow: TextOverflow.fade,
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),

            const CustomSpaceWidget(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required Future<int> future,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConfigs.mediumVisualDensity,
      ),
      decoration: BoxDecoration(
        color: AppConfigs.appShadowColor,
        borderRadius: BorderRadius.circular(
          AppConfigs.mediumVisualDensity,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConfigs.mediumVisualDensity),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: Colors.white12),
            FutureBuilder<int>(
              future: future,
              builder: (context, AsyncSnapshot<int> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ));
                } else if (snapshot.hasData && snapshot.data != null) {
                  return Text(
                    (snapshot.data ?? 0).toString(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Row(
                    children: [
                      const Icon(Icons.error_outline, size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Error loading',
                          style: const TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Text('0', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
