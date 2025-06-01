part of 'app_bloc.dart';

abstract class AppState {
  final SiteSettingModel siteSettingModel;
  final UserModel currentUser;
  final CoinType selectedCoinType;
  const AppState({
    required this.currentUser,
    required this.selectedCoinType,
    required this.siteSettingModel,
  });
  AppState copyWith({
    UserModel? currentUser,
    CoinType? selectedCoinType,
    SiteSettingModel? siteSettingModel,
  });
}

class InitializingState extends AppState {
  const InitializingState({
    required super.currentUser,
    required super.selectedCoinType,
    required super.siteSettingModel,
  });
  const InitializingState.initializing({
    required super.currentUser,
    required super.selectedCoinType,
    required super.siteSettingModel,
  });
  const InitializingState.initialized({
    required super.currentUser,
    required super.selectedCoinType,
    required super.siteSettingModel,
  });

  @override
  InitializingState copyWith({
    UserModel? currentUser,
    CoinType? selectedCoinType,
    SiteSettingModel? siteSettingModel,
  }) {
    return InitializingState(
      currentUser: currentUser ?? this.currentUser,
      siteSettingModel: siteSettingModel ?? this.siteSettingModel,
      selectedCoinType: selectedCoinType ?? this.selectedCoinType,
    );
  }
}
