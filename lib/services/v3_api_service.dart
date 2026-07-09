import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/analysis_model.dart';
import 'auth_service.dart';

/// ===============================================================
/// V3 API Service - Authenticated API calls
/// ===============================================================
class V3ApiService {
  V3ApiService._internal();

  static final V3ApiService instance = V3ApiService._internal();

  final http.Client _client = http.Client();
  final AuthService _auth = AuthService();

  //==============================================================
  // Headers
  //==============================================================

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  Map<String, String> get _authHeaders => {
    ..._headers,
    if (_auth.accessToken != null)
      "Authorization": "Bearer ${_auth.accessToken}",
  };

  //==============================================================
  // GET with Auth
  //==============================================================

  Future<dynamic> getRequest(String endpoint) async {
    try {
      final uri = Uri.parse("${AppConfig.baseUrl}$endpoint");

      _log("GET : $uri");

      final response = await _client
          .get(uri, headers: _authHeaders)
          .timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception("Request Timeout");
    } catch (e) {
      throw Exception("GET Request Failed\n$e");
    }
  }

  //==============================================================
  // POST with Auth
  //==============================================================

  Future<dynamic> postRequest(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse("${AppConfig.baseUrl}$endpoint");

      _log("POST : $uri");

      final response = await _client
          .post(uri, headers: _authHeaders, body: jsonEncode(body ?? {}))
          .timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception("Request Timeout");
    } catch (e) {
      throw Exception("POST Request Failed\n$e");
    }
  }

  //==============================================================
  // PUT with Auth
  //==============================================================

  Future<dynamic> putRequest(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse("${AppConfig.baseUrl}$endpoint");

      _log("PUT : $uri");

      final response = await _client
          .put(uri, headers: _authHeaders, body: jsonEncode(body ?? {}))
          .timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception("Request Timeout");
    } catch (e) {
      throw Exception("PUT Request Failed\n$e");
    }
  }

  //==============================================================
  // DELETE with Auth
  //==============================================================

  Future<dynamic> deleteRequest(String endpoint) async {
    try {
      final uri = Uri.parse("${AppConfig.baseUrl}$endpoint");

      _log("DELETE : $uri");

      final response = await _client
          .delete(uri, headers: _authHeaders)
          .timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception("Request Timeout");
    } catch (e) {
      throw Exception("DELETE Request Failed\n$e");
    }
  }

  //==============================================================
  // Response Handler
  //==============================================================

  dynamic _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      throw Exception("Empty Response");
    }

    final dynamic json = jsonDecode(response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        return json;

      case 400:
        throw Exception(json["detail"] ?? "Bad Request");

      case 401:
        throw Exception(json["detail"] ?? "Unauthorized");

      case 403:
        throw Exception(json["detail"] ?? "Forbidden");

      case 404:
        throw Exception(json["detail"] ?? "Not Found");

      case 422:
        throw Exception(json["detail"] ?? "Validation Error");

      case 500:
        throw Exception(json["detail"] ?? "Internal Server Error");

      default:
        throw Exception("HTTP ${response.statusCode}");
    }
  }

  //==============================================================
  // Logger
  //==============================================================

  void _log(String message) {
    if (AppConfig.enableLogs) {
      debugPrint("[API-V3] $message");
    }
  }

  //==============================================================
  // V3 Dashboard
  //==============================================================

  Future<Map<String, dynamic>> getDashboard() async {
    final json = await getRequest(AppConfig.v3Dashboard);
    return json;
  }

  //==============================================================
  // Analysis
  //==============================================================

  Future<AnalysisModel> getAnalysis({
    String symbol = AppConfig.defaultSymbol,
    String timeframe = AppConfig.defaultTimeframe,
  }) async {
    final json = await getRequest(
      "${AppConfig.analysis}?symbol=$symbol&timeframe=$timeframe",
    );

    return AnalysisModel.fromJson(json);
  }

  //==============================================================
  // V3 Strategies
  //==============================================================

  Future<List<dynamic>> getStrategies() async {
    final json = await getRequest(AppConfig.v3Strategies);
    return json is List ? json : [];
  }

  Future<Map<String, dynamic>> getStrategy(String strategyId) async {
    final json = await getRequest("${AppConfig.v3Strategies}/$strategyId");
    return json;
  }

  Future<Map<String, dynamic>> createStrategy(
    Map<String, dynamic> payload,
  ) async {
    final json = await postRequest(AppConfig.v3Strategies, body: payload);
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
    return json;
  }

  Future<Map<String, dynamic>> deleteStrategy(String strategyId) async {
    final json = await deleteRequest("${AppConfig.v3Strategies}/$strategyId");
    return json;
  }

  //==============================================================
  // V3 Paper Trading
  //==============================================================

  Future<List<dynamic>> getPaperOpenTrades() async {
    final json = await getRequest("${AppConfig.v3Paper}/open");
    return json is List ? json : [];
  }

  Future<List<dynamic>> getPaperHistory() async {
    final json = await getRequest("${AppConfig.v3Paper}/history");
    return json is List ? json : [];
  }

  Future<Map<String, dynamic>> getPaperStatistics() async {
    final json = await getRequest("${AppConfig.v3Paper}/statistics");
    return json;
  }

  //==============================================================
  // V3 Backtest
  //==============================================================

  Future<Map<String, dynamic>> runBacktest({
    String symbol = AppConfig.defaultSymbol,
    String timeframe = AppConfig.defaultTimeframe,
    int days = 365,
  }) async {
    final json = await postRequest(
      AppConfig.v3Backtest,
      body: {"symbol": symbol, "timeframe": timeframe, "days": days},
    );
    return json;
  }

  Future<List<dynamic>> getBacktestHistory() async {
    final json = await getRequest("${AppConfig.v3Backtest}history");
    return json is List ? json : [];
  }

  //==============================================================
  // V3 Reports
  //==============================================================

  Future<Map<String, dynamic>> getReports() async {
    final json = await getRequest(AppConfig.v3Reports);
    return json;
  }

  //==============================================================
  // V3 Learning
  //==============================================================

  Future<List<dynamic>> getLearningHistory() async {
    final json = await getRequest(AppConfig.v3Learning);
    return json is List ? json : [];
  }

  Future<Map<String, dynamic>> getLatestLearning() async {
    final json = await getRequest("${AppConfig.v3Learning}/latest");
    return json;
  }

  //==============================================================
  // V3 Settings
  //==============================================================

  Future<Map<String, dynamic>> getSettings() async {
    final json = await getRequest(AppConfig.v3Settings);
    return json;
  }

  Future<Map<String, dynamic>> updateSettings(
    Map<String, dynamic> payload,
  ) async {
    final json = await putRequest(AppConfig.v3Settings, body: payload);
    return json;
  }

  //==============================================================
  // V3 Account
  //==============================================================

  Future<Map<String, dynamic>> getAccount() async {
    final json = await getRequest(AppConfig.v3Account);
    return json;
  }

  Future<Map<String, dynamic>> updateAccount(
    Map<String, dynamic> payload,
  ) async {
    final json = await putRequest(AppConfig.v3Account, body: payload);
    return json;
  }

  //==============================================================
  // V3 Symbols and Timeframes
  //==============================================================

  Future<List<String>> getSymbols() async {
    final json = await getRequest(AppConfig.v3Symbols);
    return json is List ? json.cast<String>() : [];
  }

  Future<List<String>> getTimeframes() async {
    final json = await getRequest(AppConfig.v3Timeframes);
    return json is List ? json.cast<String>() : [];
  }

  //==============================================================
  // Close Client
  //==============================================================

  void dispose() {
    _client.close();
  }
}
