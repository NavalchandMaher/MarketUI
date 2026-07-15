import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

import '../models/analysis_model.dart';
import '../models/backtest_model.dart';
import '../models/dashboard_model.dart';
import '../models/learning_log_model.dart';
import '../models/paper_trade_model.dart';
import '../models/performance_model.dart';
import '../models/scheduler_model.dart';
import '../models/strategy_model.dart';

/// ===============================================================
/// API SERVICE
/// ===============================================================

class ApiService {
  ApiService._internal();

  static final ApiService instance = ApiService._internal();

  final http.Client _client = http.Client();

  //==============================================================
  // Headers
  //==============================================================

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  //==============================================================
  // GET
  //==============================================================

  Future<dynamic> getRequest(String endpoint) async {
    try {
      final uri = Uri.parse("${AppConfig.baseUrl}$endpoint");

      _log("GET : $uri");

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception("Request Timeout");
    } catch (e) {
      throw Exception("GET Request Failed\n$e");
    }
  }

  //==============================================================
  // POST
  //==============================================================

  Future<dynamic> postRequest(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse("${AppConfig.baseUrl}$endpoint");

      _log("POST : $uri");

      final response = await _client
          .post(uri, headers: _headers, body: jsonEncode(body ?? {}))
          .timeout(AppConfig.apiTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception("Request Timeout");
    } catch (e) {
      throw Exception("POST Request Failed\n$e");
    }
  }

  //==============================================================
  // RESPONSE HANDLER
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
  // LOGGER
  //==============================================================

  void _log(String message) {
    if (AppConfig.enableLogs) {
      debugPrint("[API] $message");
    }
  }

  //==============================================================
  // HEALTH CHECK
  //==============================================================

  Future<bool> ping() async {
    try {
      final response = await _client
          .get(Uri.parse(AppConfig.baseUrl))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  //==============================================================
  // CLOSE CLIENT
  //==============================================================

  void dispose() {
    _client.close();
  }

  //==============================================================
  // ANALYSIS
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
  // STRATEGY
  //==============================================================

  Future<StrategyModel> getStrategy() async {
    final json = await getRequest(AppConfig.strategy);

    return StrategyModel.fromJson(json);
  }

  //==============================================================
  // PAPER TRADES
  //==============================================================

  Future<PaperTradeModel> getPaperTrades() async {
    final json = await getRequest(AppConfig.paperTrades);

    return PaperTradeModel.fromJson(json);
  }

  //==============================================================
  // PERFORMANCE
  //==============================================================

  Future<PerformanceModel> getPerformance() async {
    final json = await getRequest(AppConfig.performance);

    return PerformanceModel.fromJson(json);
  }

  //==============================================================
  // LEARNING LOGS
  //==============================================================

  Future<LearningLogModel> getLearningLogs() async {
    final json = await getRequest(AppConfig.learningLogs);

    return LearningLogModel.fromJson(List<dynamic>.from(json));
  }

  //==============================================================
  // LOAD DASHBOARD DATA
  //==============================================================

  Future<DashboardModel> loadDashboard({
    String symbol = AppConfig.defaultSymbol,
    String timeframe = AppConfig.defaultTimeframe,
  }) async {
    final results = await Future.wait([
      getAnalysis(symbol: symbol, timeframe: timeframe),
      getStrategy(),
      getPaperTrades(),
      getPerformance(),
    ]);

    return DashboardModel(
      analysis: results[0] as AnalysisModel,
      strategy: results[1] as StrategyModel,
      paperTrade: results[2] as PaperTradeModel,
      performance: results[3] as PerformanceModel,
      scheduler: const SchedulerDashboardModel(
        scheduler: SchedulerInfo(running: false, totalJobs: 0, jobs: []),
        marketHealth: MarketHealth(marketCycle: "UNKNOWN"),
        jobs: [],
        timestamp: null,
      ),
      backtest: null,
      lastUpdated: DateTime.now(),
    );
  }

  //==============================================================
  // REFRESH DASHBOARD
  //==============================================================

  Future<DashboardModel> refreshDashboard({
    String symbol = AppConfig.defaultSymbol,
    String timeframe = AppConfig.defaultTimeframe,
  }) async {
    return loadDashboard(symbol: symbol, timeframe: timeframe);
  }
  // SCHEDULER STATUS
  //==============================================================

  Future<SchedulerStatusModel> getSchedulerStatus() async {
    final json = await getRequest(AppConfig.schedulerStatus);

    return SchedulerStatusModel.fromJson(json);
  }

  //==============================================================
  // SCHEDULER DASHBOARD
  //==============================================================

  Future<SchedulerDashboardModel> getSchedulerDashboard() async {
    final json = await getRequest(AppConfig.schedulerDashboard);

    return SchedulerDashboardModel.fromJson(json);
  }

  //==============================================================
  // RUN MARKET CYCLE
  //==============================================================

  Future<bool> runMarketCycle() async {
    try {
      final json = await postRequest(AppConfig.runMarket);

      _log("Market Cycle Triggered");

      if (json is Map<String, dynamic>) {
        if (json.containsKey("success")) {
          return json["success"] == true;
        }

        return true;
      }

      return true;
    } catch (e) {
      _log(e.toString());
      return false;
    }
  }

  //==============================================================
  // RUN NIGHTLY AI
  //==============================================================

  Future<bool> runNightlyCycle() async {
    try {
      final json = await postRequest(AppConfig.runNightly);

      _log("Nightly AI Triggered");

      if (json is Map<String, dynamic>) {
        if (json.containsKey("success")) {
          return json["success"] == true;
        }

        return true;
      }

      return true;
    } catch (e) {
      _log(e.toString());
      return false;
    }
  }

  //==============================================================
  // REFRESH SCHEDULER
  //==============================================================

  Future<SchedulerDashboardModel> refreshScheduler() async {
    return getSchedulerDashboard();
  }

  //==============================================================
  // IS SCHEDULER RUNNING
  //==============================================================

  Future<bool> isSchedulerRunning() async {
    final scheduler = await getSchedulerStatus();

    return scheduler.running;
  }

  //==============================================================
  // TOTAL JOBS
  //==============================================================

  Future<int> getSchedulerJobCount() async {
    final scheduler = await getSchedulerStatus();

    return scheduler.totalJobs;
  }

  //==============================================================
  // NEXT JOB
  //==============================================================

  Future<SchedulerJob?> getNextJob() async {
    final scheduler = await getSchedulerStatus();

    if (scheduler.jobs.isEmpty) {
      return null;
    }

    return scheduler.jobs.first;
  }

  //==============================================================
  // MARKET HEALTH
  //==============================================================

  Future<MarketHealth> getMarketHealth() async {
    final dashboard = await getSchedulerDashboard();

    return dashboard.marketHealth;
  }

  //==============================================================
  // JOB LIST
  //==============================================================

  Future<List<JobInfo>> getSchedulerJobs() async {
    final dashboard = await getSchedulerDashboard();

    return dashboard.jobs;
  }
}
