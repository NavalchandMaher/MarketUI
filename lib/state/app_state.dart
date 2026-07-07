import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models/analysis_model.dart';
import '../models/performance_model.dart';
import '../models/paper_trade_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AppState extends ChangeNotifier {
  static const _themeModeKey = 'theme_mode';
  static const _symbolKey = 'selected_symbol';
  static const _timeframeKey = 'selected_timeframe';

  final ApiService _api = ApiService.instance;

  String selectedSymbol = AppConfig.defaultSymbol;
  String selectedTimeframe = AppConfig.defaultTimeframe;
  ThemeMode themeMode = ThemeMode.system;

  bool isLoading = false;
  bool isReady = false;
  String? errorMessage;

  AnalysisModel? analysis;
  PerformanceModel? performance;
  PaperTradeModel? paperTrade;

  AppState() {
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
        _api.getPerformance(),
        _api.getPaperTrades(),
      ]);

      analysis = results[0] as AnalysisModel;
      performance = results[1] as PerformanceModel;
      paperTrade = results[2] as PaperTradeModel;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double get todayProfitLoss {
    if (performance == null || performance!.daily.isEmpty) {
      return 0;
    }

    final last = performance!.daily.last;
    if (last is Map<String, dynamic>) {
      final value =
          last['profit'] ?? last['net_profit'] ?? last['pnl'] ?? last['close'];
      if (value is num) return value.toDouble();
    }

    if (last is num) return last.toDouble();
    return 0;
  }

  double get currentBalance => performance?.account.currentBalance ?? 0;
  int get openTrades => paperTrade?.openTrades ?? 0;
  int get confidence => analysis?.confidence ?? 0;
  String get signal => analysis?.signal ?? AppConstants.wait;
  double get currentPrice => analysis?.price ?? 0;
}
