import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:invitation_repository/invitation_repository.dart';
import 'package:level_repository/level_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/enums/enums.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/widgets/widgets.dart';
import 'dart:async';

class InvitationScreen extends StatefulWidget {
  const InvitationScreen({super.key});

  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

// کلاس برای مدیریت بهتر داده‌ها
class _InvitationDataManager {
  final List<LevelModel> levels;
  final int? firstInvitationUsers;
  final int? secondInvitationUsers;
  final int? thirdInvitationUsers;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;

  const _InvitationDataManager({
    this.levels = const [],
    this.firstInvitationUsers,
    this.secondInvitationUsers,
    this.thirdInvitationUsers,
    this.isLoading = true,
    this.hasError = false,
    this.errorMessage,
  });

  _InvitationDataManager copyWith({
    List<LevelModel>? levels,
    int? firstInvitationUsers,
    int? secondInvitationUsers,
    int? thirdInvitationUsers,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return _InvitationDataManager(
      levels: levels ?? this.levels,
      firstInvitationUsers: firstInvitationUsers ?? this.firstInvitationUsers,
      secondInvitationUsers: secondInvitationUsers ?? this.secondInvitationUsers,
      thirdInvitationUsers: thirdInvitationUsers ?? this.thirdInvitationUsers,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class _InvitationScreenState extends State<InvitationScreen> {
  late final ValueNotifier<double> currentLevelValueNotifier;
  late final UserModel currentUser;
  late final LevelRepositoryFunctions levelRepositoryFunctions;
  late final InvitationRepositoryFunctions invitationRepositoryFunctions;
  
  // استفاده از ValueNotifier برای مدیریت داده‌ها
  late final ValueNotifier<_InvitationDataManager> dataManagerNotifier;
  
  // برای کنترل درخواست‌های مکرر
  Timer? _refreshDebouncer;
  bool _isInitialLoad = true;
  
  Future<void> initializeDatas() async {
    invitationRepositoryFunctions = const InvitationRepositoryFunctions();
    levelRepositoryFunctions = const LevelRepositoryFunctions();
    currentUser = context.readAppBloc.state.currentUser;
    currentLevelValueNotifier = ValueNotifier<double>(currentUser.levelId.toDouble());
    
    // مقداردهی اولیه مدیریت‌کننده داده
    dataManagerNotifier = ValueNotifier<_InvitationDataManager>(
      const _InvitationDataManager(isLoading: true)
    );
    
    // بارگذاری داده‌ها
    loadAllData();
  }
  
  Future<void> loadAllData() async {
    if (!mounted) return;

    // جلوگیری از درخواست‌های مکرر
    if (_refreshDebouncer?.isActive ?? false) {
      _refreshDebouncer!.cancel();
    }
    
    // زمان انتظار برای درخواست‌های مکرر
    _refreshDebouncer = Timer(const Duration(milliseconds: 300), () async {
      // اگر قبلاً داده‌ها لود شده‌اند، فقط state را آپدیت کنیم
      if (!_isInitialLoad) {
        setState(() {
          dataManagerNotifier.value = dataManagerNotifier.value.copyWith(
            isLoading: true,
            hasError: false,
          );
        });
      }
      
      try {
        // بارگذاری levels
        final levels = await levelRepositoryFunctions.getLevels(
          token: currentUser.token ?? '',
        );
        
        if (!mounted) return;
        
        // بارگذاری داده‌های دعوت در یک فرآیند async مجزا
        loadInvitationData().then((_) {
          if (mounted) {
            setState(() {
              dataManagerNotifier.value = dataManagerNotifier.value.copyWith(
                levels: levels,
                isLoading: false,
              );
            });
          }
        }).catchError((e) {
          if (mounted) {
            setState(() {
              dataManagerNotifier.value = dataManagerNotifier.value.copyWith(
                levels: levels,
                isLoading: false,
                hasError: true,
                errorMessage: 'Error loading invitation data',
              );
            });
          }
        });
        
      } catch (e) {
        if (mounted) {
          setState(() {
            dataManagerNotifier.value = dataManagerNotifier.value.copyWith(
              isLoading: false,
              hasError: true,
              errorMessage: 'Error loading levels',
            );
          });
        }
      }
      
      _isInitialLoad = false;
    });
  }
  
  Future<void> loadInvitationData() async {
    if (!mounted) return;
    
    try {
      // تلاش با محدودیت زمانی برای هر درخواست
      final firstInvitationFuture = _timeoutFuture(
        invitationRepositoryFunctions.getFirstInvitationUsers(
          token: currentUser.token ?? '',
        ), 
        seconds: 5
      );
      
      final secondInvitationFuture = _timeoutFuture(
        invitationRepositoryFunctions.getSecondInvitationUsers(
          token: currentUser.token ?? '',
        ),
        seconds: 5
      );
      
      final thirdInvitationFuture = _timeoutFuture(
        invitationRepositoryFunctions.getThirdInvitationUsers(
          token: currentUser.token ?? '',
        ),
        seconds: 5
      );
      
      // اجرای موازی درخواست‌ها
      final results = await Future.wait([
        firstInvitationFuture, 
        secondInvitationFuture, 
        thirdInvitationFuture
      ], eagerError: false);
      
      if (!mounted) return;
      
      setState(() {
        dataManagerNotifier.value = dataManagerNotifier.value.copyWith(
          firstInvitationUsers: results[0] as int?,
          secondInvitationUsers: results[1] as int?,
          thirdInvitationUsers: results[2] as int?,
          isLoading: false,
        );
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          dataManagerNotifier.value = dataManagerNotifier.value.copyWith(
            isLoading: false,
            hasError: true,
          );
        });
      }
      rethrow;
    }
  }
  
  // تابع کمکی برای اعمال محدودیت زمانی روی Future
  Future<T?> _timeoutFuture<T>(Future<T> future, {int seconds = 10}) async {
    try {
      return await future.timeout(Duration(seconds: seconds));
    } catch (e) {
      return null;
    }
  }

  void dispositionalDatas() {
    currentLevelValueNotifier.dispose();
    dataManagerNotifier.dispose();
    _refreshDebouncer?.cancel();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppTexts.invitation,
        ),
        actions: [
          // دکمه رفرش
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadAllData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConfigs.mediumVisualDensity,
          ),
          child: ValueListenableBuilder<_InvitationDataManager>(
            valueListenable: dataManagerNotifier,
            builder: (context, dataManager, _) {
              return Column(
                children: [
                  Text(
                    currentUser.level.levelTag,
                    style: AppConfigs.titleTextStyle,
                  ),
                  const CustomSpaceWidget(),
                  
                  // بخش اصلی صفحه
                  if (dataManager.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (dataManager.levels.isEmpty)
                    const CustomErrorWidget()
                  else
                    _buildLevelSlider(dataManager.levels),
                    
                  const CustomSpaceWidget(),
                  Row(
                    children: [
                      Expanded(
                        child: InvitationInformationItemTileWidget(
                          description:
                              '${((double.tryParse(currentUser.totalWins) ?? 0) / AppConfigs.tonBaseFactor).toStringAsFixed(3)} ${AppTexts.tonAmount}',
                          title: AppTexts.totalRebates,
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent.withOpacity(0.3),
                              AppConfigs.appShadowColor,
                            ],
                          ),
                        ),
                      ),
                      const CustomSpaceWidget(
                        sizeDirection: SizeDirection.horizontal,
                      ),
                      Expanded(
                        child: _buildInvitationCard(
                          title: AppTexts.class1Invitee,
                          value: dataManager.firstInvitationUsers,
                          color: AppConfigs.appShadowColor,
                          isLoading: dataManager.isLoading,
                        ),
                      ),
                    ],
                  ),
                  const CustomSpaceWidget(),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInvitationCard(
                          title: AppTexts.class2Invitee,
                          value: dataManager.secondInvitationUsers,
                          color: Colors.pinkAccent.withOpacity(0.3),
                          isLoading: dataManager.isLoading,
                        ),
                      ),
                      const CustomSpaceWidget(
                        sizeDirection: SizeDirection.horizontal,
                      ),
                      Expanded(
                        child: _buildInvitationCard(
                          title: AppTexts.class3Invitee,
                          value: dataManager.thirdInvitationUsers,
                          color: Colors.blue.withOpacity(0.3),
                          isLoading: dataManager.isLoading,
                        ),
                      ),
                    ],
                  ),
                  const CustomSpaceWidget(),
                  CopyInvitationCodeWidget(
                    currentUser: currentUser,
                  ),
                  const CustomSpaceWidget(),
                  // const InvitationInstructionWidget(),
                  const CustomSpaceWidget(),
                  InvitationBackgroundTemplateWidget(
                    child: ListTile(
                      onTap: () {
                        context.tonamed(
                          name: AppPages.myTeamScreen,
                        );
                      },
                      title: const Text(
                        AppTexts.teamReport,
                      ),
                      leading: const Icon(
                        Icons.group,
                        color: Colors.blue,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildLevelSlider(List<LevelModel> levels) {
    return ValueListenableBuilder<double>(
      valueListenable: currentLevelValueNotifier,
      builder: (context, currentLevel, _) {
        final LevelModel currentLevelModel =
            levels.firstWhere((e) => e.id == currentLevel.toInt());
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppConfigs.mediumVisualDensity,
            ),
            gradient: const LinearGradient(
              colors: [
                AppConfigs.darkBlueButtonColor,
                AppConfigs.redColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppConfigs.xxxLargeVisualDensity,
              horizontal: AppConfigs.mediumVisualDensity,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider.adaptive(
                  min: 0,
                  label: currentLevel.toString(),
                  value: currentUser.experience.convertToNum
                      .toDouble(),
                  max: currentLevelModel
                      .expToUpgrade.convertToNum
                      .toDouble(),
                  onChanged: (_) {},
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppTexts.yourLevelIs}$currentLevel',
                    ),
                    Text(
                      '${AppTexts.targetLevel}${currentLevel + 1}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildInvitationCard({
    required String title,
    required int? value,
    required Color color,
    required bool isLoading,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    
    if (value == null) {
      return InvitationInformationItemTileWidget(
        description: 'Error loading data',
        title: title,
        gradient: LinearGradient(
          colors: [
            Colors.transparent.withOpacity(0.3),
            color,
          ],
        ),
      );
    }
    
    return InvitationInformationItemTileWidget(
      description: value.toString(),
      title: title,
      gradient: LinearGradient(
        colors: [
          Colors.transparent.withOpacity(0.3),
          color,
        ],
      ),
    );
  }
}

class InvitationInformationItemTileWidget extends StatelessWidget {
  const InvitationInformationItemTileWidget({
    super.key,
    required this.description,
    required this.gradient,
    required this.title,
  });
  final LinearGradient gradient;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(
          AppConfigs.mediumVisualDensity,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConfigs.mediumVisualDensity,
          vertical: AppConfigs.extraLargeVisualDensity,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            const CustomSpaceWidget(),
            Text(description),
          ],
        ),
      ),
    );
  }
}
