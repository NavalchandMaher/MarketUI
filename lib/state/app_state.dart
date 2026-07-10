import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models/analysis_model.dart';
import '../service_locator.dart';
import '../services/api/v3_api_service.dart';
import '../utils/constants.dart';

class AppState extends ChangeNotifier {
  static const _themeModeKey = 'theme_mode';
  static const _symbolKey = 'selected_symbol';
  static const _timeframeKey = 'selected_timeframe';

  late final V3ApiService _api;

  String selectedSymbol = AppConfig.defaultSymbol;
  String selectedTimeframe = AppConfig.defaultTimeframe;
  ThemeMode themeMode = ThemeMode.system;

  bool isLoading = false;
  bool isReady = false;
  String? errorMessage;

  AnalysisModel? analysis;
  Map<String, dynamic>? dashboardData;
  List<dynamic> paperTrades = [];
  Map<String, dynamic>? performance;

  AppState() {
    _api = getIt<V3ApiService>();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadPreferences();
    await refreshHomeData();
    isReady = true;
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final storedTheme = prefs.getString(_themeModeKey);
    final storedSymbol = prefs.getString(_symbolKey);
    final storedTimeframe = prefs.getString(_timeframeKey);

    if (storedTheme != null) {
      themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == storedTheme,
        orElse: () => ThemeMode.system,
      );
    }

    if (storedSymbol != null && storedSymbol.isNotEmpty) {
      selectedSymbol = storedSymbol;
    }

    if (storedTimeframe != null && storedTimeframe.isNotEmpty) {
      selectedTimeframe = storedTimeframe;
    }
  }

  Future<void> _savePreference(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeMode == mode) return;
    themeMode = mode;
    await _savePreference(_themeModeKey, mode.name);
    notifyListeners();
  }

  Future<void> setSymbol(String symbol) async {
    if (selectedSymbol == symbol) return;
    selectedSymbol = symbol;
    await _savePreference(_symbolKey, symbol);
    await refreshHomeData();
  }

  Future<void> setTimeframe(String timeframe) async {
    if (selectedTimeframe == timeframe) return;
    selectedTimeframe = timeframe;
    await _savePreference(_timeframeKey, timeframe);
    await refreshHomeData();
  }

  Future<void> refreshHomeData() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.getAnalysis(symbol: selectedSymbol, timeframe: selectedTimeframe),
        _api.getDashboard(),
        _api.getPaperOpenTrades(),
      ], eagerError: false);

      analysis = results[0] as AnalysisModel;
      dashboardData = results[1] as Map<String, dynamic>?;
      paperTrades = results[2] as List<dynamic>;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double get todayProfitLoss {
    return dashboardData?['today_pl'] ?? 0.0;
  }

  double get currentBalance => dashboardData?['account_balance'] ?? 0.0;
  int get openTrades => dashboardData?['open_trades'] ?? 0;
  int get confidence => analysis?.confidence ?? 0;
  String get signal => analysis?.signal ?? AppConstants.wait;
  double get currentPrice => analysis?.price ?? 0.0;
  String get currentStrategy => dashboardData?['strategy_name'] ?? 'DEFAULT';
  int get strategyVersion => dashboardData?['strategy_version'] ?? 1;
}
