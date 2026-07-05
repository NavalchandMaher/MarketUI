import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/paper_trading_screen.dart';
import 'screens/history_screen.dart';
import 'screens/strategy_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MarketAIApp());
}

class MarketAIApp extends StatelessWidget {
  const MarketAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Market AI V2',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.darkTheme,

      initialRoute: '/',

      routes: {
        '/': (_) => const DashboardScreen(),
        '/analysis': (_) => const AnalysisScreen(),
        '/paper': (_) => const PaperTradingScreen(),
        '/history': (_) => const HistoryScreen(),
        '/strategy': (_) => const StrategyScreen(),
        '/learning': (_) => const LearningScreen(),
        '/reports': (_) => const ReportsScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
