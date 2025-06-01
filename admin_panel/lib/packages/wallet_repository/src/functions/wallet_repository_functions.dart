import 'package:dio/dio.dart';
import '../models/wallet_model.dart';

class WalletRepositoryFunctions {
  const WalletRepositoryFunctions();

  Future<List<WalletModel>> getWallets(String token) async {
    try {
      final response = await Dio().get(
        'http://localhost:3000/api/wallets',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return (response.data as List)
          .map((e) => WalletModel.fromJson(e))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createWallet({
    required String token,
    required String walletAddress,
    required String seedPhrase,
  }) async {
    try {
      await Dio().post(
        'http://localhost:3000/api/wallets',
        data: {
          'walletAddress': walletAddress,
          'seedPhrase': seedPhrase,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateWallet({
    required String token,
    required String id,
    required bool isActive,
  }) async {
    try {
      await Dio().patch(
        'http://localhost:3000/api/wallets/$id',
        data: {
          'isActive': isActive,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteWallet({
    required String token,
    required String id,
  }) async {
    try {
      await Dio().delete(
        'http://localhost:3000/api/wallets/$id',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
} 