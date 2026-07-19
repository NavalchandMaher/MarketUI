import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';
import '../../models/analysis_model.dart';
import 'auth_service.dart';
import '../storage/cache_service.dart';
import '../network/connectivity_service.dart';

/// ===============================================================
/// V3 API Service - Enhanced with Caching & Error Handling
/// ===============================================================
class V3ApiService {
  static V3ApiService? _instance;

  // Support both singleton and dependency injection
  factory V3ApiService({
    required AuthService authService,
    required CacheService cacheService,
    required ConnectivityService connectivityService,
  }) {
    _instance ??= V3ApiService._(
      authService: authService,
      cacheService: cacheService,
      connectivityService: connectivityService,
    );
    return _instance!;
  }

  V3ApiService._({
    required this.authService,
    required this.cacheService,
    required this.connectivityService,
  });

  final AuthService authService;
  final CacheService cacheService;
  final ConnectivityService connectivityService;
  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  Map<String, String> get _authHeaders {
    final token = authService.accessToken;
    final headers = <String, String>{..._headers};

    _log(
      "[DEBUG-HEADERS] Building auth headers - isInitialized: ${authService.isInitialized}, token exists: ${token != null}",
    );

    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
      _log(
        "✓ Authorization header ADDED: Bearer ${token.substring(0, min(20, token.length))}...",
      );
    } else {
      _log(
        "✗ WARNING: accessToken is ${token == null ? 'NULL' : 'EMPTY'} - Authorization header NOT added",
      );
      if (!authService.isInitialized) {
        _log(
          "✗ CRITICAL: AuthService.isInitialized = false - tokens not yet loaded from storage!",
        );
      }
    }

    return headers;
  }

  // ============================================================
  // Core Request Methods
  // ============================================================

  Future<dynamic> getRequest(
    String endpoint, {
    int cacheTtl = 60, // Cache TTL in seconds (0 = no cache)
    bool forceRefresh = false,
    bool requireAuth = true,
  }) async {
    if (requireAuth && !authService.isAuthenticated) {
      _log("[DEBUG] Auth missing before GET request. Attempting restore...");
      final restored = await authService.ensureAuthenticated();
      if (!restored) {
        _log(
          "✗ AUTHENTICATION REQUIRED: Aborting request to $endpoint because user is not authenticated.",
        );
        throw AuthenticationException("User is not authenticated");
      }
    }

    if (!connectivityService.isOnline) {
      final offlineCached = cacheService.get(endpoint, ttlSeconds: cacheTtl);
      if (offlineCached != null) {
        _log("✓ OFFLINE: returning cached data for $endpoint");
        return offlineCached;
      }
      throw Exception("Offline and no cached data available for $endpoint");
    }

    try {
      // Check cache first (if enabled and not forcing refresh)
      if (cacheTtl > 0 && !forceRefresh) {
        final cached = cacheService.get(endpoint, ttlSeconds: cacheTtl);
        if (cached != null) {
          _log("✓ GET (CACHED): $endpoint");
          return cached;
        }
      }

      final uri = Uri.parse("${AppConfig.baseUrl}$endpoint");
      _log("[DEBUG] Starting GET request to: $uri");

      final headers = requireAuth ? _authHeaders : _headers;
      _log(
        "[DEBUG] Headers built, Authorization header included: ${headers.containsKey('Authorization')}",
      );

      _log("→ GET REQUEST: $uri");
      _log(
        "  Headers: ${headers.entries.map((e) => e.key + ': ' + (e.key == 'Authorization' ? e.value.substring(0, min(30, e.value.length)) + '...' : e.value)).join(', ')}",
      );

      _log("[DEBUG] Sending HTTP GET request...");
      final response = await _client
          .get(uri, headers: headers)
          .timeout(AppConfig.apiTimeout);

      _log("← Response Status: ${response.statusCode}");

      final result = _handleResponse(response, endpoint);

      // Cache the result if TTL is specified
      if (cacheTtl > 0) {
        await cacheService.set(endpoint, result, ttlSeconds: cacheTtl);
      }

      return result;
    } on TimeoutException {
      final cached = cacheService.get(endpoint, ttlSeconds: cacheTtl);
      if (cached != null) {
        _log("✓ TIMEOUT: returning cached data for $endpoint");
        return cached;
      }
      throw Exception("Request Timeout");
    } catch (e) {
      if (!connectivityService.isOnline) {
        final cached = cacheService.get(endpoint, ttlSeconds: cacheTtl);
        if (cached != null) {
          _log("✓ NETWORK ERROR: returning cached data for $endpoint");
          return cached;
        }
      }
      throw Exception("GET Request Failed: $e");
    }
  }

  Future<dynamic> postRequest(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    if (requireAuth && !authService.isAuthenticated) {
      _log("[DEBUG] Auth missing before POST request. Attempting restore...");
      final restored = await authService.ensureAuthenticated();
      if (!restored) {
        _log(
          "✗ AUTHENTICATION REQUIRED: Aborting POST request to $endpoint because user is not authenticated.",
        );
        throw AuthenticationException("User is not authenticated");
      }
    }

    if (!connectivityService.isOnline) {
      throw Exception("Offline: unable to perform POST to $endpoint");
    }

    try {
      final uri = Uri.parse("${AppConfig.baseUrl}$endpoint");
      _log("[DEBUG] Starting POST request to: $uri");

      final headers = requireAuth ? _authHeaders : _headers;
      _log(
        "[DEBUG] Headers built, Authorization header included: ${headers.containsKey('Authorization')}",
      );

      _log("→ POST REQUEST: $uri");
      _log(
        "  Headers: ${headers.entries.map((e) => e.key + ': ' + (e.key == 'Authorization' ? e.value.substring(0, min(30, e.value.length)) + '...' : e.value)).join(', ')}",
      );
      _log("  Body: ${body ?? {}}");

      _log("[DEBUG] Sending HTTP POST request...");
      final response = await _client
          .post(uri, headers: headers, body: jsonEncode(body ?? {}))
          .timeout(AppConfig.apiTimeout);

      _log("← Response Status: ${response.statusCode}");

      return _handleResponse(response, endpoint);
    } on TimeoutException {
      throw Exception("Request Timeout");
    } catch (e) {
      throw Exception("POST Request Failed: $e");
    }
  }

  Future<dynamic> putRequest(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requireAuth = true,
  }) async {
    if (requireAuth && !authService.isAuthenticated) {
      _log("[DEBUG] Auth missing before PUT request. Attempting restore...");
      final restored = await authService.ensureAuthenticated();
      if (!restored) {
        _log(
          "✗ AUTHENTICATION REQUIRED: Aborting PUT request to $endpoint because user is not authenticated.",
        );
        throw AuthenticationException("User is not authenticated");
      }
    }

    try {
      final uri = Uri.parse("${AppConfig.baseUrl}$endpoint");
      final headers = requireAuth ? _authHeaders : _headers;

      _log("PUT REQUEST: $uri");
      _log(
        "  Headers: ${headers.entries.map((e) => e.key + ': ' + (e.key == 'Authorization' ? e.value.substring(0, min(30, e.value.length)) + '...' : e.value)).join(', ')}",
      );

      final response = await _client
          .put(uri, headers: headers, body: jsonEncode(body ?? {}))
          .timeout(AppConfig.apiTimeout);

      _log("  Response Status: ${response.statusCode}");

      return _handleResponse(response, endpoint);
    } on TimeoutException {
      throw Exception("Request Timeout");
    } catch (e) {
      throw Exception("PUT Request Failed: $e");
    }
  }

  Future<dynamic> deleteRequest(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    if (requireAuth && !authService.isAuthenticated) {
      _log("[DEBUG] Auth missing before DELETE request. Attempting restore...");
      final restored = await authService.ensureAuthenticated();
      if (!restored) {
        _log(
          "✗ AUTHENTICATION REQUIRED: Aborting DELETE request to $endpoint because user is not authenticated.",
        );
        throw AuthenticationException("User is not authenticated");
      }
    }

    try {
      final uri = Uri.parse("${AppConfig.baseUrl}$endpoint");
      final headers = requireAuth ? _authHeaders : _headers;

      _log("DELETE REQUEST: $uri");
      _log(
        "  Headers: ${headers.entries.map((e) => e.key + ': ' + (e.key == 'Authorization' ? e.value.substring(0, min(30, e.value.length)) + '...' : e.value)).join(', ')}",
      );

      final response = await _client
          .delete(uri, headers: headers)
          .timeout(AppConfig.apiTimeout);

      _log("  Response Status: ${response.statusCode}");

      return _handleResponse(response, endpoint);
    } on TimeoutException {
      throw Exception("Request Timeout");
    } catch (e) {
      throw Exception("DELETE Request Failed: $e");
    }
  }

  // ============================================================
  // Response Handler
  // ============================================================

  dynamic _handleResponse(http.Response response, String endpoint) {
    if (response.body.isEmpty) {
      throw ApiException("Empty Response", 0);
    }

    dynamic json;
    try {
      json = jsonDecode(response.body);
    } catch (e) {
      throw ApiException("Invalid JSON Response", response.statusCode);
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return json;

      case 400:
        throw ValidationException(
          json["detail"] ?? "Bad Request",
          json["errors"] ?? {},
        );

      case 401:
        // Token expired, clear it
        authService.logout();
        throw AuthenticationException(json["detail"] ?? "Unauthorized");

      case 403:
        throw ApiException(json["detail"] ?? "Forbidden", 403);

      case 404:
        throw ApiException(json["detail"] ?? "Not Found", 404);

      case 422:
        throw ValidationException(
          json["detail"] ?? "Validation Error",
          json["errors"] ?? {},
        );

      case 500:
        throw ServerException(json["detail"] ?? "Internal Server Error", 500);

      default:
        throw ApiException("HTTP ${response.statusCode}", response.statusCode);
    }
  }

  void _log(String message) {
    if (AppConfig.enableLogs) {
      debugPrint("[API-V3] $message");
    }
  }

  // ============================================================
  // Dashboard
  // ============================================================

  Future<Map<String, dynamic>> getDashboard({bool forceRefresh = false}) async {
    return await getRequest(
      AppConfig.v3Dashboard,
      cacheTtl: 30,
      forceRefresh: forceRefresh,
    );
  }

  // ============================================================
  // Analysis
  // ============================================================

  Future<AnalysisModel> getAnalysis({
    String symbol = AppConfig.defaultSymbol,
    String timeframe = AppConfig.defaultTimeframe,
    bool forceRefresh = false,
  }) async {
    final endpoint =
        "${AppConfig.analysis}?symbol=$symbol&timeframe=$timeframe";
    final json = await getRequest(
      endpoint,
      cacheTtl: 60,
      forceRefresh: forceRefresh,
    );
    return AnalysisModel.fromJson(json);
  }

  // ============================================================
  // Strategies
  // ============================================================

  Future<List<dynamic>> getStrategies({bool forceRefresh = false}) async {
    final json = await getRequest(
      AppConfig.v3Strategies,
      cacheTtl: 300,
      forceRefresh: forceRefresh,
    );
    return json is List ? json : [];
  }

  Future<List<dynamic>> getAdminStrategies({bool forceRefresh = false}) async {
    final json = await getRequest(
      "${AppConfig.v3Strategies}/admin/strategies",
      cacheTtl: 60,
      forceRefresh: forceRefresh,
    );
    return json is List ? json : [];
  }

  Future<Map<String, dynamic>> setSystemStrategyPublished(
    String strategyId,
    bool published,
  ) async {
    final json = await putRequest(
      "${AppConfig.v3Strategies}/$strategyId/publish",
      body: {"published": published},
    );
    await cacheService.delete(AppConfig.v3Strategies);
    await cacheService.delete("${AppConfig.v3Strategies}/admin/strategies");
    return json;
  }

  Future<Map<String, dynamic>> getStrategy(
    String strategyId, {
    bool forceRefresh = false,
  }) async {
    final json = await getRequest(
      "${AppConfig.v3Strategies}/$strategyId",
      cacheTtl: 300,
      forceRefresh: forceRefresh,
    );
    return json;
  }

  Future<Map<String, dynamic>> createStrategy(
    Map<String, dynamic> payload,
  ) async {
    final json = await postRequest(AppConfig.v3Strategies, body: payload);
    // Invalidate strategies cache
    await cacheService.delete(AppConfig.v3Strategies);
    return json;
  }

  Future<Map<String, dynamic>> updateStrategy(
    String strategyId,
    Map<String, dynamic> payload,
  ) async {
    final json = await putRequest(
      "${AppConfig.v3Strategies}/$strategyId",
      body: payload,
    );
    // Invalidate caches
    await cacheService.delete(AppConfig.v3Strategies);
    await cacheService.delete("${AppConfig.v3Strategies}/$strategyId");
    return json;
  }

  Future<Map<String, dynamic>> deleteStrategy(String strategyId) async {
    final json = await deleteRequest("${AppConfig.v3Strategies}/$strategyId");
    // Invalidate strategies cache
    await cacheService.delete(AppConfig.v3Strategies);
    return json;
  }

  // ============================================================
  // Paper Trading
  // ============================================================

  Future<Map<String, dynamic>> startPaperTrading({
    required String strategyId,
  }) async {
    return await postRequest(
      "${AppConfig.v3Paper}/start",
      body: {"strategy_id": strategyId},
    );
  }

  Future<Map<String, dynamic>> stopPaperTrading() async {
    return await postRequest("${AppConfig.v3Paper}/stop");
  }

  Future<Map<String, dynamic>> getPaperStatus() async {
    return await getRequest("${AppConfig.v3Paper}/status", cacheTtl: 10);
  }

  Future<List<dynamic>> getPaperOpenTrades() async {
    final json = await getRequest("${AppConfig.v3Paper}/open", cacheTtl: 20);
    return json is List ? json : [];
  }

  Future<List<dynamic>> getPaperHistory({String? symbol, int? days}) async {
    var endpoint = "${AppConfig.v3Paper}/history";
    final queryParams = <String>[];
    if (symbol != null) queryParams.add("symbol=$symbol");
    if (days != null) queryParams.add("days=$days");
    if (queryParams.isNotEmpty) {
      endpoint += "?${queryParams.join('&')}";
    }

    final json = await getRequest(endpoint, cacheTtl: 300);
    return json is List ? json : [];
  }

  Future<Map<String, dynamic>> getPaperStatistics() async {
    return await getRequest("${AppConfig.v3Paper}/statistics", cacheTtl: 60);
  }

  // ============================================================
  // Backtesting
  // ============================================================

  Future<Map<String, dynamic>> runBacktest({
    String symbol = AppConfig.defaultSymbol,
    String timeframe = AppConfig.defaultTimeframe,
    int days = 365,
  }) async {
    return await postRequest(
      "${AppConfig.v3Backtest}/run",
      body: {"symbol": symbol, "timeframe": timeframe, "days": days},
    );
  }

  Future<Map<String, dynamic>> getBacktestResult(String backtestId) async {
    return await getRequest(
      "${AppConfig.v3Backtest}/$backtestId",
      cacheTtl: 600,
    );
  }

  Future<List<dynamic>> getBacktestHistory() async {
    final json = await getRequest(
      "${AppConfig.v3Backtest}/history",
      cacheTtl: 600,
    );
    return json is List ? json : [];
  }

  Future<Map<String, dynamic>> deleteBacktest(String backtestId) async {
    return await deleteRequest("${AppConfig.v3Backtest}/$backtestId");
  }

  // ============================================================
  // Reports
  // ============================================================

  Future<Map<String, dynamic>> getReportsDashboard({
    bool forceRefresh = false,
  }) async {
    return await getRequest(
      "${AppConfig.v3Reports}/dashboard",
      cacheTtl: 300,
      forceRefresh: forceRefresh,
    );
  }

  Future<Map<String, dynamic>> getDailyReport(String date) async {
    return await getRequest(
      "${AppConfig.v3Reports}/daily?date=$date",
      cacheTtl: 300,
    );
  }

  Future<Map<String, dynamic>> getMonthlyReport(String month) async {
    return await getRequest(
      "${AppConfig.v3Reports}/monthly?month=$month",
      cacheTtl: 300,
    );
  }

  Future<Map<String, dynamic>> getEquityCurve() async {
    return await getRequest("${AppConfig.v3Reports}/equity", cacheTtl: 300);
  }

  Future<Map<String, dynamic>> getPerformanceReport() async {
    return await getRequest(
      "${AppConfig.v3Reports}/performance",
      cacheTtl: 300,
    );
  }

  // ============================================================
  // Learning Logs
  // ============================================================

  Future<List<dynamic>> getLearningLogs({
    String? category,
    int? days,
    bool forceRefresh = false,
  }) async {
    var endpoint = AppConfig.v3Learning;
    final queryParams = <String>[];
    if (category != null) queryParams.add("category=$category");
    if (days != null) queryParams.add("days=$days");
    if (queryParams.isNotEmpty) {
      endpoint += "?${queryParams.join('&')}";
    }

    final json = await getRequest(
      endpoint,
      cacheTtl: 600,
      forceRefresh: forceRefresh,
    );
    return json is List ? json : [];
  }

  Future<Map<String, dynamic>> getLearningLogDetail(String logId) async {
    return await getRequest("${AppConfig.v3Learning}/$logId", cacheTtl: 600);
  }

  Future<Map<String, dynamic>> createLearningLog(
    Map<String, dynamic> payload,
  ) async {
    final json = await postRequest(AppConfig.v3Learning, body: payload);
    await cacheService.delete(AppConfig.v3Learning);
    return json;
  }

  Future<Map<String, dynamic>> updateLearningLog(
    String logId,
    Map<String, dynamic> payload,
  ) async {
    final json = await putRequest(
      "${AppConfig.v3Learning}/$logId",
      body: payload,
    );
    await cacheService.delete(AppConfig.v3Learning);
    await cacheService.delete("${AppConfig.v3Learning}/$logId");
    return json;
  }

  Future<Map<String, dynamic>> deleteLearningLog(String logId) async {
    final json = await deleteRequest("${AppConfig.v3Learning}/$logId");
    await cacheService.delete(AppConfig.v3Learning);
    await cacheService.delete("${AppConfig.v3Learning}/$logId");
    return json;
  }

  Future<Map<String, dynamic>> getLatestLearning() async {
    return await getRequest("${AppConfig.v3Learning}/latest", cacheTtl: 60);
  }

  // ============================================================
  // Settings
  // ============================================================

  Future<Map<String, dynamic>> getSettings() async {
    return await getRequest(
      AppConfig.v3Settings,
      cacheTtl: 3600, // 1 hour
    );
  }

  Future<Map<String, dynamic>> updateSettings(
    Map<String, dynamic> payload,
  ) async {
    final json = await putRequest(AppConfig.v3Settings, body: payload);
    // Invalidate cache
    await cacheService.delete(AppConfig.v3Settings);
    return json;
  }

  // ============================================================
  // Account
  // ============================================================

  Future<Map<String, dynamic>> getAccount() async {
    return await getRequest(
      AppConfig.v3Account,
      cacheTtl: 3600, // 1 hour
    );
  }

  Future<Map<String, dynamic>> updateAccount(
    Map<String, dynamic> payload,
  ) async {
    final json = await putRequest(AppConfig.v3Account, body: payload);
    // Invalidate cache
    await cacheService.delete(AppConfig.v3Account);
    return json;
  }

  // ============================================================
  // Public Endpoints (no auth required)
  // ============================================================

  Future<List<String>> getSymbols() async {
    final json = await getRequest(
      AppConfig.v3Symbols,
      cacheTtl: 3600, // 1 hour
      requireAuth: false,
    );
    return json is List ? json.cast<String>() : [];
  }

  Future<List<String>> getTimeframes() async {
    final json = await getRequest(
      AppConfig.v3Timeframes,
      cacheTtl: 3600, // 1 hour
      requireAuth: false,
    );
    return json is List ? json.cast<String>() : [];
  }

  // ============================================================
  // Cache Management
  // ============================================================

  Future<void> invalidateCache(String endpoint) async {
    await cacheService.delete(endpoint);
  }

  Future<void> clearAllCache() async {
    await cacheService.clear();
  }

  // ============================================================
  // Cleanup
  // ============================================================

  void dispose() {
    _client.close();
  }
}

// ============================================================
// API Exceptions
// ============================================================

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => "ApiException($statusCode): $message";
}

class AuthenticationException extends ApiException {
  AuthenticationException(String message) : super(message, 401);
}

class ValidationException extends ApiException {
  final Map<String, dynamic> errors;

  ValidationException(String message, this.errors) : super(message, 422);

  @override
  String toString() => "ValidationException: $message (Errors: $errors)";
}

class ServerException extends ApiException {
  ServerException(String message, int statusCode) : super(message, statusCode);
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message, 0);
}
