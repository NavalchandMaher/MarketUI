import 'package:flutter/material.dart';
import '../config.dart';
import '../service_locator.dart';
import '../services/api/v3_api_service.dart';

/// ===============================================================
/// Learning Logs Provider - Manages learning log entries
/// ===============================================================
class LearningLogsProvider extends ChangeNotifier {
  late final V3ApiService _api;

  List<dynamic> _logs = [];
  Map<String, dynamic>? _selectedLog;
  bool _isLoading = false;
  String? _errorMessage;

  LearningLogsProvider() {
    _api = getIt<V3ApiService>();
  }

  // ============================================================
  // Getters
  // ============================================================

  List<dynamic> get logs => _logs;
  Map<String, dynamic>? get selectedLog => _selectedLog;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get logCount => _logs.length;

  // ============================================================
  // Load Learning Logs
  // ============================================================

  Future<void> loadLogs({
    bool forceRefresh = false,
    int? limit,
    int? offset,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.getLearningLogs(
        strategyId: category,
        days: endDate != null
            ? DateTime.now().difference(endDate).inDays
            : null,
      );
      _logs = response is List ? response : [];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[LEARNING_LOGS] Error loading logs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Get Specific Learning Log
  // ============================================================

  Future<void> loadLog(String logId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedLog = await _api.getLearningLogDetail(logId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[LEARNING_LOGS] Error loading log: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Create Learning Log Entry
  // ============================================================

  Future<bool> createLog({
    required String title,
    required String description,
    required String category,
    Map<String, dynamic>? metadata,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final params = {
        'title': title,
        'description': description,
        'category': category,
        if (metadata != null) 'metadata': metadata,
      };

      final response = await _api.postRequest(
        '${AppConfig.v3Learning}',
        body: params,
      );

      // Reload logs after creating new entry
      await loadLogs(forceRefresh: true);
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('[LEARNING_LOGS] Error creating log: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // ============================================================
  // Update Learning Log Entry
  // ============================================================

  Future<bool> updateLog({
    required String logId,
    required String title,
    required String description,
    required String category,
    Map<String, dynamic>? metadata,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final params = {
        'title': title,
        'description': description,
        'category': category,
        if (metadata != null) 'metadata': metadata,
      };

      final response = await _api.putRequest(
        '${AppConfig.v3Learning}/$logId',
        body: params,
      );

      _selectedLog = response as Map<String, dynamic>?;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('[LEARNING_LOGS] Error updating log: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // ============================================================
  // Delete Learning Log Entry
  // ============================================================

  Future<bool> deleteLog(String logId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.deleteRequest('${AppConfig.v3Learning}/$logId');

      _logs.removeWhere((log) => log['id'] == logId);
      if (_selectedLog?['id'] == logId) {
        _selectedLog = null;
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      print('[LEARNING_LOGS] Error deleting log: $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // ============================================================
  // Refresh Logs
  // ============================================================

  Future<void> refresh() async {
    await loadLogs(forceRefresh: true);
  }

  // ============================================================
  // Clear
  // ============================================================

  void clear() {
    _logs = [];
    _selectedLog = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
