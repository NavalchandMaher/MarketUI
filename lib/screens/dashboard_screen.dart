import 'package:flutter/material.dart';

import '../models/analysis_model.dart';
import '../models/backtest_model.dart';
import '../models/dashboard_model.dart';
import '../models/learning_log_model.dart';
import '../models/paper_trade_model.dart';
import '../models/performance_model.dart';
import '../models/scheduler_model.dart';
import '../models/strategy_model.dart';

import '../services/api_service.dart';

import '../utils/constants.dart';

import '../widgets/analysis_card.dart';
import '../widgets/chart_card.dart';
import '../widgets/learning_card.dart';
import '../widgets/paper_trade_card.dart';
import '../widgets/performance_card.dart';
import '../widgets/scheduler_card.dart';
import '../widgets/signal_card.dart';
import '../widgets/strategy_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService.instance;

  bool _loading = true;

  bool _refreshing = false;

  String? _error;

  AnalysisModel? analysis;

  DashboardModel? dashboard;

  PerformanceModel? performance;

  PaperTradeModel? paperTrade;

  StrategyModel? strategy;

  SchedulerDashboardModel? scheduler;

  LearningLogModel learning = LearningLogModel.empty();

  BacktestDashboard? backtest;

  @override
  void initState() {
    super.initState();

    _loadDashboard();
  }

  /// ===============================================================
  /// Load Dashboard
  /// ===============================================================

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _api.getAnalysis(),
        _api.loadDashboard(),
        _api.getPerformance(),
        _api.getPaperTrades(),
        _api.getStrategy(),
        _api.getSchedulerDashboard(),
        _api.getLearningLogs(),
      ]);

      if (!mounted) return;

      setState(() {
        analysis = results[0] as AnalysisModel;
        dashboard = results[1] as DashboardModel;
        performance = results[2] as PerformanceModel;
        paperTrade = results[3] as PaperTradeModel;
        strategy = results[4] as StrategyModel;
        scheduler = results[5] as SchedulerDashboardModel;
        learning = results[6] as LearningLogModel;

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  /// ===============================================================
  /// Refresh Dashboard
  /// ===============================================================

  Future<void> _refreshDashboard() async {
    setState(() {
      _refreshing = true;
    });

    try {
      await _loadDashboard();
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
        });
      }
    }
  }

  /// ===============================================================
  /// App Bar
  /// ===============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Market Dashboard",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      elevation: 0,
      actions: [
        if (_refreshing)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDashboard,
          ),

        IconButton(
          tooltip: "Settings",
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(context, "/settings");
          },
        ),
      ],
    );
  }

  /// ===============================================================
  /// Loading Widget
  /// ===============================================================

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  /// ===============================================================
  /// Error Widget
  /// ===============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 70, color: Colors.red),

            const SizedBox(height: 20),

            Text("Failed to load dashboard", style: AppTextStyles.title),

            const SizedBox(height: 10),

            Text(
              _error ?? "Unknown error",
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Floating Action Button
  /// ===============================================================

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: _refreshDashboard,
      child: const Icon(Icons.refresh),
    );
  }

  /// ===============================================================
  /// Dashboard Body
  /// ===============================================================

  Widget _buildDashboard() {
    if (analysis == null ||
        performance == null ||
        paperTrade == null ||
        strategy == null ||
        scheduler == null) {
      return const Center(child: Text("Dashboard data unavailable"));
    }

    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// =====================================================
            /// Analysis
            /// =====================================================
            AnalysisCard(analysis: analysis!),

            const SizedBox(height: 16),

            /// =====================================================
            /// Signal
            /// =====================================================
            SignalCard(analysis: analysis!),

            const SizedBox(height: 16),

            /// =====================================================
            /// Chart
            /// =====================================================
            ChartCard(analysis: analysis!),

            const SizedBox(height: 16),

            /// =====================================================
            /// Performance
            /// =====================================================
            PerformanceCard(performance: performance!),

            const SizedBox(height: 16),

            /// =====================================================
            /// Paper Trading
            /// =====================================================
            PaperTradeCard(paperTrade: paperTrade!),

            const SizedBox(height: 16),

            /// =====================================================
            /// Strategy
            /// =====================================================
            StrategyCard(strategy: strategy!),

            const SizedBox(height: 16),

            /// =====================================================
            /// Scheduler
            /// =====================================================
            SchedulerCard(scheduler: scheduler!),

            const SizedBox(height: 16),

            /// =====================================================
            /// Learning
            /// =====================================================
            LearningCard(learning: learning),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Build
  /// ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),

      floatingActionButton: _buildFab(),

      body: SafeArea(
        child: _loading
            ? _buildLoading()
            : _error != null
            ? _buildError()
            : _buildDashboard(),
      ),
    );
  }
}
