import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:user_bet_repository/user_bet_repository.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/utils/functions.dart';

class GameRecordsItemTileWidget extends StatelessWidget {
  const GameRecordsItemTileWidget({
    super.key,
    required this.userBet,
    required this.functions,
    required this.userBetOptions,
    required this.oneMinGameResult,
  });

  final UserBetModel userBet;
  final Functions functions;
  final List<UserBetOptions> userBetOptions;
  final OneMinGameResult oneMinGameResult;

  @override
  Widget build(BuildContext context) {
    final bool isWin = userBet.endGameResult.isNotEmpty && userBet.endGameResult.convertToNum > 0;
    final double betAmount = userBet.amount.convertToNum.toDouble();
    final double wonAmount = userBet.endGameResult.convertToNum.toDouble();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2F3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header با مبلغ برد/باخت و نتیجه بازی
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                isWin 
                    ? '+${wonAmount.toStringAsFixed(3)} ${userBet.coinType.name.toUpperCase()}'
                    : '-${betAmount.toStringAsFixed(3)} ${userBet.coinType.name.toUpperCase()}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isWin ? const Color(0xFF00D4AA) : Colors.red,
                ),
              ),
              // نتیجه بازی جای Details
              Text(
                oneMinGameResult.name,
                        style: TextStyle(
                  color: functions.getListOfColorsByGameResult(
                            oneMinGameResult: oneMinGameResult,
                  ).first,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  ),
                ),
            ],
            ),
          const SizedBox(height: 16),
          
          // اطلاعات بازی
          _buildInfoRow('• Game', '${userBet.game.gameType.name} Red_Green'),
          _buildInfoRow('• No.', userBet.game.eachGameUniqueNumber.toString()),
          _buildInfoRow(
            '• Order Time', 
            functions.convertDateTimeToDateAndTime(dateTime: userBet.createdAt),
              ),
          _buildInfoRow(
            '• Betting options', 
            userBetOptions.map((option) => option.name).join(', '),
            valueColor: _getBettingOptionColor(),
          ),
          _buildInfoRow(
            '• Total Amount', 
            '${betAmount.toStringAsFixed(3)} ${userBet.coinType.name.toUpperCase()}',
              ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
              ),
            ),
          ],
      ),
    );
  }

  Color _getBettingOptionColor() {
    // اگر برنده شده، سبز نشان بده
    final bool isWin = userBet.endGameResult.convertToNum > 0;
    if (isWin) {
      return const Color(0xFF00D4AA);
    }
    
    // بر اساس نوع شرط رنگ تعیین کن
    if (userBetOptions.isNotEmpty) {
      final String betName = userBetOptions.first.name.toLowerCase();
      if (betName.contains('red')) {
        return Colors.red;
      } else if (betName.contains('green')) {
        return const Color(0xFF00D4AA);
      } else if (betName.contains('violet')) {
        return Colors.purple;
      }
    }
    
    return Colors.white;
  }
}
