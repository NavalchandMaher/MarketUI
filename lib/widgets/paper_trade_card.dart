import 'package:flutter/material.dart';

import '../models/paper_trade_model.dart';
import '../utils/constants.dart';
import 'common_widgets.dart';

/// ===============================================================
/// Paper Trade Card
/// ===============================================================

class PaperTradeCard extends StatelessWidget {
  final PaperTradeModel paperTrade;

  final VoidCallback? onRefresh;

  const PaperTradeCard({super.key, required this.paperTrade, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 20),

          _buildTradeSummary(),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Header
  /// ===============================================================

  Widget _buildHeader() {
    return SectionHeader(
      title: "Paper Trading",
      subtitle: "Virtual Trading Performance",
      icon: Icons.account_balance,
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
  /// Trade Summary
  /// ===============================================================

  Widget _buildTradeSummary() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "Open Trades",
                value: paperTrade.openTrades.toString(),
                icon: Icons.trending_up,
                valueColor: AppColors.primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "Closed Trades",
                value: paperTrade.closedTrades.toString(),
                icon: Icons.assignment_turned_in,
                valueColor: Colors.orange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "Wins",
                value: paperTrade.wins.toString(),
                icon: Icons.emoji_events,
                valueColor: AppColors.buy,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "Losses",
                value: paperTrade.losses.toString(),
                icon: Icons.cancel,
                valueColor: AppColors.sell,
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
                title: "Open Trades",
                value: paperTrade.openTrades.toString(),
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Closed Trades",
                value: paperTrade.closedTrades.toString(),
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Wins",
                value: paperTrade.wins.toString(),
                valueColor: AppColors.buy,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Losses",
                value: paperTrade.losses.toString(),
                valueColor: AppColors.sell,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Win Rate",
                value: "${paperTrade.winRate.toStringAsFixed(2)}%",
                valueColor: paperTrade.winRate >= 60
                    ? AppColors.buy
                    : paperTrade.winRate >= 40
                    ? AppColors.wait
                    : AppColors.sell,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Total Profit",
                value: "₹${paperTrade.totalProfit.toStringAsFixed(2)}",
                valueColor: paperTrade.totalProfit >= 0
                    ? AppColors.buy
                    : AppColors.sell,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _buildStatistics(),
      ],
    );
  }

  /// ===============================================================
  /// Trading Statistics
  /// ===============================================================

  Widget _buildStatistics() {
    final bool profitable = paperTrade.totalProfit >= 0;

    final double winLossRatio = paperTrade.losses == 0
        ? paperTrade.wins.toDouble()
        : paperTrade.wins / paperTrade.losses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Trading Statistics",
          subtitle: "Paper Trading Analytics",
          icon: Icons.analytics,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "Win / Loss",
                value: winLossRatio.toStringAsFixed(2),
                icon: Icons.balance,
                valueColor: AppColors.primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "Success",
                value: "${paperTrade.winRate.toStringAsFixed(2)}%",
                icon: Icons.verified,
                valueColor: paperTrade.winRate >= 60
                    ? AppColors.buy
                    : paperTrade.winRate >= 40
                    ? AppColors.wait
                    : AppColors.sell,
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
                title: "Win/Loss Ratio",
                value: winLossRatio.toStringAsFixed(2),
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Win Rate",
                value: "${paperTrade.winRate.toStringAsFixed(2)}%",
                valueColor: paperTrade.winRate >= 60
                    ? AppColors.buy
                    : AppColors.wait,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Net Result",
                value: profitable ? "Profitable" : "Loss",
                valueColor: profitable ? AppColors.buy : AppColors.sell,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Total Profit",
                value: "₹${paperTrade.totalProfit.toStringAsFixed(2)}",
                valueColor: profitable ? AppColors.buy : AppColors.sell,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Trade Status",
                value: paperTrade.openTrades > 0 ? "Active" : "No Open Trades",
                valueColor: paperTrade.openTrades > 0
                    ? AppColors.buy
                    : AppColors.wait,
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
    final bool profitable = paperTrade.totalProfit >= 0;

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
                      profitable ? Icons.check_circle : Icons.warning_amber,
                      color: profitable ? AppColors.buy : AppColors.sell,
                      size: 34,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      profitable ? "Profitable" : "In Loss",
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
                      text: "${paperTrade.winRate.toStringAsFixed(2)}%",
                      color: paperTrade.winRate >= 60
                          ? AppColors.buy
                          : paperTrade.winRate >= 40
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

        Text(
          "Paper Trading Summary",
          style: AppTextStyles.small.copyWith(color: Colors.white60),
        ),

        const SizedBox(height: 6),

        Text(
          "Open: ${paperTrade.openTrades} • "
          "Closed: ${paperTrade.closedTrades} • "
          "Profit: ₹${paperTrade.totalProfit.toStringAsFixed(2)}",
          textAlign: TextAlign.center,
          style: AppTextStyles.small,
        ),
      ],
    );
  }
}
