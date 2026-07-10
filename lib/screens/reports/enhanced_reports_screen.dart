import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/reports_provider.dart';

/// ===============================================================
/// Enhanced Reports Screen
/// ===============================================================
class EnhancedReportsScreen extends StatefulWidget {
  const EnhancedReportsScreen({super.key});

  @override
  State<EnhancedReportsScreen> createState() => _EnhancedReportsScreenState();
}

class _EnhancedReportsScreenState extends State<EnhancedReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ReportsProvider>();
      provider.refreshAll();
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
        title: const Text('Reports'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Daily'),
            Tab(text: 'Monthly'),
            Tab(text: 'Equity'),
            Tab(text: 'Performance'),
          ],
        ),
      ),
      body: Consumer<ReportsProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildDashboardTab(provider),
              _buildDailyTab(provider),
              _buildMonthlyTab(provider),
              _buildEquityTab(provider),
              _buildPerformanceTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDashboardTab(ReportsProvider provider) {
    if (provider.isLoading && provider.dashboardReport == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final report = provider.dashboardReport ?? {};
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReportCard(
            'Total Trades',
            report['total_trades']?.toString() ?? '0',
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            'Win Rate',
            '${report['win_rate']?.toStringAsFixed(2) ?? '0'}%',
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            'Total Profit',
            '\$${report['total_profit']?.toStringAsFixed(2) ?? '0'}',
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            'Best Trade',
            '\$${report['best_trade']?.toStringAsFixed(2) ?? '0'}',
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            'Worst Trade',
            '\$${report['worst_trade']?.toStringAsFixed(2) ?? '0'}',
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTab(ReportsProvider provider) {
    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadDailyReport(date: DateTime.now());
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Select Date'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  await provider.loadDailyReport(date: date);
                }
              },
            ),
            const Divider(),
            if (provider.dailyReport != null) ...[
              _buildReportCard(
                'Trades Today',
                provider.dailyReport!['trades']?.toString() ?? '0',
              ),
              const SizedBox(height: 12),
              _buildReportCard(
                'Daily Profit',
                '\$${provider.dailyReport!['profit']?.toStringAsFixed(2) ?? '0'}',
              ),
              const SizedBox(height: 12),
              _buildReportCard(
                'Win Rate Today',
                '${provider.dailyReport!['win_rate']?.toStringAsFixed(2) ?? '0'}%',
              ),
            ] else
              const Center(child: Text('Select a date to view report')),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTab(ReportsProvider provider) {
    return RefreshIndicator(
      onRefresh: () async {
        final now = DateTime.now();
        await provider.loadMonthlyReport(year: now.year, month: now.month);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Current Month'),
            ),
            const Divider(),
            if (provider.monthlyReport != null) ...[
              _buildReportCard(
                'Monthly Trades',
                provider.monthlyReport!['trades']?.toString() ?? '0',
              ),
              const SizedBox(height: 12),
              _buildReportCard(
                'Monthly Profit',
                '\$${provider.monthlyReport!['profit']?.toStringAsFixed(2) ?? '0'}',
              ),
              const SizedBox(height: 12),
              _buildReportCard(
                'Monthly Win Rate',
                '${provider.monthlyReport!['win_rate']?.toStringAsFixed(2) ?? '0'}%',
              ),
            ] else
              const Center(child: Text('Loading monthly report...')),
          ],
        ),
      ),
    );
  }

  Widget _buildEquityTab(ReportsProvider provider) {
    if (provider.isLoading && provider.equityReport == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final report = provider.equityReport ?? {};
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReportCard(
            'Starting Equity',
            '\$${report['starting_equity']?.toStringAsFixed(2) ?? '0'}',
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            'Current Equity',
            '\$${report['current_equity']?.toStringAsFixed(2) ?? '0'}',
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            'Equity Change',
            '\$${report['equity_change']?.toStringAsFixed(2) ?? '0'}',
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            'Equity Peak',
            '\$${report['peak_equity']?.toStringAsFixed(2) ?? '0'}',
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            'Equity Drawdown',
            '${report['max_drawdown']?.toStringAsFixed(2) ?? '0'}%',
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab(ReportsProvider provider) {
    if (provider.isLoading && provider.performanceReport == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final report = provider.performanceReport ?? {};
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReportCard(
            'Profit Factor',
            report['profit_factor']?.toStringAsFixed(2) ?? '0',
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            'Sharpe Ratio',
            report['sharpe_ratio']?.toStringAsFixed(2) ?? '0',
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            'Sortino Ratio',
            report['sortino_ratio']?.toStringAsFixed(2) ?? '0',
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            'Return on Risk',
            '${report['return_on_risk']?.toStringAsFixed(2) ?? '0'}%',
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            'Consecutive Wins',
            report['consecutive_wins']?.toString() ?? '0',
          ),
          const SizedBox(height: 12),
          _buildReportCard(
            'Consecutive Losses',
            report['consecutive_losses']?.toString() ?? '0',
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
