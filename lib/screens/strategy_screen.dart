import 'package:flutter/material.dart';

import '../models/strategy_model.dart';
import '../services/api_service.dart';
import '../widgets/strategy_card.dart';

class StrategyScreen extends StatefulWidget {
  const StrategyScreen({super.key});

  @override
  State<StrategyScreen> createState() => _StrategyScreenState();
}

class _StrategyScreenState extends State<StrategyScreen> {
  /// ===============================================================
  /// API Service
  /// ===============================================================

  final ApiService _api = ApiService.instance;

  /// ===============================================================
  /// State
  /// ===============================================================

  bool _loading = true;

  bool _refreshing = false;

  String? _error;

  StrategyModel? _strategy;

  /// ===============================================================
  /// Init
  /// ===============================================================

  @override
  void initState() {
    super.initState();

    _loadStrategy();
  }

  /// ===============================================================
  /// Load Strategy
  /// ===============================================================

  Future<void> _loadStrategy() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.getStrategy();

      if (!mounted) return;

      setState(() {
        _strategy = result;
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
  /// Refresh Strategy
  /// ===============================================================

  Future<void> _refreshStrategy() async {
    setState(() {
      _refreshing = true;
    });

    try {
      final result = await _api.getStrategy();

      if (!mounted) return;

      setState(() {
        _strategy = result;
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
  /// App Bar
  /// ===============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Trading Strategy",
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
            onPressed: _refreshStrategy,
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
            const Icon(Icons.error_outline, color: Colors.red, size: 70),

            const SizedBox(height: 20),

            const Text(
              "Unable to load strategy",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(
              _error ?? "Unknown error occurred",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _loadStrategy,
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
            Icon(Icons.auto_graph_outlined, size: 70, color: Colors.grey),

            SizedBox(height: 20),

            Text(
              "No Strategy Available",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text(
              "No active trading strategy was found.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Strategy Dashboard
  /// ===============================================================

  Widget _buildStrategyDashboard() {
    if (_strategy == null || !_strategy!.isValid) {
      return _buildEmpty();
    }

    final strategy = _strategy!;

    return RefreshIndicator(
      onRefresh: _refreshStrategy,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// ===================================================
            /// Strategy Card
            /// ===================================================
            StrategyCard(strategy: strategy, onRefresh: _refreshStrategy),

            const SizedBox(height: 20),

            /// ===================================================
            /// Strategy Configuration
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
                      "Strategy Configuration",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _infoRow("Strategy", strategy.displayName),

                    _infoRow("Buy Threshold", strategy.buyThreshold.toString()),

                    _infoRow(
                      "Sell Threshold",
                      strategy.sellThreshold.toString(),
                    ),

                    _infoRow("Take Profit", "${strategy.tpPercent} %"),

                    _infoRow("Stop Loss", "${strategy.slPercent} %"),

                    _infoRow(
                      "Risk / Reward",
                      strategy.riskRewardRatio.toStringAsFixed(2),
                    ),

                    _infoRow("EMA Fast", strategy.emaFast.toString()),

                    _infoRow("EMA Slow", strategy.emaSlow.toString()),

                    _infoRow("RSI Buy", strategy.rsiBuy.toString()),

                    _infoRow("RSI Sell", strategy.rsiSell.toString()),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ===================================================
            /// Risk Summary
            /// ===================================================
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Text(
                      "Risk Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _metricTile(
                            "TP",
                            "${strategy.tpPercent}%",
                            Colors.green,
                          ),
                        ),

                        Expanded(
                          child: _metricTile(
                            "SL",
                            "${strategy.slPercent}%",
                            Colors.red,
                          ),
                        ),

                        Expanded(
                          child: _metricTile(
                            "RR",
                            strategy.riskRewardRatio.toStringAsFixed(2),
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Info Row
  /// ===============================================================

  Widget _infoRow(String title, String value) {
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
      color: color.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
            : _buildStrategyDashboard(),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _refreshStrategy,
        tooltip: "Refresh Strategy",
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
