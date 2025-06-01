import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:winball_admin_panel/enums/enums.dart';
import 'package:winball_admin_panel/models/models.dart';
import 'package:winball_admin_panel/screens/screens.dart';

abstract class AppConfigs {
  static const double tonBaseFactory = 1000000000;
  static const Color greenColor = Color.fromRGBO(40, 167, 69, 1);
  static const Color redColor = Color.fromRGBO(220, 53, 69, 1);
  static const Color goldColor = Color.fromRGBO(255, 215, 0, 1);
  static const Color darkBlueColor = Color.fromRGBO(0, 64, 133, 1);
  static const Color yellowColor = Color.fromRGBO(255, 193, 7, 1);
  static const Color appBackgroundColor = Color(0xff1a1e27);
  static const Color appShadowColor = Color.fromRGBO(26, 30, 39, 1);
  static const Color linearProgressIndicatorColor =
      Color.fromRGBO(241, 132, 37, 1);
  static const Color whiteTextColor = Color.fromRGBO(244, 248, 251, 1);
  static const Color whiteOrangeTextColor = Color.fromRGBO(222, 182, 112, 1);
  static const Color unselectedBottomNavigationBarColor =
      Color.fromRGBO(139, 144, 163, 1);
  static const Color lightBlueButtonColor = Color.fromRGBO(103, 119, 230, 1);
  static const Color darkBlueButtonColor = Color.fromRGBO(51, 67, 204, 1);
  static const double minVisualDensity = 4.0;
  static const double mediumVisualDensity = 8.0;
  static const double largeVisualDensity = 16.0;
  static const double extraLargeVisualDensity = 32.0;
  static const double xxxLargeVisualDensity = 64.0;
  static const TextStyle timerWhiteTextStyle = TextStyle(
    fontSize: 18.0,
  );
  static const MaterialColor applicationBackgroundMaterialColor = MaterialColor(
    0xff1a1e27,
    <int, Color>{
      50: Color(0xff171b23),
      100: Color(0xff15181f),
      200: Color(0xff12151b),
      300: Color(0xff101217),
      400: Color(0xff0d0f14),
      500: Color(0xff0a0c10),
      600: Color(0xff08090c),
      700: Color(0xff050608),
      800: Color(0xff030304),
      900: Color(0xff000000),
    },
  );
  static const String fontFamily = 'ptsans';
  static const String baseAssetsIcons = 'assets/images/';
  static const String btcIcon = '${baseAssetsIcons}btc.png';
  static const String cusd = '${baseAssetsIcons}celocelo.png';
  static const String notcoin = '${baseAssetsIcons}notcoin.png';
  static const String refUrl = 'https://t.me/bot_username_bot?start=';
  static const String tonCoin = '${baseAssetsIcons}ton.png';
  static const String usdt = '${baseAssetsIcons}usdt.png';
  static const String apiBaseUrl = 'https://back.winball.xyz/api';
  static const List<CryptoModel> listOfSupportedCryptoModels = <CryptoModel>[
    CryptoModel(
      name: 'TON',
      pictureUrl: tonCoin,
    ),
    CryptoModel(
      name: 'STARS',
      pictureUrl: notcoin,
    ),
    CryptoModel(
      name: 'USDT',
      pictureUrl: usdt,
    ),
    CryptoModel(
      name: 'BTC',
      pictureUrl: btcIcon,
    ),
    CryptoModel(
      name: 'CUSD',
      pictureUrl: cusd,
    ),
  ];
  static List<String> sliderImages =
      List.generate(4, (index) => '${baseAssetsIcons}slider${index + 1}.jpeg');
  static const double sliderHeight = 200.0;
  static InputDecoration customInputDecoration = InputDecoration(
    fillColor: AppConfigs.appShadowColor,
    filled: true,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(
        AppConfigs.mediumVisualDensity,
      ),
    ),
  );
  static const TextStyle boldTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
  );
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 22.0,
  );
  static const TextStyle greenTextStyle = TextStyle(
    color: greenColor,
  );
  static const TextStyle subtitleTextStyle = TextStyle(
    fontSize: 12.0,
  );
  static const TextStyle titleGreenTextStyle = TextStyle(
    fontSize: 22.0,
    color: greenColor,
  );
  static const TextStyle whiteBoldTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );
  static TextStyle whiteSubtitleTextStyle = TextStyle(
    color: Colors.grey[500],
    fontWeight: FontWeight.bold,
    fontSize: 12.0,
  );
  static const TextStyle redTextStyle = TextStyle(
    color: redColor,
    fontSize: 14.0,
  );
  static const TextStyle blackTextStyle = TextStyle(
    color: Colors.black,
  );

  static const Map<UserBetOptions, List<Color>> mapOfGameOptionsAndColors = {
    UserBetOptions.redPurple0: [Colors.red, Colors.purple],
    UserBetOptions.green1: [Colors.green],
    UserBetOptions.red2: [Colors.red],
    UserBetOptions.green3: [Colors.green],
    UserBetOptions.red4: [Colors.red],
    UserBetOptions.greenPurple5: [Colors.green, Colors.purple],
    UserBetOptions.red6: [Colors.red],
    UserBetOptions.green7: [Colors.green],
    UserBetOptions.red8: [Colors.red],
    UserBetOptions.green9: [Colors.green],
  };
  static const List<List<Color>> colorResultPossibilities = [
    [
      Colors.red,
    ],
    [
      Colors.green,
    ],
    [
      Colors.green,
      Colors.purple,
    ],
    [
      Colors.red,
      Colors.purple,
    ],
  ];
  static const double listWheelItemExtent = 20.0;
  static const OutlinedButtonThemeData outlinedButtonThemeData =
      OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll<Color>(
        AppConfigs.yellowColor,
      ),
      side: WidgetStatePropertyAll<BorderSide>(
        BorderSide(
          color: AppConfigs.yellowColor,
        ),
      ),
    ),
  );
  static const Map<PageType, Widget> mapOfDrawers = {
    PageType.home: SummaryScreen(),
    PageType.activities: ActivitiesScreen(),
    PageType.announcements: AnnouncementsScreen(),
    PageType.helps: HelpsScreen(),
    PageType.levels: LevelsScreen(),
    PageType.siteSetting: SiteSettingScreen(),
    PageType.slider: SliderScreen(),
    PageType.transactions: TransactionsScreen(),
    PageType.withdraws: WithdrawsScreen(),
    PageType.users: ManageUsersScreen(),
    PageType.walletManagement: WalletSettingsScreen(),
  };
}

class ApplicationScrollBehavior extends ScrollBehavior {
  const ApplicationScrollBehavior();
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }

  @override
  Set<PointerDeviceKind> get dragDevices => PointerDeviceKind.values.toSet();
}
