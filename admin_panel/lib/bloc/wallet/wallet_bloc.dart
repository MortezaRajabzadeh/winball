import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../models/models.dart';
import '../../configs/app_configs.dart';

// Events
abstract class WalletEvent {}

class SaveWalletInfo extends WalletEvent {
  final WalletInfo walletInfo;
  SaveWalletInfo(this.walletInfo);
}

class LoadWalletInfo extends WalletEvent {}

// States
abstract class WalletState {}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final WalletInfo walletInfo;
  WalletLoaded(this.walletInfo);
}

class WalletError extends WalletState {
  final String message;
  WalletError(this.message);
}

// BLoC
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final String baseUrl = AppConfigs.apiBaseUrl;

  WalletBloc() : super(WalletInitial()) {
    on<SaveWalletInfo>((event, emit) async {
      emit(WalletLoading());
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/wallet/save'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'seed_phrase': event.walletInfo.seedPhrase,
            'wallet_address': event.walletInfo.walletAddress,
          }),
        );

        if (response.statusCode == 200) {
          emit(WalletLoaded(event.walletInfo));
        } else {
          final errorData = jsonDecode(response.body);
          emit(WalletError(errorData['error'] ?? 'خطا در ذخیره‌سازی اطلاعات کیف پول'));
        }
      } catch (e) {
        emit(WalletError('خطا در ارتباط با سرور: $e'));
      }
    });

    on<LoadWalletInfo>((event, emit) async {
      emit(WalletLoading());
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/wallet/info'),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final walletInfo = WalletInfo(
            seedPhrase: data['seed_phrase'],
            walletAddress: data['wallet_address'],
          );
          emit(WalletLoaded(walletInfo));
        } else {
          final errorData = jsonDecode(response.body);
          emit(WalletError(errorData['error'] ?? 'خطا در بارگذاری اطلاعات کیف پول'));
        }
      } catch (e) {
        emit(WalletError('خطا در ارتباط با سرور: $e'));
      }
    });
  }
} 