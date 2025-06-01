import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:winball_admin_panel/bloc/app_bloc/app_bloc.dart';
import 'package:winball_admin_panel/bloc/authentication_bloc/authentication_bloc.dart';
import 'package:winball_admin_panel/configs/configs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AppBloc(),
        ),
        BlocProvider(
          create: (_) => AuthenticationBloc(
            appBloc: AppBloc(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Winball Admin Panel',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          // scaffoldBackgroundColor: AppConfigs.applicationBackgroundMaterialColor,
          elevatedButtonTheme: const ElevatedButtonThemeData(
            style: ButtonStyle(
              foregroundColor: WidgetStatePropertyAll<Color>(
                Colors.black,
              ),
              backgroundColor: WidgetStatePropertyAll<Color>(
                AppConfigs.yellowColor,
              ),
            ),
          ),
          primaryColor: AppConfigs.applicationBackgroundMaterialColor,
          useMaterial3: true,
        ),
        onGenerateRoute: PagesRoutes.onGenerateRoutes,
      ),
    );
  }
}
