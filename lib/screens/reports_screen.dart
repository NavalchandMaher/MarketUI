import 'package:flutter/material.dart';

import '../models/performance_model.dart';
import '../service_locator.dart';
import '../services/api/v3_api_service.dart';

import '../widgets/performance_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  /// ===============================================================
  /// API
  /// ===============================================================

  final V3ApiService _api = getIt<V3ApiService>();

  /// ===============================================================
  /// State
  /// ===============================================================

  bool _loading = true;

  bool _refreshing = false;

  String? _error;

  PerformanceModel? _performance;

  /// ===============================================================
  /// Init
  /// ===============================================================

  @override
  void initState() {
    super.initState();

    _loadReports();
  }

  /// ===============================================================
  /// Load Reports
  /// ===============================================================

  Future<void> _loadReports() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.getPerformanceReport();

      if (!mounted) return;

      setState(() {
        _performance = PerformanceModel.fromJson(result);
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
  /// Refresh Reports
  /// ===============================================================

  Future<void> _refreshReports() async {
    setState(() {
      _refreshing = true;
    });

    try {
      final result = await _api.getPerformanceReport();

      if (!mounted) return;

      setState(() {
        _performance = PerformanceModel.fromJson(result);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
        });
      }
    }
  }

  /// ===============================================================
  /// Helper Methods
  /// ===============================================================

  Color _profitColor(double value) {
    if (value > 0) return Colors.green;
    if (value < 0) return Colors.red;
    return Colors.orange;
  }

  String _formatCurrency(double value) {
    return "₹${value.toStringAsFixed(2)}";
  }

  String _formatPercent(double value) {
    return "${value.toStringAsFixed(2)}%";
  }

  /// ===============================================================
  /// App Bar
  /// ===============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Performance Reports",
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
            tooltip: "Refresh Reports",
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReports,
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

            const Text(
              "Unable to load reports",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              _error ?? "Unknown error occurred",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _loadReports,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Empty Widget
  /// ===============================================================

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 70, color: Colors.grey),

            SizedBox(height: 20),

            Text(
              "No Performance Reports",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text(
              "Trading reports will appear once trades are executed.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Reports Dashboard
  /// ===============================================================

  Widget _buildReportsDashboard() {
    if (_performance == null || !_performance!.hasData) {
      return _buildEmpty();
    }

    final report = _performance!;
    final account = report.account;
    final summary = report.snapshot.summary;
    final metrics = report.snapshot.metrics;

    return RefreshIndicator(
      onRefresh: _refreshReports,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// ===================================================
            /// Performance Card
            /// ===================================================
            PerformanceCard(performance: report, onRefresh: _refreshReports),

            const SizedBox(height: 20),

            /// ===================================================
            /// Account Summary
            /// ===================================================
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Account Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    _reportRow(
                      "Initial Balance",
                      _formatCurrency(account.initialBalance),
                    ),

                    _reportRow(
                      "Current Balance",
                      _formatCurrency(account.currentBalance),
                    ),

                    _reportRow(
                      "Net Profit",
                      _formatCurrency(account.netProfit),
                    ),

                    _reportRow("Total Trades", account.totalTrades.toString()),

                    _reportRow("Wins", account.wins.toString()),

                    _reportRow("Losses", account.losses.toString()),

                    _reportRow("Win Rate", _formatPercent(account.winRate)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ===================================================
            /// Trading Metrics
            /// ===================================================
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Performance Metrics",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    _reportRow(
                      "Profit Factor",
                      metrics.profitFactor.toStringAsFixed(2),
                    ),

                    _reportRow(
                      "Sharpe Ratio",
                      metrics.sharpeRatio.toStringAsFixed(2),
                    ),

                    _reportRow(
                      "Risk / Reward",
                      metrics.riskReward.toStringAsFixed(2),
                    ),

                    _reportRow(
                      "Average Win",
                      _formatCurrency(metrics.averageWin),
                    ),

                    _reportRow(
                      "Average Loss",
                      _formatCurrency(metrics.averageLoss),
                    ),

                    _reportRow(
                      "Max Drawdown",
                      _formatPercent(metrics.maxDrawdown),
                    ),

                    _reportRow("Rating", metrics.rating),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ===================================================
            /// Quick Stats
            /// ===================================================
            Row(
              children: [
                Expanded(
                  child: _metricTile(
                    "Profit",
                    _formatCurrency(summary.netProfit),
                    _profitColor(summary.netProfit),
                  ),
                ),

                Expanded(
                  child: _metricTile(
                    "Win Rate",
                    _formatPercent(summary.winRate),
                    Colors.blue,
                  ),
                ),

                Expanded(
                  child: _metricTile(
                    "Trades",
                    summary.totalTrades.toString(),
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Report Row
  /// ===============================================================

  Widget _reportRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          Text(value),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Metric Tile
  /// ===============================================================

  Widget _metricTile(String title, String value, Color color) {
    return Card(
      elevation: 0,
      color: color.withOpacity(.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 6),

            Text(title),
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

      body: SafeArea(
        child: _loading
            ? _buildLoading()
            : _error != null
            ? _buildError()
            : _buildReportsDashboard(),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _refreshReports,
        tooltip: "Refresh Reports",
        child: _refreshing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.refresh),
      ),
    );
  }
}
