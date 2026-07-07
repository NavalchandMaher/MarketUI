import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'screens/app_shell.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();

  runApp(
    ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: const MarketAIApp(),
    ),
  );
}

class MarketAIApp extends StatelessWidget {
  const MarketAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        return MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.themeMode,
          home: const AppShell(),
        );
      },
    );
  }
}
