import 'dart:async';

import 'package:base_repository/base_repository.dart';
import 'package:coinmarket_cap_repository/coinmarket_cap_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:slider_repository/slider_repository.dart';
import 'package:winball/bloc/app_bloc/app_bloc.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/enums/enums.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/models/models.dart';
import 'package:winball/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ValueNotifier<List<SliderModel>> sliderValueNotifier;
  late final ValueNotifier<CryptoModel> selectedCryptoValueNotifier;
  late final GlobalKey<ScaffoldState> currentScaffoldGlobalKey;
  late final ValueNotifier<bool> isLoadingSliderValueNotifier;
  late final ValueNotifier<bool> isLoadingCoinsValueNotifier;
  late final ValueNotifier<List<CoinModel>> coinsValueNotifier;
  late final ScrollController listCoinsScrollController;
  late final SliderRepositoryFunctions sliderRepositoryFunctions;
  late final ValueNotifier<int> currentSliderIndexValueNotifier;
  late final CoinmarketCapRepositoryFunctions coinmarketCapRepositoryFunctions;
  late final PageController pageController;
  Timer? sliderTimer;
  bool isUserInteracting = false;
  
  @override
  void initState() {
    super.initState();
    pageController = PageController();
    initializeDatas();
    startSliderTimer();
  }

  Future<void> initializeDatas() async {
    listCoinsScrollController = ScrollController();
    isLoadingSliderValueNotifier = ValueNotifier<bool>(true);
    isLoadingCoinsValueNotifier = ValueNotifier<bool>(true);
    coinsValueNotifier = ValueNotifier<List<CoinModel>>([]);
    currentSliderIndexValueNotifier = ValueNotifier<int>(0);
    sliderRepositoryFunctions = const SliderRepositoryFunctions();
    sliderValueNotifier = ValueNotifier<List<SliderModel>>([]);
    currentScaffoldGlobalKey = GlobalKey<ScaffoldState>();
    selectedCryptoValueNotifier = ValueNotifier<CryptoModel>(
      AppConfigs.listOfSupportedCryptoModels.first,
    );
    final AppBloc appBloc = context.readAppBloc;
    coinmarketCapRepositoryFunctions = const CoinmarketCapRepositoryFunctions();
    
    // Load coins data
    try {
      final List<CoinModel> coins = await coinmarketCapRepositoryFunctions.getListOfCoins();
      changeCoinsValueNotifier(coins: coins);
      if (coins.isEmpty) {
        // debugPrint('No coins data available');
      } else {
        // debugPrint('Loaded ${coins.length} coins');
      }
    } catch (e) {
      if (e is BaseExceptions) {
        // debugPrint('Coinmarketcap error: ${e.error}');
      }
      appBloc.addError(e);
    }
    changeIsLoadingCoinsValueNotifier(value: false);
    _checkAndRemoveSplash();

    try {
      final token = appBloc.state.currentUser?.token;
      if (token == null || token.isEmpty) {
        // debugPrint('No token available for slider request');
        changeIsLoadingValueNotifier(value: false);
        _checkAndRemoveSplash();
        return;
      }

      final List<SliderModel> sliders = await sliderRepositoryFunctions.getSlider(
        token: token,
      );
      
      if (sliders.isEmpty) {
        // debugPrint('No sliders data available');
      } else {
        // debugPrint('Loaded ${sliders.length} sliders');
      }
      
      changeListOfSliderValueNotifier(sliders: sliders);
    } catch (e) {
      // debugPrint('Error loading sliders: $e');
      appBloc.addError(e);
    }

    changeIsLoadingValueNotifier(value: false);
    _checkAndRemoveSplash();
  }

  void _checkAndRemoveSplash() {
    // حذف splash وقتی همه داده‌ها لود شدند
    if (!isLoadingSliderValueNotifier.value && !isLoadingCoinsValueNotifier.value) {
      try {
        FlutterNativeSplash.remove();
      } catch (e) {
        // debugPrint('Error removing splash: $e');
      }
    }
  }

  void changeIsLoadingValueNotifier({bool? value}) {
    isLoadingSliderValueNotifier.value =
        value ?? !isLoadingSliderValueNotifier.value;
  }

  void changeIsLoadingCoinsValueNotifier({bool? value}) {
    isLoadingCoinsValueNotifier.value =
        value ?? !isLoadingCoinsValueNotifier.value;
  }

  void changeCoinsValueNotifier({required List<CoinModel> coins}) {
    // فیلتر و مرتب‌سازی کوین‌ها بر اساس درصد سود
    final List<CoinModel> profitableCoins = coins
        .where((coin) => !coin.percentChagne24H.startsWith('-')) // فقط کوین‌های با سود
        .toList();
    
    // مرتب‌سازی نزولی بر اساس درصد تغییر
    profitableCoins.sort((a, b) => b.percentChagne24H.convertToNum
        .toDouble()
        .compareTo(a.percentChagne24H.convertToNum.toDouble()));
    
    // فقط 5 تای اول
    final List<CoinModel> top5Coins = profitableCoins.take(5).toList();
    
    coinsValueNotifier.value = top5Coins;
  }

  void changeListOfSliderValueNotifier({required List<SliderModel> sliders}) {
    if (sliders.isEmpty) {
      // debugPrint('Setting empty sliders list');
    }
    sliderValueNotifier.value = sliders;
  }

  void changeSliderIndexValueNotifier({required int index}) {
    try {
      if (sliderValueNotifier.value.isEmpty) {
        // debugPrint('Cannot change slider index: No sliders available');
        return;
      }
      
      if (index < 0 || index >= sliderValueNotifier.value.length) {
        // debugPrint('Invalid slider index: $index (total sliders: ${sliderValueNotifier.value.length})');
        return;
      }
      
      currentSliderIndexValueNotifier.value = index;
      if (pageController.hasClients) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      // debugPrint('Error changing slider index: $e');
    }
  }

  void changeSelectedCryptoValueNotifier({required CryptoModel cryptoModel}) {
    selectedCryptoValueNotifier.value = cryptoModel;
    context.readAppBloc
        .add(ChangeSelectedCoinTypeEvent(coinType: cryptoModel.coinType));
  }

  Future<void> refreshCoinsData() async {
    changeIsLoadingCoinsValueNotifier(value: true);
    try {
      final List<CoinModel> coins = await coinmarketCapRepositoryFunctions.getListOfCoins();
      changeCoinsValueNotifier(coins: coins);
    } catch (e) {
      if (e is BaseExceptions) {
        // debugPrint('Coinmarketcap refresh error: ${e.error}');
      }
      context.readAppBloc.addError(e);
    }
    changeIsLoadingCoinsValueNotifier(value: false);
  }

  void startSliderTimer() {
    sliderTimer?.cancel();
    sliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!isUserInteracting && sliderValueNotifier.value.isNotEmpty) {
        try {
          final int currentIndex = currentSliderIndexValueNotifier.value;
          final int nextIndex = (currentIndex + 1) % sliderValueNotifier.value.length;
          
          if (nextIndex == 0) {
            pageController.jumpToPage(0);
            currentSliderIndexValueNotifier.value = 0;
          } else {
            changeSliderIndexValueNotifier(index: nextIndex);
          }
        } catch (e) {
          // debugPrint('Error in slider timer: $e');
          timer.cancel();
        }
      }
    });
  }

  @override
  void dispose() {
    sliderTimer?.cancel();
    pageController.dispose();
    listCoinsScrollController.dispose();
    currentSliderIndexValueNotifier.dispose();
    selectedCryptoValueNotifier.dispose();
    sliderValueNotifier.dispose();
    isLoadingSliderValueNotifier.dispose();
    isLoadingCoinsValueNotifier.dispose();
    coinsValueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawerWidget(
        changeSelectedCryptoValueNotifier: changeSelectedCryptoValueNotifier,
        selectedCryptoValueNotifier: selectedCryptoValueNotifier,
      ),
      key: currentScaffoldGlobalKey,
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        actions: [
          ManageWalletWidget(
            changeSelectedCryptoValueNotifier:
                changeSelectedCryptoValueNotifier,
            selectedCryptoValueNotifier: selectedCryptoValueNotifier,
          ),
          // const WalletIconButtonWidget(),
          // const UserProfileCircleAvatarWidget(),
          const CustomSpaceWidget(
            sizeDirection: SizeDirection.horizontal,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: refreshCoinsData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConfigs.mediumVisualDensity,
                  horizontal: AppConfigs.largeVisualDensity,
                ),
                child: Column(
                  children: [
                  Builder(
                    builder: (context) {
                      // محاسبه ارتفاع بر اساس نسبت 16:9
                      final double screenWidth = MediaQuery.of(context).size.width;
                      final double sliderHeight = (screenWidth * 9) / 16;
                      
                      return SizedBox(
                        height: sliderHeight,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isLoadingSliderValueNotifier,
                      builder: (context, isLoading, child) {
                        return isLoading ? const LoadingWidget() : child!;
                      },
                      child: ValueListenableBuilder<List<SliderModel>>(
                        valueListenable: sliderValueNotifier,
                        builder: (context, sliders, _) {
                          if (sliders.isEmpty) {
                            // debugPrint('No sliders to display');
                            return const CustomErrorWidget();
                          }
                          
                          return GestureDetector(
                            onTapDown: (_) => isUserInteracting = true,
                            onTapUp: (_) {
                              isUserInteracting = false;
                              startSliderTimer();
                            },
                            child: SliderWidget(
                              sliders: sliders,
                              pageController: pageController,
                              changeSliderIndexValueNotifier:
                                  changeSliderIndexValueNotifier,
                            ),
                          );
                        },
                      ),
                    ),
                      );
                    },
                  ),
                  const CustomSpaceWidget(),
                  ValueListenableBuilder<List<SliderModel>>(
                    valueListenable: sliderValueNotifier,
                    builder: (context, sliders, child) {
                      if (sliders.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return ValueListenableBuilder<int>(
                        valueListenable: currentSliderIndexValueNotifier,
                        builder: (context, index, _) {
                          return SliderIndicatorWidget(
                            sliderLength: sliders.length,
                            currentSliderIndex: index,
                          );
                        },
                      );
                    },
                  ),
                  const CustomSpaceWidget(
                    size: AppConfigs.extraLargeVisualDensity,
                  ),
                  const GoToSearchScreenTextFieldWidget(),
                  const CustomSpaceWidget(
                    size: AppConfigs.extraLargeVisualDensity,
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: List.generate(
                      AppConfigs.mapOfHomeIconsAndRoutes.length,
                      (index) {
                        final IconData icon = AppConfigs
                            .mapOfHomeIconsAndRoutes.keys
                            .elementAt(index);
                        final String title = AppConfigs
                            .mapOfHomeIconsAndRoutes.values
                            .elementAt(index)
                            .keys
                            .first;
                        final String routename = AppConfigs
                            .mapOfHomeIconsAndRoutes.values
                            .elementAt(index)
                            .values
                            .first;
                        return CustomHomeScreenIconButtonWidget(
                          routename: routename,
                          icon: icon,
                          title: title,
                          color: Colors.primaries[
                              (Colors.primaries.length - index) %
                                  Colors.primaries.length],
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  const CustomSpaceWidget(),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: AppConfigs.mediumVisualDensity,
                        height: 4,
                        child: Divider(
                          color: AppConfigs.yellowColor,
                        ),
                      ),
                      CustomSpaceWidget(
                        sizeDirection: SizeDirection.horizontal,
                      ),
                      Text(
                        AppTexts.ranking,
                        style: AppConfigs.titleTextStyle,
                      ),
                      CustomSpaceWidget(
                        sizeDirection: SizeDirection.horizontal,
                      ),
                      SizedBox(
                        width: AppConfigs.mediumVisualDensity,
                        child: Divider(
                          color: AppConfigs.yellowColor,
                        ),
                      ),
                    ],
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: isLoadingCoinsValueNotifier,
                    builder: (context, isLoadingCoins, child) {
                      return isLoadingCoins ? const LoadingWidget() : child!;
                    },
                    child: ValueListenableBuilder<List<CoinModel>>(
                      valueListenable: coinsValueNotifier,
                      builder: (context, coins, _) {
                        if (coins.isEmpty) {
                          return const CustomErrorWidget();
                        }
                        
                        return Scrollbar(
                          thumbVisibility: true,
                          controller: listCoinsScrollController,
                          child: ListView.builder(
                            controller: listCoinsScrollController,
                            itemCount: coins.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final CoinModel coinModel = coins[index];
                              final Color rankColor = AppConfigs.greenColor;
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: rankColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: coinModel.symbol,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '/BTC',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  subtitle: Text(
                                    '24H ${coinModel.numMarketPais}',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        coinModel.volumeChanged24Hours.convertToNum
                                            .toDouble()
                                            .toStringAsFixed(6),
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: AppConfigs.greenColor,
                                        ),
                                        child: Text(
                                          '+${coinModel.percentChagne24H.convertToNum.toDouble().toStringAsFixed(2)}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    AppConfigs.mediumVisualDensity,
                  ),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black45,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [
                      0.5,
                      1.0,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    AppConfigs.listOfMenuIcons.length,
                    (index) {
                      final IconData icon =
                          AppConfigs.listOfMenuIcons.values.toList()[index];
                      final String routename =
                          AppConfigs.listOfMenuIcons.keys.toList()[index];
                      final String menuName = AppConfigs.listOfMenuNames[index];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppConfigs.appShadowColor,
                              borderRadius: BorderRadius.circular(
                                AppConfigs.mediumVisualDensity,
                              ),
                            ),
                            child: BlueBackgroundWidget(
                              showBackground: index == 1,
                              borderRadius: BorderRadius.circular(
                                  AppConfigs.xxxLargeVisualDensity),
                              child: IconButton(
                                style: const ButtonStyle(
                                  padding: WidgetStatePropertyAll<
                                      EdgeInsetsGeometry>(
                                    EdgeInsets.zero,
                                  ),
                                ),
                                icon: Icon(
                                  icon,
                                ),
                                onPressed: () {
                                  if (routename.isEmpty) {
                                    currentScaffoldGlobalKey.currentState
                                        ?.openDrawer();
                                  } else {
                                    context.tonamed(
                                      name: routename,
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          const CustomSpaceWidget(),
                          Text(
                            menuName,
                            style: AppConfigs.subtitleTextStyle,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavigationBarWidget extends StatelessWidget {
  const CustomBottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: (int? index) {
        if (index == 4) {
          context.tonamed(name: AppPages.profileScreen);
        }
      },
      showUnselectedLabels: true,
      selectedItemColor: AppConfigs.yellowColor,
      // fixedColor: Colors.white,
      unselectedItemColor: AppConfigs.unselectedBottomNavigationBarColor,
      items: List.generate(
        AppConfigs.bottomNavigationBarIcons.length,
        (index) {
          final String iconname = AppConfigs.bottomNavigationBarIcons.values
              .elementAt(index)
              .keys
              .first;
          final IconData iconData =
              AppConfigs.bottomNavigationBarIcons.keys.elementAt(index);
          return BottomNavigationBarItem(
            icon: Icon(
              iconData,
            ),
            label: iconname,
          );
        },
      ),
    );
  }
}
