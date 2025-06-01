import 'dart:async';

import 'package:flutter/material.dart';
import 'package:winball_admin_panel/configs/configs.dart';
import 'package:winball_admin_panel/enums/enums.dart';
import 'package:winball_admin_panel/extensions/extensions.dart';
import 'package:winball_admin_panel/models/dialog_model.dart';
import 'package:winball_admin_panel/utils/functions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final StreamSubscription<DialogModel> dialogStreamSubscription;
  OverlayEntry? entry;
  late final Functions functions;
  late final ValueNotifier<PageType> selectedPageValueNotifier;
  void initializeDatas() {
    functions = const Functions();
    dialogStreamSubscription =
        context.readAppBloc.dialogStreamController.stream.listen(
      (DialogModel dialogModel) {
        if (dialogModel.dialogStatus == DialogStatus.open) {
          entry = functions.showOverlayDialog(
            dialogModel: dialogModel,
            context: context,
          );
        } else {
          entry?.remove();
        }
      },
    );
    selectedPageValueNotifier = ValueNotifier<PageType>(PageType.home);
  }

  void changeSelectedPageTypeValueNotifier({required PageType pageType}) {
    selectedPageValueNotifier.value = pageType;
  }

  void dispositionalDatas() {
    selectedPageValueNotifier.dispose();
  }

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
    final Size size = context.getSize;
    
    return Scaffold(
      drawer: _buildModernDrawer(),
      appBar: _buildModernAppBar(),
      body: Row(
        children: [
          // Sidebar for desktop
          if (size.width > 1000) _buildDesktopSidebar(),
          // Main content
          Expanded(
            child: ValueListenableBuilder<PageType>(
        valueListenable: selectedPageValueNotifier,
        builder: (context, pageType, _) {
          final int index = AppConfigs.mapOfDrawers.keys.toList().indexWhere(
                (e) => e.name == pageType.name,
              );
          final Widget child = AppConfigs.mapOfDrawers.values.elementAt(index);
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
                  child: Container(
                    key: ValueKey(pageType),
                    padding: const EdgeInsets.all(16),
            child: child,
                  ),
          );
        },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppConfigs.darkBlueColor,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConfigs.yellowColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Management Dashboard',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ValueListenableBuilder<PageType>(
          valueListenable: selectedPageValueNotifier,
          builder: (context, pageType, _) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getPageIcon(pageType),
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getPageDisplayName(pageType),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDesktopSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppConfigs.darkBlueColor, AppConfigs.lightBlueButtonColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: AppConfigs.darkBlueColor,
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Administrator',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'System Manager',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: AppConfigs.mapOfDrawers.keys.map((pageType) {
                return ValueListenableBuilder<PageType>(
                  valueListenable: selectedPageValueNotifier,
                  builder: (context, selectedPage, _) {
                    final bool isSelected = selectedPage == pageType;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? AppConfigs.lightBlueButtonColor.withOpacity(0.1) : null,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected 
                            ? Border.all(color: AppConfigs.lightBlueButtonColor.withOpacity(0.3))
                            : null,
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppConfigs.lightBlueButtonColor 
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getPageIcon(pageType),
                            color: isSelected ? Colors.white : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        title: Text(
                          _getPageDisplayName(pageType),
                          style: TextStyle(
                            color: isSelected ? AppConfigs.lightBlueButtonColor : Colors.grey[800],
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        onTap: () {
                          changeSelectedPageTypeValueNotifier(pageType: pageType);
                        },
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppConfigs.darkBlueColor, AppConfigs.lightBlueButtonColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: AppConfigs.darkBlueColor,
                    size: 30,
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Admin Panel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Management System',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: AppConfigs.mapOfDrawers.keys.map((pageType) {
                return ValueListenableBuilder<PageType>(
                  valueListenable: selectedPageValueNotifier,
                  builder: (context, selectedPage, _) {
                    final bool isSelected = selectedPage == pageType;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? AppConfigs.lightBlueButtonColor.withOpacity(0.1) : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getPageIcon(pageType),
                          color: isSelected ? AppConfigs.lightBlueButtonColor : Colors.grey[600],
                        ),
                        title: Text(
                          _getPageDisplayName(pageType),
                          style: TextStyle(
                            color: isSelected ? AppConfigs.lightBlueButtonColor : Colors.grey[800],
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        onTap: () {
                          changeSelectedPageTypeValueNotifier(pageType: pageType);
                          Navigator.of(context).pop(); // Close drawer
                        },
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPageIcon(PageType pageType) {
    switch (pageType) {
      case PageType.home:
        return Icons.dashboard;
      case PageType.activities:
        return Icons.event;
      case PageType.announcements:
        return Icons.announcement;
      case PageType.helps:
        return Icons.help;
      case PageType.levels:
        return Icons.leaderboard;
      case PageType.siteSetting:
        return Icons.settings;
      case PageType.slider:
        return Icons.slideshow;
      case PageType.transactions:
        return Icons.receipt;
      case PageType.withdraws:
        return Icons.money_off;
      case PageType.users:
        return Icons.people;
      case PageType.walletManagement:
        return Icons.account_balance_wallet;
      default:
        return Icons.circle;
    }
  }

  String _getPageDisplayName(PageType pageType) {
    switch (pageType) {
      case PageType.home:
        return 'Dashboard';
      case PageType.activities:
        return 'Activities';
      case PageType.announcements:
        return 'Announcements';
      case PageType.helps:
        return 'Help Center';
      case PageType.levels:
        return 'Levels';
      case PageType.siteSetting:
        return 'Site Settings';
      case PageType.slider:
        return 'Slider Management';
      case PageType.transactions:
        return 'Transactions';
      case PageType.withdraws:
        return 'Withdrawals';
      case PageType.users:
        return 'User Management';
      case PageType.walletManagement:
        return 'Wallet Settings';
      default:
        return pageType.name;
    }
  }
}
