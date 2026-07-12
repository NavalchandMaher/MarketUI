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
  String? _successMessage;

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
  String? get successMessage => _successMessage;

  String get symbol => _symbol;
  String get timeframe => _timeframe;
  int get days => _days;

  // ============================================================
  // Run Backtest
  // ============================================================

  Future<bool> runBacktest({
    required String strategyName,
    required String symbol,
    required String timeframe,
    required DateTime startDate,
    required DateTime endDate,
    double initialCapital = 100000.0,
    double commission = 0.0,
    double slippage = 0.0,
  }) async {
    _isRunning = true;
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _symbol = symbol;
    _timeframe = timeframe;
    _days = endDate.difference(startDate).inDays.clamp(1, 3650);
    notifyListeners();

    try {
      // POST request to async backtest endpoint with parameters
      final response = await _api.postRequest(
        AppConfig.backtestAsync,
        body: {
          'strategy_name': strategyName,
          'symbol': symbol,
          'timeframe': timeframe,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'days': _days,
          'initial_capital': initialCapital,
          'commission': commission,
          'slippage': slippage,
        },
      );

      final backtestId =
          response is Map<String, dynamic> && response['backtest_id'] != null
          ? response['backtest_id'] as String
          : null;

      if (backtestId == null) {
        throw Exception('Backtest start failed');
      }

      const pollInterval = Duration(seconds: 3);
      String status = 'running';
      while (status == 'running') {
        await Future.delayed(pollInterval);
        final stat = await _api.getRequest('/v3/backtest/$backtestId/status');
        if (stat is Map<String, dynamic> && stat['status'] != null) {
          status = stat['status'] as String;
        } else {
          throw Exception('Invalid backtest status response');
        }
      }

      if (status == 'completed') {
        _currentBacktest = await getBacktestDetail(backtestId);
        await loadBacktestHistory(forceRefresh: true);
        _successMessage = 'Backtest completed successfully';
        _errorMessage = null;
        return true;
      }

      throw Exception('Backtest ended with status: $status');
    } catch (e) {
      _successMessage = null;
      _errorMessage = e.toString();
      print('[BACKTEST] Error running backtest: $e');
      return false;
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

  // Retry a failed backtest by re-issuing the async backtest request
  Future<bool> retryBacktest(Map<String, dynamic> backtest) async {
    try {
      final symbol = backtest['symbol'] ?? 'BTCUSDT';
      final timeframe = backtest['timeframe'] ?? '5m';
      int days = backtest['days'] ?? 30;

      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: days));
      if (backtest['start_date'] != null && backtest['end_date'] != null) {
        try {
          startDate = DateTime.parse(backtest['start_date']);
          endDate = DateTime.parse(backtest['end_date']);
        } catch (_) {}
      }

      final strategyName = backtest['strategy_name'] ?? 'Retry Strategy';

      final ok = await runBacktest(
        strategyName: strategyName,
        symbol: symbol,
        timeframe: timeframe,
        startDate: startDate,
        endDate: endDate,
        initialCapital: (backtest['initial_capital'] ?? 100000.0).toDouble(),
        commission: (backtest['commission'] ?? 0.0).toDouble(),
        slippage: (backtest['slippage'] ?? 0.0).toDouble(),
      );

      return ok;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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
