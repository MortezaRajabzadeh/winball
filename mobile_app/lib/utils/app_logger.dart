import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLogger {
  static final List<String> _logs = [];
  static bool _showLogs = true; // Set to false in production

  static void log(String message, {String tag = 'APP'}) {
    final logMessage = '[$tag] $message';
    if (_showLogs) {
      if (kDebugMode) {
        debugPrint(logMessage);
      }
      // Keep only last 100 logs to avoid memory issues
      if (_logs.length > 100) {
        _logs.removeAt(0);
      }
      _logs.add('${DateTime.now().toIso8601String()}: $logMessage');
    }
  }

  static List<String> get logs => List.unmodifiable(_logs);
  
  static void clear() => _logs.clear();
}

class DebugLogViewer extends StatelessWidget {
  const DebugLogViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8.0),
      ),
      constraints: const BoxConstraints(maxHeight: 200),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Debug Logs',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    AppLogger.clear();
                    // ignore: invalid_use_of_protected_member
                    (context as Element).markNeedsBuild();
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 8),
            ...AppLogger.logs.reversed.map((log) => Text(
                  log,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
