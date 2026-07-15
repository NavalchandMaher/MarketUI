import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config.dart';
import 'screens/responsive_app_shell.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'service_locator.dart';
import 'state/app_state.dart';
import 'state/auth_state.dart';
import 'state/account_provider.dart';
import 'state/settings_provider.dart';
import 'state/strategies_provider.dart';
import 'state/paper_trading_provider.dart';
import 'state/reports_provider.dart';
import 'state/learning_logs_provider.dart';
import 'state/backtest_provider.dart';
import 'state/scheduler_provider.dart';
import 'theme/app_theme.dart';
import 'strategy_builder/screens/strategy_builder_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator (Dependency Injection)
  await setupServiceLocator();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => AppState()),
        // Feature Providers - provide singleton instances from getIt
        ChangeNotifierProvider<AccountProvider>(
          create: (_) => getIt<AccountProvider>(),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => getIt<SettingsProvider>(),
        ),
        ChangeNotifierProvider<StrategiesProvider>(
          create: (_) => getIt<StrategiesProvider>(),
        ),
        ChangeNotifierProvider<PaperTradingProvider>(
          create: (_) => getIt<PaperTradingProvider>(),
        ),
        ChangeNotifierProvider<ReportsProvider>(
          create: (_) => getIt<ReportsProvider>(),
        ),
        ChangeNotifierProvider<LearningLogsProvider>(
          create: (_) => getIt<LearningLogsProvider>(),
        ),
        ChangeNotifierProvider<BacktestProvider>(
          create: (_) => getIt<BacktestProvider>(),
        ),
        ChangeNotifierProvider<SchedulerProvider>(
          create: (_) => getIt<SchedulerProvider>(),
        ),
      ],
      child: const MarketAIApp(),
    ),
  );
}

class MarketAIApp extends StatelessWidget {
  const MarketAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, AuthState>(
      builder: (context, appState, authState, child) {
        return MaterialApp(
          title: AppConfig.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appState.themeMode,
          home: const SplashScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/home': (context) => const ResponsiveAppShell(),
            '/strategy-builder': (context) => const StrategyBuilderScreen(),
          },
        );
      },
    );
  }
}
