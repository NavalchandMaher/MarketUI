import 'package:flutter/material.dart';

import '../models/backtest_model.dart';
import '../service_locator.dart';
import '../services/api/v3_api_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final V3ApiService _api = getIt<V3ApiService>();

  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  BacktestHistoryModel? _history;
  final Set<String> _expandedIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.getBacktestHistory();
      if (!mounted) return;

      setState(() {
        _history = BacktestHistoryModel.fromJson(List<dynamic>.from(result));
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

  Future<void> _refreshHistory() async {
    if (!mounted) return;

    setState(() {
      _refreshing = true;
    });

    try {
      final result = await _api.getBacktestHistory();
      if (!mounted) return;

      setState(() {
        _history = BacktestHistoryModel.fromJson(List<dynamic>.from(result));
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

  Color _resultCardColor(BacktestResult result) {
    if (result.netProfit > 0 && result.wins > result.losses) {
      return Colors.green;
    }
    if (result.netProfit < 0 || result.losses > result.wins) {
      return Colors.red;
    }
    return Colors.orange;
  }

  IconData _profitIcon(double profit) {
    if (profit > 0) return Icons.trending_up;
    if (profit < 0) return Icons.trending_down;
    return Icons.remove;
  }

  String _formatCurrency(double value) => '₹${value.toStringAsFixed(2)}';

  String _formatDate(DateTime dateTime) =>
      dateTime.toLocal().toString().substring(0, 19);

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Backtest History',
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
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _refreshHistory,
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 70, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Unable to load history',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(_error ?? 'Unknown error', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 70, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'No Backtest History',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Run a backtest to generate historical results.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryDashboard() {
    if (_history == null || _history!.history.isEmpty) {
      return _buildEmptyState();
    }

    final sortedResults = _history!.sortedHistory;

    return RefreshIndicator(
      onRefresh: _refreshHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: sortedResults.length,
        itemBuilder: (context, index) {
          final result = sortedResults[index];
          final cardColor = _resultCardColor(result);
          final expanded = _expandedIds.contains(result.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() {
                  if (expanded) {
                    _expandedIds.remove(result.id);
                  } else {
                    _expandedIds.clear();
                    _expandedIds.add(result.id);
                  }
                });
              },
              child: Card(
                elevation: 2,
                color: cardColor.withOpacity(0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(
                    color: cardColor.withOpacity(0.85),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              result.strategyName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Chip(
                            label: Text(result.symbol),
                            backgroundColor: cardColor.withOpacity(0.15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _profitIcon(result.netProfit),
                                color: cardColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatCurrency(result.netProfit),
                                style: TextStyle(
                                  color: cardColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            result.timeframe,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      if (expanded) ...<Widget>[
                        const SizedBox(height: 12),
                        const Divider(height: 24),
                        _infoRow('Timeframe', result.timeframe),
                        _infoRow('Days', result.days.toString()),
                        _infoRow('Trades', result.totalTrades.toString()),
                        _infoRow('Wins', result.wins.toString()),
                        _infoRow('Losses', result.losses.toString()),
                        _infoRow(
                          'Win Rate',
                          '${result.winRate.toStringAsFixed(2)} %',
                        ),
                        _infoRow(
                          'Profit Factor',
                          result.profitFactor.toStringAsFixed(2),
                        ),
                        _infoRow(
                          'Drawdown',
                          result.drawdown.toStringAsFixed(2),
                        ),
                        _infoRow(
                          'Sharpe Ratio',
                          result.sharpeRatio.toStringAsFixed(2),
                        ),
                        if (result.createdAt != null)
                          _infoRow('Created', _formatDate(result.createdAt!)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _loading
            ? _buildLoadingState()
            : _error != null
            ? _buildErrorState()
            : _buildHistoryDashboard(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshHistory,
        tooltip: 'Refresh History',
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
