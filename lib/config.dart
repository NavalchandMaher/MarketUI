import 'package:flutter/foundation.dart';

/// ===============================================================
/// Market AI V2 Configuration
/// ===============================================================
class AppConfig {
  AppConfig._();

  //==============================================================
  // Environment
  //==============================================================

  static const bool isProduction = false;

  //==============================================================
  // Base URL
  //==============================================================

  /// Android Emulator
  static const String androidEmulator = "http://10.0.2.2:8000";

  /// iOS Simulator
  static const String iosSimulator = "http://localhost:8000";

  /// Physical Device
  static const String localNetwork = "http://192.168.1.100:8000";

  /// Production
  static const String production = "https://your-production-api.com";

  static String get baseUrl {
    if (isProduction) {
      return production;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidEmulator;
    }

    return iosSimulator;
  }

  //==============================================================
  // Default Market
  //==============================================================

  static const String defaultSymbol = "BTCUSDT";

  static const String defaultTimeframe = "5m";

  static const int defaultBacktestDays = 30;

  //==============================================================
  // Refresh
  //==============================================================

  static const Duration dashboardRefresh = Duration(seconds: 30);

  static const Duration analysisRefresh = Duration(minutes: 1);

  static const Duration schedulerRefresh = Duration(seconds: 20);

  //==============================================================
  // Timeouts
  //==============================================================

  static const Duration apiTimeout = Duration(seconds: 30);

  //==============================================================
  // API Endpoints
  //==============================================================

  static const String analysis = "/analysis";

  static const String paperTrades = "/paper-trades";

  static const String paperTradeHistory = "/paper-trades/history";

  static const String strategy = "/strategy";

  static const String performance = "/performance";

  static const String learningLogs = "/learning-logs";

  static const String backtest = "/backtest";

  static const String backtestHistory = "/backtest/history";

  static const String schedulerStatus = "/scheduler/status";

  static const String schedulerDashboard = "/scheduler/dashboard";

  static const String runMarket = "/scheduler/run-market";

  static const String runNightly = "/scheduler/run-nightly";

  //==============================================================
  // Theme
  //==============================================================

  static const bool darkMode = true;

  //==============================================================
  // Chart
  //==============================================================

  static const int maxChartCandles = 150;

  //==============================================================
  // Trading
  //==============================================================

  static const double defaultCapital = 100000;

  static const double riskPerTrade = 2.0;

  //==============================================================
  // App
  //==============================================================

  static const String appName = "Market AI V2";

  static const String version = "2.0.0";

  static const bool enableLogs = true;
}
