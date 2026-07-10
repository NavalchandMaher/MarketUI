import 'package:flutter/material.dart';
import '../config.dart';
import '../service_locator.dart';
import '../services/api/v3_api_service.dart';

/// ===============================================================
/// Scheduler Provider - Scheduler status and job management
/// ===============================================================
class SchedulerProvider extends ChangeNotifier {
  late final V3ApiService _api;

  Map<String, dynamic>? _status;
  Map<String, dynamic>? _dashboard;
  bool _isLoading = false;
  String? _errorMessage;
  String? _lastOperation; // Track last operation result

  SchedulerProvider() {
    _api = getIt<V3ApiService>();
  }

  // ============================================================
  // Getters
  // ============================================================

  Map<String, dynamic>? get status => _status;
  Map<String, dynamic>? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get lastOperation => _lastOperation;

  bool get isSchedulerRunning => _status?['running'] ?? false;
  List<dynamic> get jobs => _dashboard?['jobs'] ?? [];
  int get completedJobs => _dashboard?['completed_jobs'] ?? 0;
  int get failedJobs => _dashboard?['failed_jobs'] ?? 0;

  // ============================================================
  // Load Scheduler Status
  // ============================================================

  Future<void> loadSchedulerStatus({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final json = await _api.getRequest(
        AppConfig.schedulerStatus,
        cacheTtl: 30, // Update every 30 seconds
        forceRefresh: forceRefresh,
      );
      _status = json is Map<String, dynamic> ? json : {};
      _errorMessage = null;
      print('[SCHEDULER] Loaded scheduler status');
    } catch (e) {
      _errorMessage = e.toString();
      print('[SCHEDULER] Error loading status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Load Scheduler Dashboard
  // ============================================================

  Future<void> loadSchedulerDashboard({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final json = await _api.getRequest(
        AppConfig.schedulerDashboard,
        cacheTtl: 30,
        forceRefresh: forceRefresh,
      );
      _dashboard = json is Map<String, dynamic> ? json : {};
      _errorMessage = null;
      print('[SCHEDULER] Loaded scheduler dashboard');
    } catch (e) {
      _errorMessage = e.toString();
      print('[SCHEDULER] Error loading dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Run Market Scanner
  // ============================================================

  Future<bool> runMarketNow() async {
    _isLoading = true;
    _errorMessage = null;
    _lastOperation = null;
    notifyListeners();

    try {
      final response = await _api.postRequest(AppConfig.runMarket);
      _lastOperation = response is Map
          ? response['message'] ?? 'Market scan started'
          : 'Market scan started';
      _errorMessage = null;
      print('[SCHEDULER] Market scan started: $_lastOperation');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _lastOperation = 'Failed: $e';
      print('[SCHEDULER] Error running market: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Run Nightly Job
  // ============================================================

  Future<bool> runNightlyNow() async {
    _isLoading = true;
    _errorMessage = null;
    _lastOperation = null;
    notifyListeners();

    try {
      final response = await _api.postRequest(AppConfig.runNightly);
      _lastOperation = response is Map
          ? response['message'] ?? 'Nightly job started'
          : 'Nightly job started';
      _errorMessage = null;
      print('[SCHEDULER] Nightly job started: $_lastOperation');
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _lastOperation = 'Failed: $e';
      print('[SCHEDULER] Error running nightly: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Refresh All Data
  // ============================================================

  Future<void> refreshAll() async {
    await Future.wait([
      loadSchedulerStatus(forceRefresh: true),
      loadSchedulerDashboard(forceRefresh: true),
    ]);
  }

  // ============================================================
  // Utilities
  // ============================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearLastOperation() {
    _lastOperation = null;
    notifyListeners();
  }

  void reset() {
    _status = null;
    _dashboard = null;
    _isLoading = false;
    _errorMessage = null;
    _lastOperation = null;
    notifyListeners();
  }
}
