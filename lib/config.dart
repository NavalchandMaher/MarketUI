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
  // Use emulator loopback address so Android emulators can reach host
  // (10.0.2.2 for Android Emulator / AVD). If using a physical device,
  // set `localNetwork` to your machine IP and toggle `baseUrl` accordingly.
  static const String androidEmulator = "http://10.0.2.2:10000";

  /// iOS Simulator
  static const String iosSimulator = "http://localhost:10000";

  /// Physical Device
  static const String localNetwork = "http://192.168.1.100:10000";

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
  // API Endpoints - Auth
  //==============================================================

  static const String register = "/auth/register";

  static const String login = "/auth/login";

  static const String refresh = "/auth/refresh";

  static const String logout = "/auth/logout";

  static const String forgotPassword = "/auth/forgot-password";

  static const String resetPassword = "/auth/reset-password";

  static const String changePassword = "/auth/change-password";

  static const String currentUser = "/users/me";
  static const String users = "/users";

  //==============================================================
  // API Endpoints - V3
  //==============================================================

  static const String v3Dashboard = "/v3/dashboard";

  static const String v3Strategies = "/v3/strategies";

  static const String v3AdminStrategies = "/v3/admin/strategies";

  static const String v3Paper = "/v3/paper";

  static const String v3Backtest = "/v3/backtest";

  static const String v3Reports = "/v3/reports";

  static const String v3Learning = "/v3/learning";

  static const String v3Settings = "/v3/settings";

  static const String v3Account = "/v3/account";

  static const String v3Symbols = "/v3/symbols";

  static const String v3Timeframes = "/v3/timeframes";

  //==============================================================
  // API Endpoints - V3 (Legacy endpoints replaced with V3)
  //==============================================================

  static const String analysis = "/v3/analysis";

  static const String paperTrades = "/v3/paper/open";

  static const String paperTradeHistory = "/v3/paper/history";

  static const String strategy = "/v3/strategies";

  static const String performance = "/v3/reports/performance";

  static const String learningLogs = "/v3/learning";

  static const String backtest = "/v3/backtest/run";
  // Async backtest endpoint (starts job and returns backtest_id)
  static const String backtestAsync = "/v3/backtest/async";

  static const String backtestHistory = "/v3/backtest/history";

  static const String schedulerStatus = "/v3/scheduler/status";

  static const String schedulerDashboard = "/v3/scheduler/dashboard";

  static const String runMarket = "/v3/scheduler/run-market";

  static const String runNightly = "/v3/scheduler/run-nightly";

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

  static const String appName = "Market AI V3";

  static const String version = "3.0.0";

  static const bool enableLogs = true;
}
