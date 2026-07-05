import 'package:flutter/material.dart';

import '../models/strategy_model.dart';
import '../utils/constants.dart';
import 'common_widgets.dart';

/// ===============================================================
/// Strategy Card
/// Displays current trading strategy configuration
/// ===============================================================

class StrategyCard extends StatelessWidget {
  final StrategyModel strategy;

  final VoidCallback? onRefresh;

  const StrategyCard({super.key, required this.strategy, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 20),

          _buildStrategyInfo(),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Header
  /// ===============================================================

  Widget _buildHeader() {
    return SectionHeader(
      title: "Trading Strategy",
      subtitle: "${strategy.name} • v${strategy.version}",
      icon: Icons.psychology,
      trailing: onRefresh == null
          ? null
          : IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh Strategy",
            ),
    );
  }

  /// ===============================================================
  /// Placeholder Widgets
  /// ===============================================================

  /// ===============================================================
  /// Strategy Information
  /// ===============================================================

  Widget _buildStrategyInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "Strategy",
                value: strategy.name,
                icon: Icons.psychology,
                valueColor: AppColors.primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "Version",
                value: "v${strategy.version}",
                icon: Icons.new_releases,
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
                title: "Buy Threshold",
                value: strategy.buyThreshold.toString(),
                icon: Icons.trending_up,
                valueColor: AppColors.buy,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "Sell Threshold",
                value: strategy.sellThreshold.toString(),
                icon: Icons.trending_down,
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
              InfoRow(title: "Strategy Name", value: strategy.name),

              const DashboardDivider(),

              InfoRow(title: "Version", value: strategy.version.toString()),

              const DashboardDivider(),

              InfoRow(
                title: "Buy Threshold",
                value: strategy.buyThreshold.toString(),
                valueColor: AppColors.buy,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Sell Threshold",
                value: strategy.sellThreshold.toString(),
                valueColor: AppColors.sell,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Take Profit",
                value: "${strategy.tpPercent.toStringAsFixed(2)} %",
                valueColor: AppColors.buy,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Stop Loss",
                value: "${strategy.slPercent.toStringAsFixed(2)} %",
                valueColor: AppColors.sell,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _buildIndicatorSettings(),
      ],
    );
  }

  /// ===============================================================
  /// Indicator Settings
  /// ===============================================================

  Widget _buildIndicatorSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Indicator Settings",
          subtitle: "Technical Indicator Configuration",
          icon: Icons.tune,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "EMA Fast",
                value: strategy.emaFast.toString(),
                icon: Icons.show_chart,
                valueColor: AppColors.primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "EMA Slow",
                value: strategy.emaSlow.toString(),
                icon: Icons.multiline_chart,
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
                title: "RSI Buy",
                value: strategy.rsiBuy.toString(),
                icon: Icons.trending_up,
                valueColor: AppColors.buy,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "RSI Sell",
                value: strategy.rsiSell.toString(),
                icon: Icons.trending_down,
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
                title: "EMA Fast Period",
                value: strategy.emaFast.toString(),
              ),

              const DashboardDivider(),

              InfoRow(
                title: "EMA Slow Period",
                value: strategy.emaSlow.toString(),
              ),

              const DashboardDivider(),

              InfoRow(
                title: "RSI Buy Level",
                value: strategy.rsiBuy.toString(),
                valueColor: AppColors.buy,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "RSI Sell Level",
                value: strategy.rsiSell.toString(),
                valueColor: AppColors.sell,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Trading Style",
                value: strategy.emaFast < strategy.emaSlow
                    ? "Trend Following"
                    : "Momentum",
                valueColor: AppColors.primary,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Risk Profile",
                value: strategy.slPercent <= 1
                    ? "Low Risk"
                    : strategy.slPercent <= 2
                    ? "Medium Risk"
                    : "High Risk",
                valueColor: strategy.slPercent <= 1
                    ? AppColors.buy
                    : strategy.slPercent <= 2
                    ? AppColors.wait
                    : AppColors.sell,
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
  /// Strategy Summary
  /// ===============================================================

  Widget _buildFooter() {
    final bool trendFollowing = strategy.emaFast < strategy.emaSlow;

    final String riskLevel = strategy.slPercent <= 1
        ? "LOW"
        : strategy.slPercent <= 2
        ? "MEDIUM"
        : "HIGH";

    final Color riskColor = strategy.slPercent <= 1
        ? AppColors.buy
        : strategy.slPercent <= 2
        ? AppColors.wait
        : AppColors.sell;

    return Column(
      children: [
        DashboardCard(
          margin: EdgeInsets.zero,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Icon(Icons.psychology, size: 34, color: AppColors.primary),

                    const SizedBox(height: 10),

                    Text(
                      strategy.name,
                      style: AppTextStyles.title,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Version ${strategy.version}",
                      style: AppTextStyles.small,
                    ),
                  ],
                ),
              ),

              Container(width: 1, height: 90, color: Colors.white12),

              Expanded(
                child: Column(
                  children: [
                    StatusChip(text: riskLevel, color: riskColor),

                    const SizedBox(height: 12),

                    Text("Risk Profile", style: AppTextStyles.small),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        DashboardCard(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: AppColors.primary),

                  const SizedBox(width: 8),

                  Text("Strategy Summary", style: AppTextStyles.title),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                trendFollowing
                    ? "This strategy uses EMA crossover with RSI confirmation to identify trend-following opportunities. It is suitable for trending markets and aims to capture medium-term price movements."
                    : "This strategy is configured for momentum-based trading. Review EMA and RSI settings to ensure they match current market conditions.",
                style: AppTextStyles.body,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      title: "TP",
                      value: "${strategy.tpPercent.toStringAsFixed(1)}%",
                      icon: Icons.flag,
                      valueColor: AppColors.buy,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: MetricTile(
                      title: "SL",
                      value: "${strategy.slPercent.toStringAsFixed(1)}%",
                      icon: Icons.shield,
                      valueColor: AppColors.sell,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: Text(
            "EMA ${strategy.emaFast} / ${strategy.emaSlow} • "
            "RSI ${strategy.rsiBuy}-${strategy.rsiSell}",
            style: AppTextStyles.small.copyWith(color: Colors.white60),
          ),
        ),
      ],
    );
  }
}
