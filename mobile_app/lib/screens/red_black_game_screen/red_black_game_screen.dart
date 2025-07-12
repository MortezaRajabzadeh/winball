import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:base_repository/base_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:red_black_game_repository/red_black_game_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:winball/bloc/app_bloc/app_bloc.dart';
import 'package:winball/configs/configs.dart';
import 'package:winball/configs/app_configs.dart';
import 'package:winball/enums/enums.dart';
import 'package:winball/extensions/extensions.dart';
import 'package:winball/models/websocket_server_model.dart';
import 'package:winball/utils/functions.dart';
import 'package:winball/widgets/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:user_bet_repository/user_bet_repository.dart';
import 'package:winball/configs/app_configs.dart';
import 'package:winball/configs/app_texts.dart';

class RedBlackGameScreen extends StatefulWidget {
  const RedBlackGameScreen({
    super.key,
    required this.gameType,
  });
  final RedBlackGameType gameType;

  @override
  State<RedBlackGameScreen> createState() => _RedBlackGameScreenState();
}

class _RedBlackGameScreenState extends State<RedBlackGameScreen>
    with TickerProviderStateMixin {
  WebSocketChannel? websocketChannel;
  late final ValueNotifier<bool> canChangeSelectedOptionsValueNotifier;
  late final ValueNotifier<RedBlackWebsocketServerModel>
      currentWebsocketServerModelValueNotifier;
  late final ValueNotifier<RedBlackGameModel> oneLastRedBlackGameModelValueNotifier;
  late final ValueNotifier<int> currentGameTimerValueNotifier;
  late final ValueNotifier<double> amountPerOptionsValueNotifier;
  late final ValueNotifier<bool> isLoadingValueNotifier;
  late final RedBlackGameFunctions redBlackGameFunctions;
  late final Functions functions;
  late final UserRepositoryFunctions userRepositoryFunctions;
  late final TextEditingController amountPerOptionTextEditingController;
  late final ValueNotifier<List<RedBlackUserBetOptions>>
      listOfSelectedUserBetOptionsValueNotifier;
  
  // Animation Controllers
  late AnimationController _timerAnimationController;
  late AnimationController _popupAnimationController;
  late AnimationController _betButtonAnimationController;
  late AnimationController _spinAnimationController;
  late AnimationController _animationController;
  late AnimationController _scanLineAnimationController;
  
  // Animations
  late Animation<double> _timerAnimation;
  late Animation<double> _popupAnimation;
  late Animation<double> _betButtonAnimation;
  late Animation<double> _scanLineAnimation;
  
  UserModel? currentUser;
  Timer? gameSecondsTimer;
  late String debugServerResponse = '';
  bool isBetSubmitted = false;
  bool _isSpinning = false;
  late ValueNotifier<RedBlackGameModel> latestGameNotifier;
  bool showHistoryPopup = false;
  
  // Sample data for history and current game
  List<Map<String, dynamic>> gameHistory = [
    {'number': 902663, 'time': '05:11:30', 'result': 9, 'isRed': false},
    {'number': 902662, 'time': '05:11:00', 'result': 1, 'isRed': true},
    {'number': 902661, 'time': '05:10:30', 'result': 12, 'isRed': false},
    {'number': 902660, 'time': '05:10:00', 'result': 12, 'isRed': false},
    {'number': 902659, 'time': '05:09:30', 'result': 14, 'isRed': false},
    {'number': 902658, 'time': '05:09:00', 'result': 10, 'isRed': false},
    {'number': 902657, 'time': '05:08:30', 'result': 10, 'isRed': false},
    {'number': 902656, 'time': '05:08:00', 'result': 10, 'isRed': false},
    {'number': 902655, 'time': '05:07:30', 'result': 9, 'isRed': false},
    {'number': 902654, 'time': '05:07:00', 'result': 12, 'isRed': false},
  ];
  
  List<int> recentResults = [11, 15, 4, 12, 15, 14, 5, 1, 4];
  String currentGameNumber = "2026801189";
  int currentTimer = 11;
  double userBalance = 0.000;
  String selectedCurrency = "USDT";
  RedBlackUserBetOptions? selectedBetOption;
  double betAmount = 0.0;
  List<int> currentGameResults = [1, 14, 2, 13]; // Only 4 numbers
  String? selectedBettingOption;
  late final ValueNotifier<int> _timerNotifier;

  @override
  void initState() {
    super.initState();
    
    // Initialize ValueNotifiers
    canChangeSelectedOptionsValueNotifier = ValueNotifier(true);
    currentWebsocketServerModelValueNotifier = ValueNotifier(
      RedBlackWebsocketServerModel(
        command: '',
        redBlackGame: RedBlackGameModel(
          id: 1,
          eachGameUniqueNumber: int.parse(currentGameNumber), // Fixed: convert String to int
          gameHash: 'temp_hash',
          gameResult: null,
          gameType: widget.gameType,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        seconds: currentTimer,
      ),
    );
    oneLastRedBlackGameModelValueNotifier = ValueNotifier(
      RedBlackGameModel(
        id: 1,
        eachGameUniqueNumber: int.parse(currentGameNumber), // Fixed: convert String to int
        gameHash: 'temp_hash', // Added required gameHash parameter
        gameResult: null,
        gameType: widget.gameType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    currentGameTimerValueNotifier = ValueNotifier(currentTimer);
    amountPerOptionsValueNotifier = ValueNotifier(0.0);
    isLoadingValueNotifier = ValueNotifier(false);
    listOfSelectedUserBetOptionsValueNotifier = ValueNotifier([]);
    latestGameNotifier = ValueNotifier(
      RedBlackGameModel(
        id: 1,
        eachGameUniqueNumber: int.parse(currentGameNumber), // Fixed: convert String to int
        gameHash: currentGameNumber, // Added required gameHash parameter
        gameResult: null,
        gameType: widget.gameType,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    
    // Initialize controllers
    amountPerOptionTextEditingController = TextEditingController();
    redBlackGameFunctions = RedBlackGameFunctions();
    functions = Functions();
    userRepositoryFunctions = UserRepositoryFunctions();
    
    // Initialize Animation Controllers
    _timerAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _popupAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _betButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _spinAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _scanLineAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _timerNotifier = ValueNotifier(currentTimer);
    
    // Initialize Animations
    _timerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _timerAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _popupAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _popupAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _betButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _betButtonAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _scanLineAnimation = Tween<double>(
      begin: -0.1,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _scanLineAnimationController,
      curve: Curves.linear,
    ));
    
    // Start timer animation
    _timerAnimationController.repeat();
    _animationController.repeat();
    
    // Listen to timer changes
    _timerNotifier.addListener(_onTimerChanged);
    
    // Start the initial timer
    _startTimer();
  }

  @override
  void dispose() {
    _timerAnimationController.dispose();
    _popupAnimationController.dispose();
    _betButtonAnimationController.dispose();
    _spinAnimationController.dispose();
    _animationController.dispose();
    _scanLineAnimationController.dispose();
    _timerNotifier.removeListener(_onTimerChanged);
    _timerNotifier.dispose();
    canChangeSelectedOptionsValueNotifier.dispose();
    currentWebsocketServerModelValueNotifier.dispose();
    oneLastRedBlackGameModelValueNotifier.dispose();
    currentGameTimerValueNotifier.dispose();
    amountPerOptionsValueNotifier.dispose();
    isLoadingValueNotifier.dispose();
    listOfSelectedUserBetOptionsValueNotifier.dispose();
    latestGameNotifier.dispose();
    amountPerOptionTextEditingController.dispose();
    gameSecondsTimer?.cancel();
    super.dispose();
  }

  void _onTimerChanged() {
    if (_timerNotifier.value == 0 && !_isSpinning) {
      // Start spinning when timer reaches 0
      _startSpin();
    }
  }
  
  void _startSpin() {
    setState(() {
      _isSpinning = true;
    });
    
    _spinAnimationController.reset();
    _scanLineAnimationController.reset();
    _scanLineAnimationController.repeat();
    _spinAnimationController.forward().then((_) {
      // Stop scanning line animation
      _scanLineAnimationController.stop();
      // Spin completed, generate new results and restart timer
      _generateNewResults();
      _restartTimer();
      setState(() {
        _isSpinning = false;
      });
    });
  }
  
  void _generateNewResults() {
    // Generate 4 new random numbers for the game
    setState(() {
      currentGameResults = List.generate(4, (index) => Random().nextInt(15) + 1);
    });
  }
  
  void _selectBettingOption(String option) {
    setState(() {
      selectedBettingOption = option;
    });
  }
  
  // Helper methods for number colors
  Color _getNumberBackgroundColor(int number) {
    if (number == 0) return Colors.green;
    if (number >= 1 && number <= 7) return const Color(0xFFE74C3C); // Red
    return const Color(0xFF2C3E50); // Black
  }
  
  Color _getNumberBorderColor(int number) {
    if (number == 0) return Colors.white;
    if (number >= 1 && number <= 7) return Colors.white;
    return Colors.white;
  }
  
  Color _getFixedSpinColor(int index) {
    // Cycle through colors for spinning effect
    List<Color> colors = [
      const Color(0xFFE74C3C), // Red
      const Color(0xFF2C3E50), // Black
      Colors.white,
      const Color(0xFFE74C3C), // Red
    ];
    return colors[index % colors.length];
  }
  
  void _restartTimer() {
    // Restart timer based on game type
    _timerNotifier.value = 30; // or whatever the game duration should be
    _startTimer();
  }
  
  void _startTimer() {
    gameSecondsTimer?.cancel();
    gameSecondsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerNotifier.value > 0) {
        _timerNotifier.value = _timerNotifier.value - 1;
      } else {
        timer.cancel();
      }
    });
  }

  void addOrRemoveUserBetOptionsInListOfUserBetOptions({
    required RedBlackUserBetOptions userBetOptions,
  }) {
    final currentList = List<RedBlackUserBetOptions>.from(
        listOfSelectedUserBetOptionsValueNotifier.value);
    
    if (currentList.contains(userBetOptions)) {
      currentList.remove(userBetOptions);
    } else {
      currentList.add(userBetOptions);
    }
    
    listOfSelectedUserBetOptionsValueNotifier.value = currentList;
    
    setState(() {
      selectedBetOption = currentList.isNotEmpty ? currentList.first : null;
    });
    
    _betButtonAnimationController.forward().then((_) {
      _betButtonAnimationController.reverse();
    });
  }

  void updateUserFromServer() {
    // Implementation for updating user from server
  }
  
  void divideBy3AmountPerOptionTextEditingController() {
    final currentValue = double.tryParse(amountPerOptionTextEditingController.text.replaceAll(',', '.')) ?? 0.0;
    final newValue = currentValue / 3;
    amountPerOptionTextEditingController.text = newValue.toStringAsFixed(3);
    amountPerOptionsValueNotifier.value = newValue;
  }
  
  void multipy3AmountPerOptionTextEditingController() {
    final currentValue = double.tryParse(amountPerOptionTextEditingController.text.replaceAll(',', '.')) ?? 0.0;
    final newValue = currentValue * 3;
    amountPerOptionTextEditingController.text = newValue.toStringAsFixed(3);
    amountPerOptionsValueNotifier.value = newValue;
  }
  
  void changeCanChangeSelectedOptions() {
    // Implementation for changing selected options
  }
  
  void changeAmountPerOptionsValueNotifier({required double value}) {
    setState(() {
      amountPerOptionsValueNotifier.value = value;
    });
  }
  
  void resetGameBet() {
    setState(() {
      selectedBetOption = null;
      betAmount = 0.0;
      amountPerOptionTextEditingController.clear();
      listOfSelectedUserBetOptionsValueNotifier.value = [];
      amountPerOptionsValueNotifier.value = 0.0;
    });
  }
  
  void submitBet() {
    if (selectedBetOption != null && betAmount > 0) {
      setState(() {
        isBetSubmitted = true;
      });
      
      // Add bet submission logic here
      HapticFeedback.lightImpact();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bet submitted: ${selectedBetOption.toString().split('.').last.toUpperCase()} - $betAmount $selectedCurrency'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  void toggleHistoryPopup() {
    setState(() {
      showHistoryPopup = !showHistoryPopup;
    });
    
    if (showHistoryPopup) {
      _popupAnimationController.forward();
    } else {
      _popupAnimationController.reverse();
    }
  }
  
  void adjustBetAmount(double multiplier) {
    setState(() {
      betAmount = betAmount * multiplier;
      if (betAmount < 0.001) betAmount = 0.001;
      amountPerOptionTextEditingController.text = betAmount.toStringAsFixed(3);
    });
  }
  
  Color _getResultColor(int result) {
    // Red numbers: 1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36
    List<int> redNumbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36];
    return redNumbers.contains(result) ? const Color(0xFFE84855) : const Color(0xFF3C4249);
  }
  
  bool _isRedNumber(int result) {
    List<int> redNumbers = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36];
    return redNumbers.contains(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          PopupMenuButton(
            itemBuilder: (context) {
              return List.generate(
                AppConfigs.oneMinGameMoreMenuValues.length,
                (index) {
                  return PopupMenuItem(
                    value: AppConfigs.oneMinGameMoreMenuValues.values.elementAt(index),
                    child: Text(
                      AppConfigs.oneMinGameMoreMenuValues.keys.elementAt(index),
                    ),
                    onTap: () {
                      context.tonamed(
                        name: AppConfigs.oneMinGameMoreMenuValues.values.elementAt(index),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
        title: const Text(
          'Red Black Game',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Column(
                children: [
                  // History Bar - now scrollable and with rounded corners
                  Container(
                    height: 70,
                    margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildHistoryBar(),
                  ),
                  
                  // Current Game Results (includes timer and betting options)
                  _buildCurrentGameResults(),
                  const SizedBox(height: 20),
                  _buildBetInputSection(),
                ],
              ),
            ),
          ),
          // Keep the history popup
          if (showHistoryPopup) _buildHistoryPopup(),
        ],
      ),
    );
  }
  
  Widget _buildHistoryBar() {
    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentResults.length,
            itemBuilder: (context, index) {
              final result = recentResults[index];
              return Container(
                margin: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: toggleHistoryPopup,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getHistoryResultBackgroundColor(result),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getHistoryResultBorderColor(result),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            result.toString(),
                            style: TextStyle(
                              color: _getHistoryResultTextColor(result),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        GestureDetector(
          onTap: toggleHistoryPopup,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF3C4249),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFFFFD700),
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
  
  Color _getHistoryResultBackgroundColor(int result) {
    // Red numbers: 1, 2, 4
    List<int> redNumbers = [1, 2, 4];
    // White numbers: 15
    List<int> whiteNumbers = [15];
    
    if (redNumbers.contains(result)) {
      return const Color(0xFFDC3545);
    } else if (whiteNumbers.contains(result)) {
      return Colors.white;
    } else {
      // Black numbers: 9, 10, 11, 13
      return const Color(0xFF3C4249);
    }
  }
  
  Color _getHistoryResultBorderColor(int result) {
    List<int> whiteNumbers = [15];
    return whiteNumbers.contains(result) ? Colors.black : Colors.white;
  }
  
  Color _getHistoryResultTextColor(int result) {
    List<int> whiteNumbers = [15];
    return whiteNumbers.contains(result) ? Colors.black : Colors.white;
  }
  
  Widget _buildTimerSection() {
    return ValueListenableBuilder<int>(
      valueListenable: currentGameTimerValueNotifier,
      builder: (context, timer, _) {
        return Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  timer.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Game #$currentGameNumber',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildCurrentGameResults() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Timer Section
          ValueListenableBuilder<int>(
            valueListenable: _timerNotifier,
            builder: (context, timer, child) {
              return Column(
                children: [
                  Text(
                    '${timer}s',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'No.$currentGameNumber',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          
          // Spinning Numbers Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A1A),
                  Color(0xFF2A2A2A),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ردیف اعداد
                SizedBox(
                  height: 90,
                  child: _isSpinning
                      ? AnimatedBuilder(
                          animation: _spinAnimationController,
                          builder: (context, child) {
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.zero,
                              itemCount: 20,
                              itemBuilder: (context, index) {
                                // تولید عدد تصادفی برای اسپین
                                int spinNumber = ((_spinAnimationController.value * 100).toInt() + index * 7) % 15 + 1;
                                Color bgColor = _getFixedSpinColor(index % 4);
                                
                                return Container(
                                  width: 80,
                                  margin: const EdgeInsets.only(left: 4.0, right: 4.0),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                    ),
                                    child: Center(
                                      child: Text(
                                        spinNumber.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.zero,
                          itemCount: currentGameResults.length + 16,
                          itemBuilder: (context, index) {
                            int number;
                            if (index < currentGameResults.length) {
                              number = currentGameResults[index];
                            } else {
                              // اعداد تکراری برای پر کردن فضا
                              number = (index % 15) + 1;
                            }
                            
                            Color bgColor = _getNumberBackgroundColor(number);
                            
                            return Container(
                              width: 80,
                              margin: const EdgeInsets.only(left: 4.0, right: 4.0),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                                child: Center(
                                  child: Text(
                                    number.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // خط نشانگر ثابت در وسط
                Container(
                  width: 4,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Betting Options
          Row(
            children: [
              // Red Option
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectBettingOption('red'),
                  child: AnimatedScale(
                    scale: selectedBettingOption == 'red' ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE74C3C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Red',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '1.98x',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // White Option
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectBettingOption('white'),
                  child: AnimatedScale(
                    scale: selectedBettingOption == 'white' ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'White',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '13.87x',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Black Option
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectBettingOption('black'),
                  child: AnimatedScale(
                    scale: selectedBettingOption == 'black' ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C3E50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Black',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '1.98x',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildBettingOptions() {
    return Row(
      children: [
        // Red Option
        Expanded(
          child: AnimatedBuilder(
            animation: _betButtonAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: selectedBetOption == RedBlackUserBetOptions.red
                    ? _betButtonAnimation.value
                    : 1.0,
                child: GestureDetector(
                  onTap: () => addOrRemoveUserBetOptionsInListOfUserBetOptions(
                      userBetOptions: RedBlackUserBetOptions.red),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE84855),
                      borderRadius: BorderRadius.circular(12),
                      border: selectedBetOption == RedBlackUserBetOptions.red
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Red',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '1.98x',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Violet Option (Fixed: replaced white with violet)
        Expanded(
          child: AnimatedBuilder(
            animation: _betButtonAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: selectedBetOption == RedBlackUserBetOptions.white
                    ? _betButtonAnimation.value
                    : 1.0,
                child: GestureDetector(
                  onTap: () => addOrRemoveUserBetOptionsInListOfUserBetOptions(
                      userBetOptions: RedBlackUserBetOptions.white),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: selectedBetOption == RedBlackUserBetOptions.white
                          ? Border.all(color: const Color(0xFFFFD700), width: 3)
                          : null,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'White',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '13.87x',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Black Option
        Expanded(
          child: AnimatedBuilder(
            animation: _betButtonAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: selectedBetOption == RedBlackUserBetOptions.black
                    ? _betButtonAnimation.value
                    : 1.0,
                child: GestureDetector(
                  onTap: () => addOrRemoveUserBetOptionsInListOfUserBetOptions(
                      userBetOptions: RedBlackUserBetOptions.black),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3C4249),
                      borderRadius: BorderRadius.circular(12),
                      border: selectedBetOption == RedBlackUserBetOptions.black
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Black',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '1.98x',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildBetInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Balance Display - مطابق one_min_game_screen
        UserCurrentAmountWidget(
          updateUserFromServer: updateUserFromServer,
        ),
        const CustomSpaceWidget(),
        
        // Bet Amount Input - دقیقاً مشابه one_min_game_screen
        Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: amountPerOptionTextEditingController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9.,]'),
                    replacementString: '0',
                  ),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    // تبدیل ویرگول به نقطه
                    return TextEditingValue(
                      text: newValue.text.replaceAll(',', '.'),
                      selection: newValue.selection,
                    );
                  }),
                ],
                decoration: AppConfigs.customInputDecoration.copyWith(
                  labelText: AppTexts.amountPerOption,
                ),
                onChanged: (value) {
                  final doubleValue = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                  changeAmountPerOptionsValueNotifier(value: doubleValue);
                },
              ),
            ),
            const CustomSpaceWidget(
              sizeDirection: SizeDirection.horizontal,
            ),
            TextButton(
              onPressed: () {
                divideBy3AmountPerOptionTextEditingController();
              },
              child: const Text('/3'),
            ),
            const CustomSpaceWidget(
              sizeDirection: SizeDirection.horizontal,
            ),
            TextButton(
              onPressed: () {
                multipy3AmountPerOptionTextEditingController();
              },
              child: const Text('x3'),
            ),
          ],
        ),
        const CustomSpaceWidget(),
        
        // Bet Summary - دقیقاً مشابه one_min_game_screen
        ValueListenableBuilder<List<RedBlackUserBetOptions>>(
          valueListenable: listOfSelectedUserBetOptionsValueNotifier,
          builder: (context, options, _) {
            return ValueListenableBuilder<double>(
              valueListenable: amountPerOptionsValueNotifier,
              builder: (context, amountPerPage, _) {
                // محدود کردن اعداد اعشاری به 3 رقم برای نمایش بهتر
                final String formattedAmount = amountPerPage.toStringAsFixed(3);
                final String formattedTotal = (options.length * amountPerPage).toStringAsFixed(3);
                
                return Text(
                  '${options.length}x$formattedAmount=$formattedTotal ${context.readAppBloc.state.selectedCoinType == CoinType.stars ? AppTexts.stars : context.readAppBloc.state.selectedCoinType.name}',
                );
              },
            );
          },
        ),
        const CustomSpaceWidget(),
        
        // Action Buttons Row - دقیقاً مشابه one_min_game_screen
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: resetGameBet,
            ),
            ValueListenableBuilder(
              valueListenable: listOfSelectedUserBetOptionsValueNotifier,
              builder: (context, listOfSelectedUserBetOptions, _) {
                return ValueListenableBuilder<double>(
                  valueListenable: amountPerOptionsValueNotifier,
                  builder: (context, amountPerOption, _) {
                    final bool canPlaceBet = listOfSelectedUserBetOptions.isNotEmpty && 
                                           amountPerOption > 0 && 
                                           !isBetSubmitted;
                    
                    return ElevatedButton(
                      onPressed: canPlaceBet ? () {
                        // منطق ثبت شرط‌بندی
                        setState(() {
                          isBetSubmitted = true;
                        });
                        
                        // ارسال شرط‌بندی به سرور
                        HapticFeedback.lightImpact();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'شرط‌بندی ثبت شد: ${listOfSelectedUserBetOptions.map((e) => e.toString().split('.').last.toUpperCase()).join(', ')} - ${(listOfSelectedUserBetOptions.length * amountPerOption).toStringAsFixed(3)} ${context.readAppBloc.state.selectedCoinType == CoinType.stars ? AppTexts.stars : context.readAppBloc.state.selectedCoinType.name}'
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canPlaceBet ? const Color(0xFFFFD700) : Colors.grey,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isBetSubmitted ? 'Bet Placed' : 'Confirm',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }
  

  
  double _getMultiplier() {

    // The switch statement should only handle:
    switch (selectedBetOption) {
      case RedBlackUserBetOptions.red:
      case RedBlackUserBetOptions.black:
        return 1.98;
      case RedBlackUserBetOptions.white:
        return 13.87;
      default:
        return 1.0;
    }
  }
  
  Widget _buildHistoryPopup() {
    return AnimatedBuilder(
      animation: _popupAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _popupAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2B3139),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3C4249),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Game History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: toggleHistoryPopup,
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // History List
                Expanded(
                  child: ListView.builder(
                    itemCount: gameHistory.length,
                    itemBuilder: (context, index) {
                      final game = gameHistory[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Game Number
                            Expanded(
                              flex: 2,
                              child: Text(
                                'No.${game['number']}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            
                            // Time
                            Expanded(
                              flex: 2,
                              child: Text(
                                game['time'],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            
                            // Result
                            Expanded(
                              flex: 1,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _getHistoryResultBackgroundColor(game['result']),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _getHistoryResultBorderColor(game['result']),
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        game['result'].toString(),
                                        style: TextStyle(
                                          color: _getHistoryResultTextColor(game['result']),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}