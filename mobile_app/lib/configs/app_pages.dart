import 'package:flutter/material.dart' show Widget;
import 'package:winball/screens/screens.dart';

abstract class AppPages {
  static const String authenticationControllerScreen = '/';
  static const String withdrawScreen = '/withdraw-screen';
  static const String serviceScreen = '/service-screen';
  static const String homeScreen = '/home-screen';
  static const String earnScreen = '/earn-screen';
  static const String profileScreen = '/profile-screen';
  static const String oneMinGameScreen = '/one-min-game-screen';
  static const String listOfGamesScreen = '/list-of-games-screen';
  static const String announcementScreen = '/announcement-screen';
  static const String activityScreen = '/activity-screen';
  static const String invitationScreen = '/invitation-screen';
  static const String myTeamScreen = '/my-team-screen';
  static const String helpScreen = '/help-screen';
  static const String rulesScreen = '/rules-screen';
  static const String depositScreen = '/deposit-screen';
  static const String gameRecordsScreen = '/game-records-screen';
  static const String searchScreen = '/search-screen';
  static const String redBlackGameScreen = '/red-black-game-screen';
  
  static const Map<String, Widget> mapOfAppScreens = {
    authenticationControllerScreen: AuthenticationControllerScreen(),
    homeScreen: HomeScreen(),
    earnScreen: EarnScreen(),
    profileScreen: ProfileScreen(),
    listOfGamesScreen: ListOfGamesScreen(),
    announcementScreen: AnnouncementScreen(),
    activityScreen: ActivityScreen(),
    invitationScreen: InvitationScreen(),
    myTeamScreen: MyTeamScreen(),
    helpScreen: HelpScreen(),
    rulesScreen: RulesScreen(),
    depositScreen: DepositScreen(),
    gameRecordsScreen: GameRecordsScreen(),
    searchScreen: SearchScreen(),
    withdrawScreen: WithdrawScreen(),
    serviceScreen: ServiceScreen(),
  };
}
