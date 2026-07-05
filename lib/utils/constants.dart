import 'package:flutter/material.dart';

/// ===============================================================
/// App Constants
/// ===============================================================
class AppConstants {
  AppConstants._();

  //==============================================================
  // App
  //==============================================================

  static const String appName = "Market AI V2";
  static const String version = "2.0.0";

  //==============================================================
  // Signals
  //==============================================================

  static const String buy = "BUY";
  static const String sell = "SELL";
  static const String wait = "WAIT";

  //==============================================================
  // Trade Status
  //==============================================================

  static const String open = "OPEN";
  static const String closed = "CLOSED";

  //==============================================================
  // Trade Result
  //==============================================================

  static const String win = "WIN";
  static const String loss = "LOSS";

  //==============================================================
  // Market Regime
  //==============================================================

  static const String trending = "TRENDING";
  static const String ranging = "RANGING";
  static const String volatile = "VOLATILE";

  //==============================================================
  // Higher Timeframe
  //==============================================================

  static const String bullish = "BULLISH";
  static const String bearish = "BEARISH";
  static const String neutral = "NEUTRAL";

  //==============================================================
  // Default Values
  //==============================================================

  static const String defaultSymbol = "BTCUSDT";
  static const String defaultTimeframe = "5m";

  //==============================================================
  // Timeframes
  //==============================================================

  static const List<String> timeframes = [
    "1m",
    "3m",
    "5m",
    "15m",
    "30m",
    "1h",
    "4h",
    "1d",
  ];

  //==============================================================
  // Supported Symbols
  //==============================================================

  static const List<String> symbols = [
    "BTCUSDT",
    "ETHUSDT",
    "BNBUSDT",
    "SOLUSDT",
    "XRPUSDT",
    "DOGEUSDT",
  ];

  //==============================================================
  // Card Radius
  //==============================================================

  static const double radius = 16;

  //==============================================================
  // Padding
  //==============================================================

  static const double padding = 16;
  static const double spacing = 12;

  //==============================================================
  // Elevation
  //==============================================================

  static const double elevation = 3;

  //==============================================================
  // Animation
  //==============================================================

  static const Duration animation = Duration(milliseconds: 300);

  //==============================================================
  // Chart
  //==============================================================

  static const int maxChartCandles = 150;

  //==============================================================
  // Currency
  //==============================================================

  static const String currency = "\$";

  //==============================================================
  // Number Formats
  //==============================================================

  static const int pricePrecision = 2;
  static const int percentPrecision = 2;
}

/// ===============================================================
/// App Colors
/// ===============================================================
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2962FF);

  static const Color secondary = Color(0xFF00C853);

  static const Color background = Color(0xFF0D1117);

  static const Color card = Color(0xFF1C2128);

  static const Color surface = Color(0xFF24292F);

  static const Color buy = Color(0xFF00C853);

  static const Color sell = Color(0xFFD50000);

  static const Color wait = Color(0xFFFFB300);

  static const Color positive = Color(0xFF00E676);

  static const Color negative = Color(0xFFFF5252);

  static const Color warning = Color(0xFFFFC107);

  static const Color info = Color(0xFF29B6F6);

  static const Color textPrimary = Colors.white;

  static const Color textSecondary = Colors.white70;

  static const Color divider = Colors.white12;
}

/// ===============================================================
/// Text Styles
/// ===============================================================
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: AppColors.textPrimary,
  );

  static const TextStyle value = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}
