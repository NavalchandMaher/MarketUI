import 'package:flutter/material.dart';
import '../config.dart';
import '../service_locator.dart';
import '../services/api/v3_api_service.dart';

/// ===============================================================
/// Backtest Provider - Backtest execution and history management
/// ===============================================================
class BacktestProvider extends ChangeNotifier {
  late final V3ApiService _api;

  Map<String, dynamic>? _currentBacktest;
  List<dynamic> _backtestHistory = [];
  bool _isRunning = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Backtest parameters
  String _symbol = "BTCUSDT";
  String _timeframe = "5m";
  int _days = 30;

  BacktestProvider() {
    _api = getIt<V3ApiService>();
  }

  // ============================================================
  // Getters
  // ============================================================

  Map<String, dynamic>? get currentBacktest => _currentBacktest;
  List<dynamic> get backtestHistory => _backtestHistory;
  bool get isRunning => _isRunning;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get symbol => _symbol;
  String get timeframe => _timeframe;
  int get days => _days;

  // ============================================================
  // Run Backtest
  // ============================================================

  Future<void> runBacktest({
    String symbol = "BTCUSDT",
    String timeframe = "5m",
    int days = 30,
  }) async {
    _isRunning = true;
    _isLoading = true;
    _errorMessage = null;
    _symbol = symbol;
    _timeframe = timeframe;
    _days = days;
    notifyListeners();

    try {
      // POST request to /v3/backtest/run with parameters
      final json = await _api.postRequest(
        '/v3/backtest/run',
        body: {'symbol': symbol, 'timeframe': timeframe, 'days': days},
      );
      _currentBacktest = json;
      _errorMessage = null;
      print('[BACKTEST] Backtest completed: $symbol $timeframe for $days days');
    } catch (e) {
      _errorMessage = e.toString();
      print('[BACKTEST] Error running backtest: $e');
    } finally {
      _isRunning = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Load Backtest History
  // ============================================================

  Future<void> loadBacktestHistory({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.getRequest(
        '/v3/backtest/history',
        cacheTtl: 300, // Cache for 5 minutes
        forceRefresh: forceRefresh,
      );
      _backtestHistory = response is List ? response : [];
      _errorMessage = null;
      print('[BACKTEST] Loaded ${_backtestHistory.length} backtest results');
    } catch (e) {
      _errorMessage = e.toString();
      print('[BACKTEST] Error loading history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Get Backtest Details
  // ============================================================

  Future<Map<String, dynamic>?> getBacktestDetail(String backtestId) async {
    try {
      final response = await _api.getRequest(
        '/v3/backtest/$backtestId',
        cacheTtl: 300,
      );
      return response is Map<String, dynamic> ? response : null;
    } catch (e) {
      print('[BACKTEST] Error fetching backtest detail: $e');
      return null;
    }
  }

  // ============================================================
  // Delete Backtest
  // ============================================================

  Future<bool> deleteBacktest(String backtestId) async {
    try {
      await _api.deleteRequest('/v3/backtest/$backtestId');
      _backtestHistory.removeWhere((item) => item['id'] == backtestId);
      notifyListeners();
      print('[BACKTEST] Deleted backtest: $backtestId');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('[BACKTEST] Error deleting backtest: $e');
      return false;
    }
  }

  // ============================================================
  // Utilities
  // ============================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _currentBacktest = null;
    _backtestHistory = [];
    _isRunning = false;
    _isLoading = false;
    _errorMessage = null;
    _symbol = "BTCUSDT";
    _timeframe = "5m";
    _days = 30;
    notifyListeners();
  }
}
