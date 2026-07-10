import 'package:flutter/material.dart';
import '../service_locator.dart';
import '../services/api/v3_api_service.dart';

/// ===============================================================
/// Reports Provider - Manages all report types and filtering
/// ===============================================================
class ReportsProvider extends ChangeNotifier {
  late final V3ApiService _api;

  Map<String, dynamic>? _dashboardReport;
  Map<String, dynamic>? _dailyReport;
  Map<String, dynamic>? _monthlyReport;
  Map<String, dynamic>? _equityReport;
  Map<String, dynamic>? _performanceReport;
  bool _isLoading = false;
  String? _errorMessage;

  ReportsProvider() {
    _api = getIt<V3ApiService>();
  }

  // ============================================================
  // Getters
  // ============================================================

  Map<String, dynamic>? get dashboardReport => _dashboardReport;
  Map<String, dynamic>? get dailyReport => _dailyReport;
  Map<String, dynamic>? get monthlyReport => _monthlyReport;
  Map<String, dynamic>? get equityReport => _equityReport;
  Map<String, dynamic>? get performanceReport => _performanceReport;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ============================================================
  // Load Dashboard Report
  // ============================================================

  Future<void> loadDashboardReport({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardReport =
          await _api.getDashboard(forceRefresh: forceRefresh)
              as Map<String, dynamic>?;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[REPORTS] Error loading dashboard report: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Load Daily Report
  // ============================================================

  Future<void> loadDailyReport({
    required DateTime date,
    bool forceRefresh = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dateStr = date.toIso8601String().split('T')[0];
      _dailyReport =
          await _api.getRequest(
                '/v3/reports/daily?date=$dateStr',
                cacheTtl: forceRefresh ? 0 : 300,
              )
              as Map<String, dynamic>?;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[REPORTS] Error loading daily report: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Load Monthly Report
  // ============================================================

  Future<void> loadMonthlyReport({
    required int year,
    required int month,
    bool forceRefresh = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final monthStr = '$year-${month.toString().padLeft(2, '0')}';
      _monthlyReport =
          await _api.getRequest(
                '/v3/reports/monthly?month=$monthStr',
                cacheTtl: forceRefresh ? 0 : 300,
              )
              as Map<String, dynamic>?;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[REPORTS] Error loading monthly report: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Load Equity Report
  // ============================================================

  Future<void> loadEquityReport({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _equityReport =
          await _api.getRequest(
                '/v3/reports/equity',
                cacheTtl: forceRefresh ? 0 : 300,
              )
              as Map<String, dynamic>?;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[REPORTS] Error loading equity report: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Load Performance Report
  // ============================================================

  Future<void> loadPerformanceReport({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _performanceReport =
          await _api.getRequest(
                '/v3/reports/performance',
                cacheTtl: forceRefresh ? 0 : 300,
              )
              as Map<String, dynamic>?;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      print('[REPORTS] Error loading performance report: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Refresh All Reports
  // ============================================================

  Future<void> refreshAll() async {
    await Future.wait([
      loadDashboardReport(forceRefresh: true),
      loadEquityReport(forceRefresh: true),
      loadPerformanceReport(forceRefresh: true),
    ]);
  }

  // ============================================================
  // Clear
  // ============================================================

  void clear() {
    _dashboardReport = null;
    _dailyReport = null;
    _monthlyReport = null;
    _equityReport = null;
    _performanceReport = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
