import 'package:flutter/material.dart';
import '../models/strategy_model.dart';
import '../service_locator.dart';
import '../services/api/v3_api_service.dart';

/// ===============================================================
/// Strategies Provider - Manages strategy CRUD operations
/// ===============================================================
class StrategiesProvider extends ChangeNotifier {
  late final V3ApiService _api;

  List<StrategyModel> _strategies = [];
  StrategyModel? _selectedStrategy;
  bool _isLoading = false;
  String? _errorMessage;

  StrategiesProvider() {
    _api = getIt<V3ApiService>();
  }

  // ============================================================
  // Getters
  // ============================================================

  List<StrategyModel> get strategies => _strategies;
  StrategyModel? get selectedStrategy => _selectedStrategy;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get strategyCount => _strategies.length;

  // ============================================================
  // Load Strategies
  // ============================================================

  Future<void> loadStrategies({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.getStrategies(forceRefresh: forceRefresh);
      _strategies = result
          .map(
            (s) => s is StrategyModel
                ? s
                : StrategyModel.fromJson(s as Map<String, dynamic>),
          )
          .toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[STRATEGIES] Error loading strategies: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Select Strategy
  // ============================================================

  void selectStrategy(StrategyModel strategy) {
    _selectedStrategy = strategy;
    notifyListeners();
  }

  void clearSelection() {
    _selectedStrategy = null;
    notifyListeners();
  }

  // ============================================================
  // Create Strategy
  // ============================================================

  Future<bool> createStrategy({
    required String name,
    required int buyThreshold,
    required int sellThreshold,
    required double tpPercent,
    required double slPercent,
    required int emaFast,
    required int emaSlow,
    required int rsiBuy,
    required int rsiSell,
  }) async {
    final strategyData = {
      'strategy_name': name,
      'version': 1,
      'enabled': true,
      'paper_mode': true,
      'live_mode': false,
      'priority': 1,
      'symbol': 'BTCUSDT',
      'timeframe': '5m',
      'risk_percent': 1.0,
      'tp': tpPercent,
      'sl': slPercent,
      'indicator_parameters': {
        'buy_threshold': buyThreshold,
        'sell_threshold': sellThreshold,
        'ema_fast': emaFast,
        'ema_slow': emaSlow,
        'rsi_buy': rsiBuy,
        'rsi_sell': rsiSell,
      },
    };
    return await createStrategyFromPayload(strategyData);
  }

  Future<bool> createStrategyFromPayload(Map<String, dynamic> payload) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.createStrategy(payload);

      final newStrategy = StrategyModel.fromJson(response);
      _strategies.add(newStrategy);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('[STRATEGIES] Error creating strategy: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // ============================================================
  // Update Strategy
  // ============================================================

  Future<bool> updateStrategy({
    required String id,
    required String name,
    required int buyThreshold,
    required int sellThreshold,
    required double tpPercent,
    required double slPercent,
    required int emaFast,
    required int emaSlow,
    required int rsiBuy,
    required int rsiSell,
  }) async {
    final strategyData = {
      'strategy_name': name,
      'version': 1,
      'enabled': true,
      'paper_mode': true,
      'live_mode': false,
      'priority': 1,
      'symbol': 'BTCUSDT',
      'timeframe': '5m',
      'risk_percent': 1.0,
      'tp': tpPercent,
      'sl': slPercent,
      'indicator_parameters': {
        'buy_threshold': buyThreshold,
        'sell_threshold': sellThreshold,
        'ema_fast': emaFast,
        'ema_slow': emaSlow,
        'rsi_buy': rsiBuy,
        'rsi_sell': rsiSell,
      },
    };
    return await updateStrategyFromPayload(id, strategyData);
  }

  Future<bool> updateStrategyFromPayload(
    String id,
    Map<String, dynamic> payload,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.updateStrategy(id, payload);

      final updated = StrategyModel.fromJson(response);
      final index = _strategies.indexWhere((s) => s.id == id);
      if (index >= 0) {
        _strategies[index] = updated;
      }
      if (_selectedStrategy?.id == id) {
        _selectedStrategy = updated;
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('[STRATEGIES] Error updating strategy: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  Future<Map<String, dynamic>> getStrategyPayload(
    String id, {
    bool forceRefresh = false,
  }) async {
    return await _api.getStrategy(id, forceRefresh: forceRefresh);
  }

  // ============================================================
  // Delete Strategy
  // ============================================================

  Future<bool> deleteStrategy(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.deleteStrategy(id);

      _strategies.removeWhere((s) => s.id == id);
      if (_selectedStrategy?.id == id) {
        _selectedStrategy = null;
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('[STRATEGIES] Error deleting strategy: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // ============================================================
  // Refresh Strategies
  // ============================================================

  Future<void> refresh() async {
    await loadStrategies(forceRefresh: true);
  }

  // ============================================================
  // Clear
  // ============================================================

  void clear() {
    _strategies = [];
    _selectedStrategy = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
