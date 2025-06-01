import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:winball/bloc/app_bloc/app_bloc.dart';
import 'package:winball/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:winball/configs/configs.dart';
import 'package:database_repository_functions/database_repository_functions.dart';
import 'package:telegram_web_app/telegram_web_app.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:qr_flutter/qr_flutter.dart';

// لینک پیش‌فرض برای QR کد
const String defaultAppUrl = 'https://t.me/Win_ball_bot/Winball';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  if (isDesktopPlatform()) {
    runApp(const DesktopApp());
    return;
  }

  // فقط در موبایل از Splash استفاده می‌کنیم
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  const String path = '/';
  const DatabaseRepositoryFunctions().initHiveDb(path: path);

  runApp(const MobileApp());
}

bool isDesktopPlatform() {
  if (!kIsWeb) return false;

  try {
    final webApp = TelegramWebApp.instance;
    if (!webApp.isSupported) return false;

    final platform = webApp.platform?.trim().toLowerCase();
    if (platform == null || platform.isEmpty) return false;

    final isDesktop = platform.contains('tdesktop') || platform.contains('macos');
    return isDesktop;
  } catch (e) {
    return false;
  }
}

String getFormattedUrl() {
  try {
    final uri = Uri.base;
    if (uri.host.isEmpty || uri.scheme.isEmpty || !uri.hasAuthority) {
      return defaultAppUrl;
    }
    return '${uri.scheme}://${uri.host}${uri.path}';
  } catch (e) {
    return defaultAppUrl;
  }
}

class DesktopApp extends StatelessWidget {
  const DesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const Scaffold(
        backgroundColor: Color(0xFF1B1D2B),
        body: DesktopScreen(),
      ),
    );
  }
}

class DesktopScreen extends StatelessWidget {
  const DesktopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUrl = getFormattedUrl();
    final bool showQrCode = currentUrl.isNotEmpty && currentUrl != defaultAppUrl;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // لوگو
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.sports_soccer, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'WinBall',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),

            // QR Code فقط اگر لازم باشد نمایش داده شود
            if (showQrCode) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: currentUrl,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
            ],

            // متن راهنما
            Text(
              'Please use mobile version',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Scan QR code with your mobile device',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class MobileApp extends StatefulWidget {
  const MobileApp({super.key});

  @override
  State<MobileApp> createState() => _MobileAppState();
}

class _MobileAppState extends State<MobileApp> {
  bool _isSplashRemoved = false;

  @override
  void initState() {
    super.initState();
    _removeSplashScreen();
  }

  void _removeSplashScreen() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      FlutterNativeSplash.remove();
      setState(() => _isSplashRemoved = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // نمایش لودینگ در صورت عدم حذف Splash
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppBloc()),
        BlocProvider(create: (context) => AuthenticationBloc(appBloc: context.read<AppBloc>())),
      ],
      child: MaterialApp(
        title: 'WinBall',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          useMaterial3: true,
          outlinedButtonTheme: AppConfigs.outlinedButtonThemeData,
          textTheme: Typography().white.apply(fontFamily: AppConfigs.fontFamily),
          appBarTheme: const AppBarTheme(centerTitle: true),
        ),
        initialRoute: AppPages.authenticationControllerScreen,
        onGenerateRoute: PagesRoutes.onGenerateRoutes,
        scrollBehavior: const ApplicationScrollBehavior(),
      ),
    );
  }
}
