import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models/analysis_model.dart';
import '../service_locator.dart';
import '../services/api/auth_service.dart';
import '../services/api/v3_api_service.dart';
import '../services/network/connectivity_service.dart';
import '../utils/constants.dart';

class AppState extends ChangeNotifier {
  static const _themeModeKey = 'theme_mode';
  static const _symbolKey = 'selected_symbol';
  static const _timeframeKey = 'selected_timeframe';
  static const _autoRefreshKey = 'auto_refresh_enabled';
  static const _refreshIntervalKey = 'refresh_interval_seconds';
  static const _pushNotificationsKey = 'push_notifications_enabled';

  late final AuthService _authService;
  late final V3ApiService _api;
  late final ConnectivityService _connectivityService;
  Timer? _refreshTimer;

  String selectedSymbol = AppConfig.defaultSymbol;
  String selectedTimeframe = AppConfig.defaultTimeframe;
  ThemeMode themeMode = ThemeMode.system;

  bool autoRefreshEnabled = true;
  int refreshIntervalSeconds = 15;
  bool pushNotificationsEnabled = true;
  bool isOnline = true;

  bool isLoading = false;
  bool isRefreshing = false;
  bool isReady = false;
  String? errorMessage;
  String? notificationMessage;

  AnalysisModel? analysis;
  Map<String, dynamic>? dashboardData;
  List<dynamic> paperTrades = [];

  String? _lastSignal;
  Map<String, dynamic>? performance;

  AppState() {
    _authService = getIt<AuthService>();
    _api = getIt<V3ApiService>();
    _connectivityService = getIt<ConnectivityService>();
    _connectivityService.addListener(_onConnectivityChanged);
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadPreferences();
    isOnline = await _connectivityService.checkConnectivity();

    if (_authService.isAuthenticated) {
      await refreshHomeData();
      _startAutoRefresh();
    }

    isReady = true;
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final storedTheme = prefs.getString(_themeModeKey);
    final storedSymbol = prefs.getString(_symbolKey);
    final storedTimeframe = prefs.getString(_timeframeKey);
    final storedAutoRefresh = prefs.getBool(_autoRefreshKey);
    final storedInterval = prefs.getInt(_refreshIntervalKey);

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

    if (storedAutoRefresh != null) {
      autoRefreshEnabled = storedAutoRefresh;
    }

    if (storedInterval != null && storedInterval > 0) {
      refreshIntervalSeconds = storedInterval;
    }

    final storedPushNotifications = prefs.getBool(_pushNotificationsKey);
    if (storedPushNotifications != null) {
      pushNotificationsEnabled = storedPushNotifications;
    }
  }

  Future<void> _savePreference(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _saveBoolPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveIntPreference(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeMode == mode) return;
    themeMode = mode;
    await _savePreference(_themeModeKey, mode.name);
    notifyListeners();
  }

  Future<void> setAutoRefreshEnabled(bool enabled) async {
    if (autoRefreshEnabled == enabled) return;
    autoRefreshEnabled = enabled;
    await _saveBoolPreference(_autoRefreshKey, enabled);
    if (enabled) {
      _startAutoRefresh();
    } else {
      _stopAutoRefresh();
    }
    notifyListeners();
  }

  Future<void> setRefreshInterval(int seconds) async {
    if (refreshIntervalSeconds == seconds || seconds <= 0) return;
    refreshIntervalSeconds = seconds;
    await _saveIntPreference(_refreshIntervalKey, seconds);
    _startAutoRefresh();
    notifyListeners();
  }

  Future<void> setPushNotificationsEnabled(bool enabled) async {
    if (pushNotificationsEnabled == enabled) return;
    pushNotificationsEnabled = enabled;
    await _saveBoolPreference(_pushNotificationsKey, enabled);
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
    if (isLoading || isRefreshing) return;

    if (!_authService.isAuthenticated) {
      errorMessage = 'User is not authenticated';
      if (analysis == null) {
        isLoading = false;
      } else {
        isRefreshing = false;
      }
      notifyListeners();
      return;
    }

    final initialLoad = analysis == null;
    if (initialLoad) {
      isLoading = true;
    } else {
      isRefreshing = true;
    }
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _api.getAnalysis(symbol: selectedSymbol, timeframe: selectedTimeframe),
        _api.getDashboard(),
        _api.getPaperOpenTrades(),
      ], eagerError: false);

      final newAnalysis = results[0] as AnalysisModel;
      dashboardData = results[1] as Map<String, dynamic>?;
      paperTrades = results[2] as List<dynamic>;

      if (_lastSignal != null && _lastSignal != newAnalysis.signal) {
        if (pushNotificationsEnabled) {
          notificationMessage = 'Signal updated: ${newAnalysis.signal}';
        }
      }
      _lastSignal = newAnalysis.signal;
      analysis = newAnalysis;
    } catch (error) {
      errorMessage = error.toString();
      if (analysis == null) {
        // Keep any cached analysis data if available.
      }
    } finally {
      if (initialLoad) {
        isLoading = false;
      } else {
        isRefreshing = false;
      }
      notifyListeners();
    }
  }

  double get todayProfitLoss {
    return dashboardData?['today_pl'] ?? 0.0;
  }

  void clearNotification() {
    notificationMessage = null;
    notifyListeners();
  }

  void _onConnectivityChanged(bool online) {
    if (isOnline == online) return;
    isOnline = online;
    if (online) {
      notificationMessage = 'Back online. Refreshing data.';
      if (_authService.isAuthenticated) {
        refreshHomeData();
      }
    } else {
      if (pushNotificationsEnabled) {
        notificationMessage =
            'Offline mode enabled. Showing cached market data.';
      }
    }
    notifyListeners();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    if (!_authService.isAuthenticated ||
        !autoRefreshEnabled ||
        refreshIntervalSeconds <= 0)
      return;

    _refreshTimer = Timer.periodic(Duration(seconds: refreshIntervalSeconds), (
      _,
    ) {
      if (isOnline && !isLoading) {
        refreshHomeData();
      }
    });
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    _connectivityService.clearListeners();
    super.dispose();
  }

  double get currentBalance => dashboardData?['account_balance'] ?? 0.0;
  int get openTrades => dashboardData?['open_trades'] ?? 0;
  int get confidence => analysis?.confidence ?? 0;
  String get signal => analysis?.signal ?? AppConstants.wait;
  double get currentPrice => analysis?.price ?? 0.0;
  String get currentStrategy => dashboardData?['strategy_name'] ?? 'DEFAULT';
  int get strategyVersion => dashboardData?['strategy_version'] ?? 1;
}
