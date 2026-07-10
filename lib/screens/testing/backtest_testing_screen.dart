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
    Future.microtask(() {
      context.read<BacktestProvider>().loadBacktestHistory();
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

    if (symbol.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a symbol")));
      return;
    }

    context.read<BacktestProvider>().runBacktest(
      symbol: symbol,
      timeframe: _selectedTimeframe,
      days: days,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
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
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "e.g., BTCUSDT",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF24292F),
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
                backgroundColor: const Color(0xFF24292F),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
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
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "e.g., 30",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF24292F),
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
              backgroundColor: provider.isRunning ? Colors.grey : Colors.green,
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

          // Error Message
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
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
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
          color: const Color(0xFF24292F),
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
              color: const Color(0xFF24292F),
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
        color: const Color(0xFF24292F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
