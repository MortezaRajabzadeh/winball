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
import 'package:winball/utils/asset_utils.dart';
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
  late final ValueNotifier<List<String>> sliderImagesValueNotifier;

  @override
  void initState() {
    super.initState();
    initializeDatas();
  }

  Future<void> initializeDatas() async {
    listCoinsScrollController = ScrollController();
    isLoadingCoinsValueNotifier = ValueNotifier<bool>(true);
    coinsValueNotifier = ValueNotifier<List<CoinModel>>([]);
    currentSliderIndexValueNotifier = ValueNotifier<int>(0);
    sliderValueNotifier = ValueNotifier<List<SliderModel>>([]);
    isLoadingSliderValueNotifier = ValueNotifier<bool>(true);
    sliderRepositoryFunctions = const SliderRepositoryFunctions();
    coinmarketCapRepositoryFunctions = const CoinmarketCapRepositoryFunctions();
    selectedCryptoValueNotifier = ValueNotifier<CryptoModel>(
      AppConfigs.listOfSupportedCryptoModels.first,
    );
    currentScaffoldGlobalKey = GlobalKey<ScaffoldState>();
    sliderImagesValueNotifier = ValueNotifier<List<String>>([]);
    final AppBloc appBloc = context.readAppBloc;
    
    // Load local slider images first
    await loadLocalSliderImages();
    
    // Loading slider data
    try {
      final List<SliderModel> sliders = await sliderRepositoryFunctions.getSlider(
        token: appBloc.state.currentUser?.token ?? '',
      );
      changeSliderValueNotifier(sliders: sliders);
    } catch (e) {
      if (e is BaseExceptions) {
        // debugPrint('Slider error: ${e.error}');
      }
      appBloc.addError(e);
    }
    changeIsLoadingSliderValueNotifier(value: false);

    // Loading coins data
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
  }

  // Load local slider images from assets directory dynamically
  Future<void> loadLocalSliderImages() async {
    print('🚀 Starting loadLocalSliderImages...');
    changeIsLoadingSliderValueNotifier(value: true);
    
    // Set default fallback images first
    final List<String> fallbackImages = [
      'assets/images/slider/IMG_1465.png',
      'assets/images/slider/IMG_1466.png',
      'assets/images/slider/IMG_1467.png',
      'assets/images/slider/IMG_1468.png',
    ];
    
    try {
      // Get all slider images dynamically
      final List<String> sliderImages = await AssetUtils.getSliderImages();
      print('📊 Received ${sliderImages.length} images from AssetUtils');
      
      if (sliderImages.isEmpty) {
        print('⚠️ No slider images found, using fallback');
        sliderImagesValueNotifier.value = fallbackImages;
      } else {
        print('✅ Setting ${sliderImages.length} images to ValueNotifier');
        sliderImagesValueNotifier.value = sliderImages;
      }
      print('🏁 Final sliderImagesValueNotifier value: ${sliderImagesValueNotifier.value}');
    } catch (e) {
      print('❌ Error in loadLocalSliderImages: $e');
      // Set fallback images in case of error
      sliderImagesValueNotifier.value = fallbackImages;
    } finally {
      changeIsLoadingSliderValueNotifier(value: false);
      print('🔚 loadLocalSliderImages completed');
    }
  }

  void _checkAndRemoveSplash() {
    // Remove splash when all data is loaded
    if (!isLoadingCoinsValueNotifier.value && !isLoadingSliderValueNotifier.value) {
      try {
        FlutterNativeSplash.remove();
      } catch (e) {
        // debugPrint('Error removing splash: $e');
      }
    }
  }

  void changeIsLoadingCoinsValueNotifier({bool? value}) {
    isLoadingCoinsValueNotifier.value =
        value ?? !isLoadingCoinsValueNotifier.value;
  }

  void changeIsLoadingSliderValueNotifier({bool? value}) {
    isLoadingSliderValueNotifier.value =
        value ?? !isLoadingSliderValueNotifier.value;
  }

  void changeCoinsValueNotifier({required List<CoinModel> coins}) {
    // Filter and sort coins based on profit percentage
    final List<CoinModel> profitableCoins = coins
        .where((coin) => !coin.percentChagne24H.startsWith('-')) // Only profitable coins
        .toList();
    
    // Sort in descending order based on change percentage
    profitableCoins.sort((a, b) => b.percentChagne24H.convertToNum
        .toDouble()
        .compareTo(a.percentChagne24H.convertToNum.toDouble()));
    
    // Only the top 5
    final List<CoinModel> top5Coins = profitableCoins.take(5).toList();
    
    coinsValueNotifier.value = top5Coins;
  }

  void changeSliderValueNotifier({required List<SliderModel> sliders}) {
    sliderValueNotifier.value = sliders;
  }

  void changeSliderIndexValueNotifier(int index) {
    try {
      currentSliderIndexValueNotifier.value = index;
    } catch (e) {
      // Silent exception handling
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

  Future<void> refreshSliderData() async {
    changeIsLoadingSliderValueNotifier(value: true);
    try {
      final AppBloc appBloc = context.readAppBloc;
      final List<SliderModel> sliders = await sliderRepositoryFunctions.getSlider(
        token: appBloc.state.currentUser?.token ?? '',
      );
      changeSliderValueNotifier(sliders: sliders);
    } catch (e) {
      if (e is BaseExceptions) {
        // debugPrint('Slider refresh error: ${e.error}');
      }
      context.readAppBloc.addError(e);
    }
    changeIsLoadingSliderValueNotifier(value: false);
  }

  @override
  void dispose() {
    listCoinsScrollController.dispose();
    currentSliderIndexValueNotifier.dispose();
    selectedCryptoValueNotifier.dispose();
    isLoadingCoinsValueNotifier.dispose();
    coinsValueNotifier.dispose();
    sliderValueNotifier.dispose();
    isLoadingSliderValueNotifier.dispose();
    sliderImagesValueNotifier.dispose();
    super.dispose();
  }

  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      String route = '';
      
      // Handle menu items based on their index
      if (index == 0) {
        // Menu button - open drawer
        currentScaffoldGlobalKey.currentState?.openDrawer();
        return;
      } else if (index == 1) {
        // Game - navigate to list of games
        route = AppPages.listOfGamesScreen;
      } else if (index == 2) {
        // Earn - navigate to earn screen
        route = AppPages.earnScreen;
      } else if (index == 3) {
        // Profile - navigate to profile screen
        route = AppPages.profileScreen;
      }
      
      if (route.isNotEmpty) {
        context.tonamed(name: route);
      }
    });
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
          const CustomSpaceWidget(
            sizeDirection: SizeDirection.horizontal,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: refreshCoinsData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: AppConfigs.largeVisualDensity,
                  right: AppConfigs.largeVisualDensity,
                  top: AppConfigs.mediumVisualDensity,
                  bottom: 16.0,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: AppConfigs.sliderHeight,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isLoadingSliderValueNotifier,
                        builder: (context, isLoading, child) {
                          return isLoading ? const LoadingWidget() : child!;
                        },
                        child: ValueListenableBuilder<List<String>>(
                          valueListenable: sliderImagesValueNotifier,
                          builder: (context, sliderImages, _) {
                            return sliderImages.isNotEmpty
                                ? SliderWidget(
                                    sliderImages: sliderImages,
                                    changeSliderIndexValueNotifier: ({required int index}) {
                                      changeSliderIndexValueNotifier(index);
                                    },
                                  )
                                : const CustomErrorWidget();
                          },
                        ),
                      ),
                    ),
                    const CustomSpaceWidget(),
                    ValueListenableBuilder<List<String>>(
                      valueListenable: sliderImagesValueNotifier,
                      builder: (context, sliderImages, child) {
                        return ValueListenableBuilder<int>(
                          valueListenable: currentSliderIndexValueNotifier,
                          builder: (context, index, _) {
                            return SliderIndicatorWidget(
                              sliderLength: sliderImages.length,
                              currentSliderIndex: index,
                            );
                          },
                        );
                      },
                    ),
                    const CustomSpaceWidget(
                      size: AppConfigs.extraLargeVisualDensity,
                    ),
                    _buildIconsGrid(),
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
                          style: const TextStyle(
                            fontSize: 20, // Standard title size in Material Design
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
                              physics: const NeverScrollableScrollPhysics(),
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
                                              fontSize: 16, // Standard list item title in Material Design
                                            ),
                                          ),
                                          TextSpan(
                                            text: '/BTC',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 14, // Standard for secondary text in Material Design
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
                    const SizedBox(height: 80), // Add space for bottom navigation
                  ],
                ),
              ),
            ),
          ),
          // Bottom Navigation Bar
          CustomBottomNavigationBarWidget(
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
          ),
        ],
      ),
    );
  }

  Widget _buildIconsGrid() {
    final items = AppConfigs.mapOfHomeIconsAndRoutes.entries.toList();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 0, // Less horizontal spacing
        mainAxisSpacing: 24,
        childAspectRatio: 0.85,
        children: List.generate(
          items.length,
          (index) => _buildIconItem(items[index], index),
        ),
      ),
    );
  }

  Widget _buildIconItem(MapEntry<IconData, dynamic> entry, int index) {
    final IconData icon = entry.key;
    String title = entry.value.keys.first.toString();
    final String routename = entry.value.values.first.toString();
    
    final List<Color> iconColors = [
      const Color(0xFF8E6CEF), // Purple
      const Color(0xFF4285F4), // Blue
      const Color(0xFFFF9800), // Orange
      const Color(0xFF4CAF50), // Green
      const Color(0xFFE53935), // Red
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFFEB3B), // Yellow
      const Color(0xFF795548), // Brown
    ];
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[800]?.withOpacity(0.3),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.grey[600]?.withOpacity(0.2) ?? Colors.grey,
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                if (routename.isNotEmpty) {
                  context.tonamed(name: routename);
                }
              },
              child: Icon(
                icon,
                size: 24,
                color: iconColors[index % iconColors.length],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 90, // More width for text
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class CustomBottomNavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          AppConfigs.listOfMenuIcons.length,
          (index) {
            final icon = AppConfigs.listOfMenuIcons.values.elementAt(index);
            final label = AppConfigs.listOfMenuNames[index];
            return _buildNavItem(icon, label, index);
          },
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppConfigs.yellowColor : Colors.white54,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppConfigs.yellowColor : Colors.white54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
