import 'package:flutter/material.dart';
import 'package:one_min_game_repository/one_min_game_repository.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/screens/screens.dart';

class GameThumbItemTileWidget extends StatelessWidget {
  const GameThumbItemTileWidget({
    super.key,
    required this.gameName,
    required this.imagePath,
    required this.gameType,
  });
  final String imagePath;
  final String gameName;
  final GameType gameType;
  
  @override
  Widget build(BuildContext context) {
    // استاندارد کردن اندازه آیکون بر اساس اندازه صفحه
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;
    final double iconSize = isTablet ? 120.0 : 80.0; // اندازه استاندارد آیکون
    
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.to(
            child: OneMinGameScreen(
              gameType: gameType,
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. کانتینر آیکون با سایز استاندارد و افکت سایه
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(height: 8), // فاصله استاندارد بین آیکون و متن
            
            // 2. نام بازی با استایل استاندارد
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                AppTexts.redAndGreenGameText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: isTablet ? 14.0 : 12.0, // اندازه استاندارد متن
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(height: 4), // فاصله کم بین دو متن
            
            // 3. زمان بازی با استایل جذاب‌تر
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppConfigs.yellowColor.withOpacity(0.8),
                    AppConfigs.yellowColor.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                const OneMinGameFunctions().convertGameTypeMinutes(
                  gameType: gameType,
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 13.0 : 11.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
