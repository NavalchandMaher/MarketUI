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
  List<dynamic> _strategies = [];
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
  List<dynamic> get strategies => _strategies;
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
  }) {
    return runBacktests(
      strategyNames: [strategyName],
      symbols: [symbol],
      timeframes: [timeframe],
      startDate: startDate,
      endDate: endDate,
      initialCapital: initialCapital,
      commission: commission,
      slippage: slippage,
    );
  }

  /// Runs every selected strategy, symbol, and timeframe combination one at
  /// a time. The API currently accepts one combination per backtest job.
  Future<bool> runBacktests({
    required Iterable<String> strategyNames,
    required Iterable<String> symbols,
    required Iterable<String> timeframes,
    required DateTime startDate,
    required DateTime endDate,
    double initialCapital = 100000.0,
    double commission = 0.0,
    double slippage = 0.0,
  }) async {
    final strategies = strategyNames
        .where((value) => value.trim().isNotEmpty)
        .toSet();
    final selectedSymbols = symbols
        .where((value) => value.trim().isNotEmpty)
        .toSet();
    final selectedTimeframes = timeframes
        .where((value) => value.trim().isNotEmpty)
        .toSet();

    if (strategies.isEmpty ||
        selectedSymbols.isEmpty ||
        selectedTimeframes.isEmpty) {
      _errorMessage =
          'Select at least one strategy, trading symbol, and timeframe.';
      notifyListeners();
      return false;
    }

    _isRunning = true;
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _days = endDate.difference(startDate).inDays.clamp(1, 3650);
    notifyListeners();

    final failures = <String>[];
    var completed = 0;
    try {
      for (final strategyName in strategies) {
        for (final symbol in selectedSymbols) {
          for (final timeframe in selectedTimeframes) {
            _symbol = symbol;
            _timeframe = timeframe;
            try {
              _currentBacktest = await _runSingleBacktest(
                strategyName: strategyName,
                symbol: symbol,
                timeframe: timeframe,
                startDate: startDate,
                endDate: endDate,
                initialCapital: initialCapital,
                commission: commission,
                slippage: slippage,
              );
              completed++;
            } catch (error) {
              failures.add('$strategyName / $symbol / $timeframe: $error');
            }
          }
        }
      }

      await loadBacktestHistory(forceRefresh: true);
      final total =
          strategies.length * selectedSymbols.length * selectedTimeframes.length;
      if (completed == 0) {
        _errorMessage = failures.isEmpty
            ? 'No backtests completed.'
            : 'No backtests completed. ${failures.first}';
        return false;
      }

      _successMessage = failures.isEmpty
          ? '$completed backtest${completed == 1 ? '' : 's'} completed successfully.'
          : '$completed of $total backtests completed. ${failures.length} failed.';
      _errorMessage = failures.isEmpty ? null : failures.first;
      return failures.isEmpty;
    } catch (error) {
      _successMessage = null;
      _errorMessage = error.toString();
      print('[BACKTEST] Error running backtests: $error');
      return false;
    } finally {
      _isRunning = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> _runSingleBacktest({
    required String strategyName,
    required String symbol,
    required String timeframe,
    required DateTime startDate,
    required DateTime endDate,
    required double initialCapital,
    required double commission,
    required double slippage,
  }) async {
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
    if (backtestId == null) throw Exception('Backtest start failed');

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
    if (status != 'completed') {
      throw Exception('Backtest ended with status: $status');
    }
    return getBacktestDetail(backtestId);
  }

  // ============================================================
  // Load Backtest History
  // ============================================================

  Future<void> loadStrategies({bool forceRefresh = false}) async {
    try {
      final response = await _api.getStrategies(forceRefresh: forceRefresh);
      _strategies = response is List ? response : [];
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      print('[BACKTEST] Error loading strategies: $e');
    }
  }

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
    _strategies = [];
    _isRunning = false;
    _isLoading = false;
    _errorMessage = null;
    _symbol = "BTCUSDT";
    _timeframe = "5m";
    _days = 30;
    notifyListeners();
  }
}
