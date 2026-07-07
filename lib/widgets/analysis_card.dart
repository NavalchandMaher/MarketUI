import 'package:flutter/material.dart';

import '../models/analysis_model.dart';
import '../utils/constants.dart';
import 'common_widgets.dart';

class AnalysisCard extends StatelessWidget {
  final AnalysisModel analysis;

  final VoidCallback? onRefresh;

  const AnalysisCard({super.key, required this.analysis, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 20),

          _buildSignalSection(),

          const SizedBox(height: 20),

          _buildPriceSection(),

          const SizedBox(height: 20),

          _buildStrategySection(),

          const SizedBox(height: 20),

          _buildRecommendationSection(),

          const SizedBox(height: 20),

          _buildIndicatorsSection(),

          const SizedBox(height: 20),

          _buildMarketMetricsSection(),

          const SizedBox(height: 20),

          _buildPaperTradeSection(),

          const SizedBox(height: 20),

          _buildReasonSection(),

          const SizedBox(height: 20),

          _buildSummarySection(),

          const SizedBox(height: 20),

          _buildChartSection(),

          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SectionHeader(
      title: "Market Analysis",
      subtitle: "${analysis.symbol} • ${analysis.timeframe}",
      icon: Icons.analytics_outlined,
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
  /// Signal Section
  /// ===============================================================

  Widget _buildSignalSection() {
    Color signalColor;

    IconData signalIcon;

    switch (analysis.signal.toUpperCase()) {
      case "BUY":
        signalColor = AppColors.buy;
        signalIcon = Icons.trending_up;
        break;

      case "SELL":
        signalColor = AppColors.sell;
        signalIcon = Icons.trending_down;
        break;

      default:
        signalColor = AppColors.wait;
        signalIcon = Icons.pause_circle_outline;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: signalColor.withAlpha(31),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: signalColor.withAlpha(89)),
      ),
      child: Column(
        children: [
          Icon(signalIcon, size: 48, color: signalColor),

          const SizedBox(height: 12),

          Text(
            analysis.signal,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: signalColor,
            ),
          ),

          const SizedBox(height: 8),

          StatusChip(
            text: "${analysis.confidence}% Confidence",
            color: signalColor,
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: MetricTile(
                  title: "Score",
                  value: analysis.score.toString(),
                  icon: Icons.speed,
                  valueColor: signalColor,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: MetricTile(
                  title: "Trend",
                  value: analysis.higherTimeframe,
                  icon: Icons.show_chart,
                  valueColor: analysis.isBullish
                      ? AppColors.buy
                      : analysis.isSell
                      ? AppColors.sell
                      : AppColors.wait,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Price Section
  /// ===============================================================

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Market", icon: Icons.currency_bitcoin),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "Current Price",
                value: "\$${analysis.price.toStringAsFixed(2)}",
                icon: Icons.attach_money,
                valueColor: AppColors.primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "Regime",
                value: analysis.marketRegime,
                icon: Icons.insights,
                valueColor: analysis.marketRegime == "TRENDING"
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
                title: "Timeframe",
                value: analysis.timeframe,
                icon: Icons.schedule,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "Symbol",
                value: analysis.symbol,
                icon: Icons.currency_exchange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ===============================================================
  /// Strategy Section
  /// ===============================================================

  Widget _buildStrategySection() {
    final strategy = analysis.strategy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        const SectionHeader(title: "Strategy", icon: Icons.psychology),

        const SizedBox(height: 12),

        DashboardCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              InfoRow(title: "Name", value: strategy.name),

              const DashboardDivider(),

              InfoRow(title: "Version", value: strategy.version.toString()),

              const DashboardDivider(),

              InfoRow(
                title: "Buy Threshold",
                value: strategy.buyThreshold.toString(),
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Sell Threshold",
                value: strategy.sellThreshold.toString(),
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
      ],
    );
  }

  /// ===============================================================
  /// Recommendation Section
  /// ===============================================================

  Widget _buildRecommendationSection() {
    Color color;

    IconData icon;

    String title;

    switch (analysis.signal.toUpperCase()) {
      case "BUY":
        color = AppColors.buy;
        icon = Icons.trending_up;
        title = "Bullish Setup";
        break;

      case "SELL":
        color = AppColors.sell;
        icon = Icons.trending_down;
        title = "Bearish Setup";
        break;

      default:
        color = AppColors.wait;
        icon = Icons.pause_circle;
        title = "Wait For Confirmation";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        const SectionHeader(
          title: "Recommendation",
          icon: Icons.lightbulb_outline,
        ),

        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(.30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 28),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(analysis.reason, style: AppTextStyles.body),

              const SizedBox(height: 20),

              LinearProgressIndicator(
                value: analysis.confidence / 100,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation(color),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${analysis.confidence}% Confidence",
                  style: AppTextStyles.small,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ===============================================================
  /// Indicators Section
  /// ===============================================================

  Widget _buildIndicatorsSection() {
    final indicators = analysis.indicators;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        const SectionHeader(
          title: "Technical Indicators",
          subtitle: "Live Market Indicators",
          icon: Icons.bar_chart,
        ),

        const SizedBox(height: 12),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            MetricTile(
              title: "EMA 20",
              value: indicators.ema20.toStringAsFixed(2),
              icon: Icons.show_chart,
              valueColor: AppColors.primary,
            ),

            MetricTile(
              title: "EMA 50",
              value: indicators.ema50.toStringAsFixed(2),
              icon: Icons.show_chart,
              valueColor: Colors.orange,
            ),

            MetricTile(
              title: "EMA 100",
              value: indicators.ema100.toStringAsFixed(2),
              icon: Icons.show_chart,
              valueColor: Colors.deepPurple,
            ),

            MetricTile(
              title: "EMA 200",
              value: indicators.ema200.toStringAsFixed(2),
              icon: Icons.show_chart,
              valueColor: Colors.indigo,
            ),

            MetricTile(
              title: "RSI",
              value: indicators.rsi.toStringAsFixed(2),
              icon: Icons.speed,
              valueColor: _rsiColor(indicators.rsi),
            ),

            MetricTile(
              title: "MACD",
              value: indicators.macd.toStringAsFixed(2),
              icon: Icons.timeline,
              valueColor: indicators.macd >= 0 ? AppColors.buy : AppColors.sell,
            ),

            MetricTile(
              title: "ADX",
              value: indicators.adx.toStringAsFixed(2),
              icon: Icons.trending_up,
              valueColor: _adxColor(indicators.adx),
            ),
          ],
        ),
      ],
    );
  }

  /// ===============================================================
  /// RSI Color
  /// ===============================================================

  Color _rsiColor(double rsi) {
    if (rsi >= 70) {
      return AppColors.sell;
    }

    if (rsi <= 30) {
      return AppColors.buy;
    }

    return AppColors.wait;
  }

  /// ===============================================================
  /// ADX Color
  /// ===============================================================

  Color _adxColor(double adx) {
    if (adx >= 25) {
      return AppColors.buy;
    }

    return AppColors.wait;
  }

  /// ===============================================================
  /// Market Metrics
  /// ===============================================================

  Widget _buildMarketMetricsSection() {
    final indicators = analysis.indicators;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        const SectionHeader(
          title: "Market Metrics",
          subtitle: "Options & Volume Analysis",
          icon: Icons.analytics,
        ),

        const SizedBox(height: 12),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            MetricTile(
              title: "ATR",
              value: indicators.atr.toStringAsFixed(2),
              icon: Icons.swap_vert,
              valueColor: Colors.orange,
            ),

            MetricTile(
              title: "PCR",
              value: indicators.pcr.toStringAsFixed(2),
              icon: Icons.balance,
              valueColor: _pcrColor(indicators.pcr),
            ),

            MetricTile(
              title: "Volume Ratio",
              value: indicators.volumeRatio.toStringAsFixed(2),
              icon: Icons.bar_chart,
              valueColor: _volumeColor(indicators.volumeRatio),
            ),

            MetricTile(
              title: "OI Change %",
              value: "${indicators.oiChangePct.toStringAsFixed(2)}%",
              icon: Icons.stacked_line_chart,
              valueColor: indicators.oiChangePct >= 0
                  ? AppColors.buy
                  : AppColors.sell,
            ),
          ],
        ),
      ],
    );
  }

  /// ===============================================================
  /// Paper Trade
  /// ===============================================================

  Widget _buildPaperTradeSection() {
    final trade = analysis.paperTrade;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        const SectionHeader(
          title: "Paper Trade",
          subtitle: "Suggested Trade",
          icon: Icons.account_balance_wallet,
        ),

        const SizedBox(height: 12),

        DashboardCard(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              InfoRow(
                title: "Signal",
                value: trade.signal,
                valueColor: trade.signal == "BUY"
                    ? AppColors.buy
                    : trade.signal == "SELL"
                    ? AppColors.sell
                    : AppColors.wait,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Entry",
                value: trade.entryPrice.toStringAsFixed(2),
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Take Profit",
                value: trade.takeProfit.toStringAsFixed(2),
                valueColor: AppColors.buy,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Stop Loss",
                value: trade.stopLoss.toStringAsFixed(2),
                valueColor: AppColors.sell,
              ),

              const DashboardDivider(),

              InfoRow(title: "Opened", value: trade.openedAt),
            ],
          ),
        ),
      ],
    );
  }

  /// ===============================================================
  /// PCR Color
  /// ===============================================================

  Color _pcrColor(double pcr) {
    if (pcr > 1.2) {
      return AppColors.buy;
    }

    if (pcr < 0.7) {
      return AppColors.sell;
    }

    return AppColors.wait;
  }

  /// ===============================================================
  /// Volume Color
  /// ===============================================================

  Color _volumeColor(double ratio) {
    if (ratio >= 1.5) {
      return AppColors.buy;
    }

    if (ratio <= 0.5) {
      return AppColors.sell;
    }

    return AppColors.primary;
  }

  /// ===============================================================
  /// AI Analysis Reason
  /// ===============================================================

  Widget _buildReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        const SectionHeader(
          title: "AI Analysis",
          subtitle: "Why this signal was generated",
          icon: Icons.psychology_alt,
        ),

        const SizedBox(height: 12),

        DashboardCard(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.primary, size: 22),

                  const SizedBox(width: 10),

                  Text("Trading Reason", style: AppTextStyles.title),
                ],
              ),

              const SizedBox(height: 16),

              Text(analysis.reason, style: AppTextStyles.body),
            ],
          ),
        ),
      ],
    );
  }

  /// ===============================================================
  /// Market Summary
  /// ===============================================================

  Widget _buildSummarySection() {
    final indicators = analysis.indicators;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        const SectionHeader(
          title: "Market Summary",
          subtitle: "Quick Overview",
          icon: Icons.dashboard_customize,
        ),

        const SizedBox(height: 12),

        DashboardCard(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              InfoRow(
                title: "Signal",
                value: analysis.signal,
                valueColor: analysis.isBuy
                    ? AppColors.buy
                    : analysis.isSell
                    ? AppColors.sell
                    : AppColors.wait,
              ),

              const DashboardDivider(),

              InfoRow(title: "Confidence", value: "${analysis.confidence} %"),

              const DashboardDivider(),

              InfoRow(title: "Market Regime", value: analysis.marketRegime),

              const DashboardDivider(),

              InfoRow(
                title: "Higher Timeframe",
                value: analysis.higherTimeframe,
              ),

              const DashboardDivider(),

              InfoRow(title: "RSI", value: indicators.rsi.toStringAsFixed(2)),

              const DashboardDivider(),

              InfoRow(title: "MACD", value: indicators.macd.toStringAsFixed(2)),

              const DashboardDivider(),

              InfoRow(title: "ADX", value: indicators.adx.toStringAsFixed(2)),

              const DashboardDivider(),

              InfoRow(title: "PCR", value: indicators.pcr.toStringAsFixed(2)),
            ],
          ),
        ),
      ],
    );
  }

  /// ===============================================================
  /// Chart Preview
  /// ===============================================================

  Widget _buildChartSection() {
    final candles = analysis.chart;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        const SectionHeader(
          title: "Recent Candles",
          subtitle: "Latest market data",
          icon: Icons.candlestick_chart,
        ),

        const SizedBox(height: 12),

        DashboardCard(
          margin: EdgeInsets.zero,
          child: candles.isEmpty
              ? const EmptyStateWidget(
                  title: "No Chart Data",
                  subtitle: "No candle data available.",
                  icon: Icons.show_chart,
                )
              : Column(
                  children: [
                    for (int i = 0; i < candles.length && i < 5; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Candle ${i + 1}",
                                style: AppTextStyles.body,
                              ),
                            ),

                            Expanded(
                              child: Text(
                                candles[i][1].toStringAsFixed(2),
                                textAlign: TextAlign.end,
                              ),
                            ),

                            Expanded(
                              child: Text(
                                candles[i][2].toStringAsFixed(2),
                                textAlign: TextAlign.end,
                              ),
                            ),

                            Expanded(
                              child: Text(
                                candles[i][3].toStringAsFixed(2),
                                textAlign: TextAlign.end,
                              ),
                            ),

                            Expanded(
                              child: Text(
                                candles[i][4].toStringAsFixed(2),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  /// ===============================================================
  /// Footer
  /// ===============================================================

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Center(
        child: Text(
          "Strategy: ${analysis.strategy.name}  •  "
          "Version ${analysis.strategy.version}",
          style: AppTextStyles.small,
        ),
      ),
    );
  }
}
