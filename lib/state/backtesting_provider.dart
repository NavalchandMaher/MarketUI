import 'package:flutter/material.dart';
import '../service_locator.dart';
import '../services/api/v3_api_service.dart';

/// ===============================================================
/// Backtesting Provider - Manages backtest runs and results
/// ===============================================================
class BacktestingProvider extends ChangeNotifier {
  late final V3ApiService _api;

  List<dynamic> _backtestResults = [];
  Map<String, dynamic>? _selectedResult;
  bool _isLoading = false;
  bool _isRunning = false;
  String? _errorMessage;

  BacktestingProvider() {
    _api = getIt<V3ApiService>();
  }

  // ============================================================
  // Getters
  // ============================================================

  List<dynamic> get backtestResults => _backtestResults;
  Map<String, dynamic>? get selectedResult => _selectedResult;
  bool get isLoading => _isLoading;
  bool get isRunning => _isRunning;
  String? get errorMessage => _errorMessage;

  // ============================================================
  // Load Backtest Results History
  // ============================================================

  Future<void> loadResults({
    bool forceRefresh = false,
    int? limit,
    int? offset,
  }) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String endpoint = '/v3/backtest/results';
      final params = <String, String>{};
      if (limit != null) params['limit'] = limit.toString();
      if (offset != null) params['offset'] = offset.toString();

      if (params.isNotEmpty) {
        final queryString = params.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        endpoint = '$endpoint?$queryString';
      }

      final response = await _api.getRequest(endpoint, cacheTtl: 600);
      _backtestResults = response is List ? response : [];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[BACKTESTING] Error loading results: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Get Specific Backtest Result
  // ============================================================

  Future<void> loadResult(String backtestId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedResult =
          await _api.getRequest(
                '/v3/backtest/results/$backtestId',
                cacheTtl: 600,
              )
              as Map<String, dynamic>?;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[BACKTESTING] Error loading result: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Run Backtest
  // ============================================================

  Future<bool> runBacktest({
    required String strategyName,
    required String symbol,
    required String timeframe,
    required DateTime startDate,
    required DateTime endDate,
    double? initialCapital,
  }) async {
    _isLoading = true;
    _isRunning = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final params = {
        'strategy_name': strategyName,
        'symbol': symbol,
        'timeframe': timeframe,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        if (initialCapital != null) 'initial_capital': initialCapital,
      };

      final response = await _api.postRequest('/v3/backtest/run', body: params);

      // Reload results after running backtest
      await loadResults(forceRefresh: true);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('[BACKTESTING] Error running backtest: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      _isRunning = false;
    }
  }

  // ============================================================
  // Delete Backtest Result
  // ============================================================

  Future<bool> deleteResult(String backtestId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.deleteRequest('/v3/backtest/results/$backtestId');

      _backtestResults.removeWhere((r) => r['id'] == backtestId);
      if (_selectedResult?['id'] == backtestId) {
        _selectedResult = null;
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('[BACKTESTING] Error deleting result: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // ============================================================
  // Refresh Results
  // ============================================================

  Future<void> refresh() async {
    await loadResults(forceRefresh: true);
  }

  // ============================================================
  // Clear
  // ============================================================

  void clear() {
    _backtestResults = [];
    _selectedResult = null;
    _isLoading = false;
    _isRunning = false;
    _errorMessage = null;
    notifyListeners();
  }
}
