import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/backtest_provider.dart';

/// ===============================================================
/// Backtest Testing Screen
/// ===============================================================
class BacktestTestingScreen extends StatefulWidget {
  const BacktestTestingScreen({Key? key}) : super(key: key);

  @override
  State<BacktestTestingScreen> createState() => _BacktestTestingScreenState();
}

class _BacktestTestingScreenState extends State<BacktestTestingScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _symbolController;
  late TextEditingController _daysController;
  String _selectedTimeframe = "5m";

  final List<String> _timeframes = ["1m", "5m", "15m", "1h", "4h", "1d"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _symbolController = TextEditingController(text: "BTCUSDT");
    _daysController = TextEditingController(text: "30");

    // Load history on first open
    final provider = context.read<BacktestProvider>();
    Future.microtask(() {
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
    final days = int.tryParse(_daysController.text) ?? 30;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    if (symbol.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a symbol")));
      return;
    }

    context.read<BacktestProvider>().runBacktest(
      strategyName: 'Backtest Test',
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
                color: Colors.red.withOpacity(0.2),
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
                color: Colors.green.withOpacity(0.2),
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
                  "${provider.currentBacktest!['win_rate']?.toString() ?? "0"}%",
                ),
                _buildResultCard(
                  "Total Profit",
                  "${provider.currentBacktest!['total_pnl']?.toString() ?? "0"}",
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
              "Error loading history",
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
              "No backtest history",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.backtestHistory.length,
      itemBuilder: (context, index) {
        final backtest = provider.backtestHistory[index];
        return Card(
          color: Theme.of(context).colorScheme.surfaceContainer,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(
              "${backtest['symbol'] ?? 'UNKNOWN'} - ${backtest['timeframe'] ?? '5m'}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  "Trades: ${backtest['total_trades'] ?? 0} | Win Rate: ${backtest['win_rate'] ?? 0}%",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  "P&L: ${backtest['total_pnl'] ?? 0}",
                  style: TextStyle(
                    color: (backtest['total_pnl'] ?? 0) >= 0
                        ? Colors.green
                        : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton(
              color: Theme.of(context).colorScheme.surfaceContainer,
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    provider.deleteBacktest(backtest['id'] ?? backtest['_id']);
                  },
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
}
