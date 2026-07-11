import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/symbol_timeframe_selector.dart';
import 'analysis_screen.dart';
import 'reports_screen.dart';
import 'trades_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Market Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: state.refreshHomeData,
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? _buildLoading()
            : state.errorMessage != null
            ? _buildError(state.errorMessage!, state)
            : Stack(
                children: [
                  _buildDashboard(context, state),
                  if (state.isRefreshing)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha((0.65 * 255).round()),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Refreshing...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SkeletonLoader(height: 120),
        const SizedBox(height: 16),
        const SkeletonLoader(height: 100),
        const SizedBox(height: 16),
        const SkeletonLoader(height: 100),
      ],
    );
  }

  Widget _buildError(String errorMessage, AppState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 70, color: Colors.red),
            const SizedBox(height: 20),
            const Text('Unable to load dashboard', style: AppTextStyles.title),
            const SizedBox(height: 10),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: state.refreshHomeData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, AppState state) {
    final signal = state.signal;
    final confidence = state.confidence;
    final currentPrice = state.currentPrice;
    final balance = state.currentBalance;
    final openTrades = state.openTrades;
    final todayPnl = state.todayProfitLoss;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SymbolTimeframeSelector(
          symbol: state.selectedSymbol,
          timeframe: state.selectedTimeframe,
          onSymbolChanged: state.setSymbol,
          onTimeframeChanged: state.setTimeframe,
        ),
        const SizedBox(height: 16),
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Market Snapshot', style: AppTextStyles.title),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      title: 'Signal',
                      value: signal,
                      icon: signal == AppConstants.buy
                          ? Icons.trending_up
                          : signal == AppConstants.sell
                          ? Icons.trending_down
                          : Icons.pause_circle,
                      valueColor: signal == AppConstants.buy
                          ? AppColors.buy
                          : signal == AppConstants.sell
                          ? AppColors.sell
                          : AppColors.wait,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricTile(
                      title: 'Confidence',
                      value: '$confidence%',
                      icon: Icons.verified,
                      valueColor: confidence >= 70
                          ? AppColors.buy
                          : confidence >= 40
                          ? AppColors.wait
                          : AppColors.sell,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      title: 'Current Price',
                      value: '₹${currentPrice.toStringAsFixed(2)}',
                      icon: Icons.attach_money,
                      valueColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricTile(
                      title: 'Balance',
                      value: '₹${balance.toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet,
                      valueColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      title: 'Open Trades',
                      value: openTrades.toString(),
                      icon: Icons.swap_horiz,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricTile(
                      title: "Today's P/L",
                      value: '₹${todayPnl.toStringAsFixed(2)}',
                      icon: Icons.trending_flat,
                      valueColor: todayPnl >= 0
                          ? AppColors.buy
                          : AppColors.sell,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DashboardCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Quick Actions', style: AppTextStyles.title),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ActionChip(
                    icon: Icons.analytics,
                    label: 'View Analysis',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Scaffold(
                            body: SafeArea(child: AnalysisScreen()),
                          ),
                        ),
                      );
                    },
                  ),
                  _ActionChip(
                    icon: Icons.show_chart,
                    label: 'View Trades',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Scaffold(
                            body: SafeArea(child: TradesScreen()),
                          ),
                        ),
                      );
                    },
                  ),
                  _ActionChip(
                    icon: Icons.insights,
                    label: 'View Reports',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const Scaffold(
                            body: SafeArea(child: ReportsScreen()),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}
