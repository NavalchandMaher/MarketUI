import 'package:flutter/material.dart';

import '../models/performance_model.dart';
import '../utils/constants.dart';
import 'common_widgets.dart';

/// ===============================================================
/// Performance Card
/// ===============================================================

class PerformanceCard extends StatelessWidget {
  final PerformanceModel performance;

  final VoidCallback? onRefresh;

  const PerformanceCard({super.key, required this.performance, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 20),

          _buildAccountSummary(),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Header
  /// ===============================================================

  Widget _buildHeader() {
    return SectionHeader(
      title: "Performance",
      subtitle: "Trading Account Summary",
      icon: Icons.account_balance_wallet,
      trailing: onRefresh == null
          ? null
          : IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh",
            ),
    );
  }

  /// ===============================================================
  /// Placeholder Widgets
  /// ===============================================================

  /// ===============================================================
  /// Account Summary
  /// ===============================================================

  Widget _buildAccountSummary() {
    final account = performance.account;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "Current Balance",
                value: "₹${account.currentBalance.toStringAsFixed(2)}",
                icon: Icons.account_balance_wallet,
                valueColor: AppColors.primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "Net Profit",
                value: "₹${account.netProfit.toStringAsFixed(2)}",
                icon: account.netProfit >= 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                valueColor: account.netProfit >= 0
                    ? AppColors.buy
                    : AppColors.sell,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "Win Rate",
                value: "${account.winRate.toStringAsFixed(2)}%",
                icon: Icons.emoji_events,
                valueColor: account.winRate >= 60
                    ? AppColors.buy
                    : account.winRate >= 40
                    ? AppColors.wait
                    : AppColors.sell,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "Total Trades",
                value: account.totalTrades.toString(),
                icon: Icons.swap_horiz,
                valueColor: AppColors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        DashboardCard(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              InfoRow(
                title: "Initial Balance",
                value: "₹${account.initialBalance.toStringAsFixed(2)}",
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Current Balance",
                value: "₹${account.currentBalance.toStringAsFixed(2)}",
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Net Profit",
                value: "₹${account.netProfit.toStringAsFixed(2)}",
                valueColor: account.netProfit >= 0
                    ? AppColors.buy
                    : AppColors.sell,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Win Rate",
                value: "${account.winRate.toStringAsFixed(2)}%",
                valueColor: account.winRate >= 60
                    ? AppColors.buy
                    : AppColors.wait,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Wins",
                value: account.wins.toString(),
                valueColor: AppColors.buy,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Losses",
                value: account.losses.toString(),
                valueColor: AppColors.sell,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _buildMetricsSection(),
      ],
    );
  }

  /// ===============================================================
  /// Performance Metrics
  /// ===============================================================

  Widget _buildMetricsSection() {
    final metrics = performance.snapshot.metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Performance Metrics",
          subtitle: "Trading Analytics",
          icon: Icons.analytics,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "Profit Factor",
                value: metrics.profitFactor.toStringAsFixed(2),
                icon: Icons.trending_up,
                valueColor: metrics.profitFactor >= 1
                    ? AppColors.buy
                    : AppColors.sell,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "Sharpe Ratio",
                value: metrics.sharpeRatio.toStringAsFixed(2),
                icon: Icons.show_chart,
                valueColor: metrics.sharpeRatio >= 1
                    ? AppColors.buy
                    : AppColors.wait,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "Drawdown",
                value: metrics.maxDrawdown.toStringAsFixed(2),
                icon: Icons.trending_down,
                valueColor: AppColors.sell,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "Risk / Reward",
                value: metrics.riskReward.toStringAsFixed(2),
                icon: Icons.balance,
                valueColor: metrics.riskReward >= 1
                    ? AppColors.buy
                    : AppColors.wait,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        DashboardCard(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              InfoRow(
                title: "Profit Factor",
                value: metrics.profitFactor.toStringAsFixed(2),
                valueColor: metrics.profitFactor >= 1
                    ? AppColors.buy
                    : AppColors.sell,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Sharpe Ratio",
                value: metrics.sharpeRatio.toStringAsFixed(2),
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Maximum Drawdown",
                value: "₹${metrics.maxDrawdown.toStringAsFixed(2)}",
                valueColor: AppColors.sell,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Average Win",
                value: "₹${metrics.averageWin.toStringAsFixed(2)}",
                valueColor: AppColors.buy,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Average Loss",
                value: "₹${metrics.averageLoss.toStringAsFixed(2)}",
                valueColor: AppColors.sell,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Expectancy",
                value: metrics.riskReward.toStringAsFixed(2),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _buildFooter(),
      ],
    );
  }

  /// ===============================================================
  /// Footer
  /// ===============================================================

  Widget _buildFooter() {
    final account = performance.account;

    final bool profitable = account.netProfit >= 0;

    return Column(
      children: [
        DashboardCard(
          margin: EdgeInsets.zero,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Icon(
                      profitable ? Icons.verified : Icons.warning_amber,
                      color: profitable ? AppColors.buy : AppColors.sell,
                      size: 34,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      profitable ? "Profitable" : "Needs Improvement",
                      style: AppTextStyles.title.copyWith(
                        color: profitable ? AppColors.buy : AppColors.sell,
                      ),
                    ),
                  ],
                ),
              ),

              Container(width: 1, height: 70, color: Colors.white12),

              Expanded(
                child: Column(
                  children: [
                    Text("Win Rate", style: AppTextStyles.small),

                    const SizedBox(height: 8),

                    StatusChip(
                      text: "${account.winRate.toStringAsFixed(2)}%",
                      color: account.winRate >= 60
                          ? AppColors.buy
                          : account.winRate >= 40
                          ? AppColors.wait
                          : AppColors.sell,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: Text(
            "Performance Summary",
            style: AppTextStyles.small.copyWith(color: Colors.white60),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "Balance : ₹${account.currentBalance.toStringAsFixed(2)}"
          "   •   "
          "Trades : ${account.totalTrades}",
          style: AppTextStyles.small,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
