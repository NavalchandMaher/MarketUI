import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/paper_trading_provider.dart';

/// ===============================================================
/// Enhanced Paper Trading Dashboard
/// ===============================================================
class EnhancedPaperTradingScreen extends StatefulWidget {
  const EnhancedPaperTradingScreen({super.key});

  @override
  State<EnhancedPaperTradingScreen> createState() =>
      _EnhancedPaperTradingScreenState();
}

class _EnhancedPaperTradingScreenState extends State<EnhancedPaperTradingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PaperTradingProvider>();
      provider.loadDashboard();
      provider.loadOpenTrades();
      provider.loadStatistics();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paper Trading'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
            Tab(text: 'Trades', icon: Icon(Icons.trending_up)),
            Tab(text: 'Stats', icon: Icon(Icons.bar_chart)),
          ],
        ),
      ),
      body: Consumer<PaperTradingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Dashboard Tab
              _buildDashboardTab(provider, context),
              // Trades Tab
              _buildTradesTab(provider, context),
              // Stats Tab
              _buildStatsTab(provider, context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDashboardTab(
    PaperTradingProvider provider,
    BuildContext context,
  ) {
    final dashboard = provider.dashboard;
    if (dashboard == null) {
      return const Center(child: Text('No data'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Trading Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text(provider.isTrading ? 'ACTIVE' : 'INACTIVE'),
                        backgroundColor: provider.isTrading
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (provider.isTrading)
                    ElevatedButton.icon(
                      onPressed: () async {
                        await provider.stopPaperTrading();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Paper trading stopped'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop Trading'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const _StartTradingDialog(),
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Trading'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Statistics Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Open Trades',
                  dashboard.openTrades.toString(),
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Closed Trades',
                  dashboard.closedTrades.toString(),
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Wins',
                  dashboard.wins.toString(),
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Losses',
                  dashboard.losses.toString(),
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Profit Card
          Card(
            color: dashboard.totalProfit >= 0
                ? Colors.green.shade50
                : Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Total Profit/Loss',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${dashboard.totalProfit.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: dashboard.totalProfit >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Win Rate: ${dashboard.winRate.toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradesTab(PaperTradingProvider provider, BuildContext context) {
    if (provider.openTrades.isEmpty) {
      return const Center(child: Text('No open trades'));
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadOpenTrades(forceRefresh: true),
      child: ListView.builder(
        itemCount: provider.openTrades.length,
        itemBuilder: (context, index) {
          final trade = provider.openTrades[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text('Trade #${trade['id'] ?? index}'),
              subtitle: Text('Entry: ${trade['entry_price'] ?? 'N/A'}'),
              trailing: Text(
                '${trade['current_profit'] ?? 0}%',
                style: TextStyle(
                  color: (trade['current_profit'] ?? 0) >= 0
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsTab(PaperTradingProvider provider, BuildContext context) {
    final stats = provider.statistics ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistics',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildStatRow(
                    'Total Trades',
                    stats['total_trades']?.toString() ?? '0',
                  ),
                  _buildStatRow(
                    'Winning Trades',
                    stats['winning_trades']?.toString() ?? '0',
                  ),
                  _buildStatRow(
                    'Losing Trades',
                    stats['losing_trades']?.toString() ?? '0',
                  ),
                  _buildStatRow(
                    'Average Win',
                    '\$${(stats['average_win'] ?? 0).toStringAsFixed(2)}',
                  ),
                  _buildStatRow(
                    'Average Loss',
                    '\$${(stats['average_loss'] ?? 0).toStringAsFixed(2)}',
                  ),
                  _buildStatRow(
                    'Profit Factor',
                    (stats['profit_factor'] ?? 0).toStringAsFixed(2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StartTradingDialog extends StatefulWidget {
  const _StartTradingDialog();

  @override
  State<_StartTradingDialog> createState() => _StartTradingDialogState();
}

class _StartTradingDialogState extends State<_StartTradingDialog> {
  String _selectedStrategy = '';
  String _selectedSymbol = 'EURUSD';
  String _selectedTimeframe = '1H';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start Paper Trading'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: 'Strategy Name'),
            onChanged: (value) => setState(() => _selectedStrategy = value),
          ),
          const SizedBox(height: 12),
          DropdownButton<String>(
            isExpanded: true,
            value: _selectedSymbol,
            items: const [
              DropdownMenuItem(value: 'EURUSD', child: Text('EURUSD')),
              DropdownMenuItem(value: 'GBPUSD', child: Text('GBPUSD')),
            ],
            onChanged: (value) =>
                setState(() => _selectedSymbol = value ?? 'EURUSD'),
          ),
          const SizedBox(height: 12),
          DropdownButton<String>(
            isExpanded: true,
            value: _selectedTimeframe,
            items: const [
              DropdownMenuItem(value: '1H', child: Text('1 Hour')),
              DropdownMenuItem(value: '4H', child: Text('4 Hour')),
              DropdownMenuItem(value: '1D', child: Text('Daily')),
            ],
            onChanged: (value) =>
                setState(() => _selectedTimeframe = value ?? '1H'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            await context.read<PaperTradingProvider>().startPaperTrading(
              strategyName: _selectedStrategy,
              symbol: _selectedSymbol,
              timeframe: _selectedTimeframe,
            );
            if (mounted) Navigator.pop(context);
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}
