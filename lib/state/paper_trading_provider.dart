import 'package:flutter/material.dart';
import '../config.dart';
import '../models/paper_trade_model.dart';
import '../service_locator.dart';
import '../services/api/v3_api_service.dart';

/// ===============================================================
/// Paper Trading Provider - Enhanced with CRUD operations
/// ===============================================================
class PaperTradingProvider extends ChangeNotifier {
  late final V3ApiService _api;

  PaperTradeModel? _dashboard;
  List<dynamic> _openTrades = [];
  List<dynamic> _tradingHistory = [];
  Map<String, dynamic>? _statistics;
  bool _isTrading = false;
  bool _isLoading = false;
  String? _errorMessage;

  PaperTradingProvider() {
    _api = getIt<V3ApiService>();
  }

  // ============================================================
  // Getters
  // ============================================================

  PaperTradeModel? get dashboard => _dashboard;
  List<dynamic> get openTrades => _openTrades;
  List<dynamic> get tradingHistory => _tradingHistory;
  Map<String, dynamic>? get statistics => _statistics;
  bool get isTrading => _isTrading;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get totalOpenTrades => _dashboard?.openTrades ?? 0;
  int get totalClosedTrades => _dashboard?.closedTrades ?? 0;
  int get totalWins => _dashboard?.wins ?? 0;
  int get totalLosses => _dashboard?.losses ?? 0;
  double get winRate => _dashboard?.winRate ?? 0;
  double get totalProfit => _dashboard?.totalProfit ?? 0;

  // ============================================================
  // Load Dashboard
  // ============================================================

  Future<void> loadDashboard({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final json = await _api.getPaperStatus();
      _dashboard = PaperTradeModel.fromJson(json);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[PAPER_TRADING] Error loading dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Load Open Trades
  // ============================================================

  Future<void> loadOpenTrades({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.getPaperOpenTrades();
      _openTrades = response is List ? response : [];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[PAPER_TRADING] Error loading open trades: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Load Trading History
  // ============================================================

  Future<void> loadTradingHistory({
    bool forceRefresh = false,
    int? limit,
    int? offset,
    String? symbol,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.getPaperHistory(symbol: symbol, days: limit);
      _tradingHistory = response is List ? response : [];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[PAPER_TRADING] Error loading history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Load Statistics
  // ============================================================

  Future<void> loadStatistics({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _statistics = await _api.getPaperStatistics();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[PAPER_TRADING] Error loading statistics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Start Paper Trading
  // ============================================================

  Future<bool> startPaperTrading({
    required String strategyName,
    String? symbol,
    String? timeframe,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final params = {
        'strategy_name': strategyName,
        if (symbol != null) 'symbol': symbol,
        if (timeframe != null) 'timeframe': timeframe,
      };

      await _api.postRequest('/v3/paper/start', body: params);

      _isTrading = true;
      _errorMessage = null;
      await loadDashboard(forceRefresh: true);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('[PAPER_TRADING] Error starting: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // ============================================================
  // Stop Paper Trading
  // ============================================================

  Future<bool> stopPaperTrading() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.postRequest('/v3/paper/stop');

      _isTrading = false;
      _errorMessage = null;
      await loadDashboard(forceRefresh: true);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('[PAPER_TRADING] Error stopping: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // ============================================================
  // Refresh All Data
  // ============================================================

  Future<void> refresh() async {
    await Future.wait([
      loadDashboard(forceRefresh: true),
      loadOpenTrades(forceRefresh: true),
      loadTradingHistory(forceRefresh: true),
      loadStatistics(forceRefresh: true),
    ]);
  }

  // ============================================================
  // Clear
  // ============================================================

  void clear() {
    _dashboard = null;
    _openTrades = [];
    _tradingHistory = [];
    _statistics = null;
    _isTrading = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
