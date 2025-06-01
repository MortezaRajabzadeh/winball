part of 'app_bloc.dart';

abstract class AppState {
  final UserModel currentUser;
  const AppState({
    required this.currentUser,
  });
  AppState copyWith({UserModel? currentUser});
}

class InitializedAppState extends AppState {
  const InitializedAppState({
    required super.currentUser,
  });

  @override
  InitializedAppState copyWith({UserModel? currentUser}) {
    return InitializedAppState(
      currentUser: currentUser ?? this.currentUser,
    );
  }
}
