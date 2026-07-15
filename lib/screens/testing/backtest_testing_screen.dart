import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/backtest_provider.dart';

/// ===============================================================
/// Backtest Testing Screen
/// ===============================================================
class BacktestTestingScreen extends StatefulWidget {
  const BacktestTestingScreen({super.key});

  @override
  State<BacktestTestingScreen> createState() => _BacktestTestingScreenState();
}

class _BacktestTestingScreenState extends State<BacktestTestingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _symbolController;
  late TextEditingController _daysController;
  String _selectedTimeframe = "5m";
  String? _selectedStrategyName;

  final List<String> _timeframes = ["1m", "5m", "15m", "1h", "4h", "1d"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _symbolController = TextEditingController(text: "BTCUSDT");
    _daysController = TextEditingController(text: "30");

    // Load saved strategies and history on first open
    final provider = context.read<BacktestProvider>();
    Future.microtask(() {
      provider.loadStrategies();
      provider.loadBacktestHistory();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _symbolController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  void _runBacktest() {
    final symbol = _symbolController.text.trim();
    final strategyName = _selectedStrategyName?.trim() ?? '';
    final days = int.tryParse(_daysController.text) ?? 30;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    if (symbol.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a symbol")));
      return;
    }

    if (strategyName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a strategy")));
      return;
    }

    context.read<BacktestProvider>().runBacktest(
      strategyName: strategyName,
      symbol: symbol,
      timeframe: _selectedTimeframe,
      startDate: startDate,
      endDate: endDate,
      initialCapital: 10000.0,
      commission: 0.1,
      slippage: 0.1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Backtest'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<BacktestProvider>(
        builder: (context, provider, _) => Column(
          children: [
            // Tab Bar
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.green,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "Run Backtest"),
                Tab(text: "History"),
              ],
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Run Backtest
                  _buildRunBacktestTab(provider),
                  // Tab 2: History
                  _buildHistoryTab(provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunBacktestTab(BacktestProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          const Text(
            "Configure & Run Backtest",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),

          // Strategy Selector
          const Text("Select Strategy", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedStrategyName,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: "Choose a saved strategy",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            items: provider.strategies.map((strategy) {
              final strategyName =
                  (strategy['strategy_name'] ?? strategy['name'] ?? '')
                      .toString();
              return DropdownMenuItem<String>(
                value: strategyName,
                child: Text(strategyName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStrategyName = value;
                if (value == null) return;

                final selectedStrategy = provider.strategies.firstWhere(
                  (strategy) =>
                      (strategy['strategy_name'] ?? strategy['name'] ?? '')
                          .toString() ==
                      value,
                  orElse: () => <String, dynamic>{},
                );

                if (selectedStrategy is Map<String, dynamic>) {
                  final symbol = (selectedStrategy['symbol'] ?? 'BTCUSDT')
                      .toString();
                  final timeframe = (selectedStrategy['timeframe'] ?? '5m')
                      .toString();
                  _symbolController.text = symbol;
                  _selectedTimeframe = timeframe;
                }
              });
            },
          ),
          const SizedBox(height: 20),

          // Symbol Input
          const Text("Trading Symbol", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _symbolController,
            decoration: InputDecoration(
              hintText: "e.g., BTCUSDT",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 20),

          // Timeframe Selection
          const Text("Timeframe", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _timeframes.map((tf) {
              final isSelected = _selectedTimeframe == tf;
              return ChoiceChip(
                label: Text(tf),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedTimeframe = tf;
                  });
                },
                selectedColor: Colors.green,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Days Input
          const Text("Historical Days", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: _daysController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "e.g., 30",
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 24),

          // Run Button
          ElevatedButton(
            onPressed: provider.isRunning ? null : _runBacktest,
            style: ElevatedButton.styleFrom(
              backgroundColor: provider.isRunning
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: provider.isRunning
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    "Run Backtest",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          // Status Messages
          if (provider.errorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 0.5),
              ),
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          if (provider.successMessage != null)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green, width: 0.5),
              ),
              child: Text(
                provider.successMessage!,
                style: const TextStyle(color: Colors.green, fontSize: 12),
              ),
            ),

          // Results (if backtest completed)
          if (provider.currentBacktest != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Text(
                  "Backtest Results",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildResultCard(
                  "Total Trades",
                  provider.currentBacktest!['total_trades']?.toString() ?? "0",
                ),
                _buildResultCard(
                  "Win Rate",
                  '${provider.currentBacktest!['win_rate']?.toString() ?? '0'}%',
                ),
                _buildResultCard(
                  'Total Profit',
                  provider.currentBacktest!['total_pnl']?.toString() ?? '0',
                ),
                _buildResultCard(
                  "Profit Factor",
                  provider.currentBacktest!['profit_factor']?.toString() ?? "0",
                ),
              ],
            ),
        ],
      ),
    );
  }

  Color _resultCardColorFromMetrics(Map<String, dynamic> data) {
    final netProfit = _metricDoubleValue(data, 'net_profit');
    final wins = _metricIntValue(data, 'wins');
    final losses = _metricIntValue(data, 'losses');

    if (netProfit > 0 && wins > losses) {
      return Colors.green;
    }
    if (netProfit < 0 || losses > wins) {
      return Colors.red;
    }
    return Colors.orange;
  }

  String _statusLabelFromMetrics(Map<String, dynamic> data) {
    final netProfit = _metricDoubleValue(data, 'net_profit');
    if (netProfit > 0) return 'Profitable';
    if (netProfit < 0) return 'Loss-making';
    return 'Balanced';
  }

  String _formatCurrency(double value) => '₹${value.toStringAsFixed(2)}';

  double _metricDoubleValue(Map<String, dynamic> data, String key) {
    final source = data[key];
    if (source is num) return source.toDouble();
    return 0;
  }

  int _metricIntValue(Map<String, dynamic> data, String key) {
    final source = data[key];
    if (source is num) return source.toInt();
    return 0;
  }

  Map<String, dynamic> _extractResultData(dynamic entry) {
    if (entry is! Map) {
      return <String, dynamic>{};
    }

    final raw = Map<String, dynamic>.from(entry);
    if (raw['result'] is Map) {
      final result = Map<String, dynamic>.from(raw['result']);
      result.addAll(raw);
      return result;
    }

    return raw;
  }

  List<dynamic> _sortedHistoryItems(List<dynamic> items) {
    final sorted = [...items];
    sorted.sort((a, b) {
      final aData = _extractResultData(a);
      final bData = _extractResultData(b);

      final profitFactorCompare = _metricDoubleValue(
        bData,
        'profit_factor',
      ).compareTo(_metricDoubleValue(aData, 'profit_factor'));
      if (profitFactorCompare != 0) {
        return profitFactorCompare;
      }

      final netProfitCompare = _metricDoubleValue(
        bData,
        'net_profit',
      ).compareTo(_metricDoubleValue(aData, 'net_profit'));
      if (netProfitCompare != 0) {
        return netProfitCompare;
      }

      final winRateCompare = _metricDoubleValue(
        bData,
        'win_rate',
      ).compareTo(_metricDoubleValue(aData, 'win_rate'));
      if (winRateCompare != 0) {
        return winRateCompare;
      }

      return _metricDoubleValue(
        bData,
        'wins',
      ).compareTo(_metricDoubleValue(aData, 'wins'));
    });
    return sorted;
  }

  Widget _buildHistoryTab(BacktestProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading history',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (provider.backtestHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            const Text(
              'No backtest history',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final sortedHistory = _sortedHistoryItems(provider.backtestHistory);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedHistory.length,
      itemBuilder: (context, index) {
        final historyEntry = sortedHistory[index];
        final historyMap = historyEntry is Map
            ? Map<String, dynamic>.from(historyEntry)
            : <String, dynamic>{};
        final data = _extractResultData(historyMap);
        final cardColor = _resultCardColorFromMetrics(data);
        final netProfit = _metricDoubleValue(data, 'net_profit');
        final profitFactor = _metricDoubleValue(data, 'profit_factor');

        String createdAt = '';
        try {
          createdAt = historyMap['created_at']?.toString() ?? '';
        } catch (_) {
          createdAt = '';
        }

        final title =
            '${data['symbol'] ?? historyMap['symbol'] ?? 'UNKNOWN'} - '
            '${data['timeframe'] ?? historyMap['timeframe'] ?? '5m'}';
        final subtitle =
            data['strategy_name'] ?? historyMap['strategy_name'] ?? '';
        final symbolText = data['symbol'] ?? historyMap['symbol'] ?? '';
        final timeframeText =
            data['timeframe'] ?? historyMap['timeframe'] ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cardColor, width: 4.5),
            boxShadow: [
              BoxShadow(
                color: cardColor.withValues(alpha: 0.14),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              leading: Icon(Icons.show_chart, color: cardColor),
              title: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: cardColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      _statusLabelFromMetrics(data),
                      style: TextStyle(
                        color: cardColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                'Net Profit ${_formatCurrency(netProfit)} • PF ${profitFactor.toStringAsFixed(2)}',
                style: TextStyle(
                  color: cardColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildResultCard(
                              'Total Trades',
                              _metricValue(data, 'total_trades'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildResultCard(
                              'Win Rate',
                              _metricValue(data, 'win_rate', percent: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildResultCard(
                              'Net Profit',
                              _metricValue(data, 'net_profit'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildResultCard(
                              'Profit Factor',
                              _metricValue(data, 'profit_factor'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildResultCard(
                              'Gross Profit',
                              _metricValue(data, 'gross_profit'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildResultCard(
                              'Gross Loss',
                              _metricValue(data, 'gross_loss'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildResultCard(
                              'Drawdown',
                              _metricValue(data, 'drawdown'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildResultCard(
                              'Sharpe',
                              _metricValue(data, 'sharpe_ratio'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildResultCard(
                        'Expectancy',
                        _metricValue(data, 'expectancy'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Details',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('Symbol: $symbolText'),
                      Text('Timeframe: $timeframeText'),
                      Text('Days: ${data['days'] ?? historyMap['days'] ?? ''}'),
                      Text('Created: $createdAt'),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status: ${historyMap['status'] ?? 'unknown'}',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Row(
                            children: [
                              if ((historyMap['status'] ?? '') == 'failed')
                                ElevatedButton.icon(
                                  onPressed: provider.isRunning
                                      ? null
                                      : () async {
                                          final ok = await provider
                                              .retryBacktest(historyMap);
                                          if (!mounted) return;
                                          if (!context.mounted) return;
                                          final messenger =
                                              ScaffoldMessenger.of(context);
                                          if (ok) {
                                            messenger.showSnackBar(
                                              const SnackBar(
                                                content: Text('Retry started'),
                                              ),
                                            );
                                          } else {
                                            messenger.showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Retry failed to start',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              PopupMenuButton(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainer,
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onTap: () {
                                      provider.deleteBacktest(
                                        historyMap['id'] ?? historyMap['_id'],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Try multiple locations for a metric: result map, top-level, nested 'metrics' or 'stats'
  String _metricValue(
    Map<String, dynamic> backtest,
    String key, {
    bool percent = false,
  }) {
    dynamic val;
    if (backtest['result'] is Map) {
      final res = Map<String, dynamic>.from(backtest['result']);
      if (res.containsKey(key)) val = res[key];
      if (val == null && res['metrics'] is Map) val = res['metrics'][key];
      if (val == null && res['stats'] is Map) val = res['stats'][key];
    }

    if (val == null && backtest.containsKey(key)) val = backtest[key];
    if (val == null && backtest['result'] is Map) {
      final res = Map<String, dynamic>.from(backtest['result']);
      if (res.containsKey(key)) val = res[key];
    }

    if (val == null) return percent ? '0%' : '0';
    try {
      if (val is num) {
        return percent ? '$val%' : val.toString();
      }
      return val.toString();
    } catch (_) {
      return val.toString();
    }
  }
}
