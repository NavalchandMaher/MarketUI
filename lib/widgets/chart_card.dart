import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/analysis_model.dart';
import '../utils/constants.dart';
import 'common_widgets.dart';

class ChartCard extends StatelessWidget {
  final AnalysisModel analysis;

  final VoidCallback? onRefresh;

  const ChartCard({super.key, required this.analysis, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 20),

          _buildChart(),

          const SizedBox(height: 20),

          _buildStatisticsSection(),

          _buildMarketSummary(),

          _buildFooter(),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Header
  /// ===============================================================

  Widget _buildHeader() {
    return SectionHeader(
      title: "Price Chart",
      subtitle: "${analysis.symbol} • ${analysis.timeframe}",
      icon: Icons.show_chart,
      trailing: onRefresh == null
          ? null
          : IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh Chart",
            ),
    );
  }

  /// ===============================================================
  /// Chart
  /// ===============================================================

  Widget _buildChart() {
    if (analysis.chart.isEmpty) {
      return const SizedBox(
        height: 260,
        child: EmptyStateWidget(
          title: "No Chart Data",
          subtitle: "Waiting for market candles...",
          icon: Icons.show_chart,
        ),
      );
    }

    return SizedBox(height: 300, child: LineChart(_buildChartData()));
  }

  /// ===============================================================
  /// Chart Data
  /// ===============================================================

  LineChartData _buildChartData() {
    return LineChartData(
      minX: 0,
      maxX: (analysis.chart.length - 1).toDouble(),

      minY: _minPrice,

      maxY: _maxPrice,

      gridData: _gridData(),

      borderData: _borderData(),

      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: _leftTitles(),
        bottomTitles: _bottomTitles(),
      ),

      lineTouchData: _touchData(),
      lineBarsData: [
        LineChartBarData(
          spots: _buildSpots(),

          isCurved: true,

          preventCurveOverShooting: true,

          isStrokeCapRound: true,

          color: AppColors.primary,

          barWidth: 2.8,

          dotData: const FlDotData(show: false),

          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withAlpha(38),
          ),
        ),
      ],
    );
  }

  /// ===============================================================
  /// Convert Backend Candle Data to FlSpot
  /// Backend Format:
  /// [
  ///   timestamp,
  ///   close,
  ///   ema20,
  ///   ema50,
  ///   ema100,
  ///   ema200
  /// ]
  /// ===============================================================

  List<FlSpot> _buildSpots() {
    final List<FlSpot> spots = [];

    for (int i = 0; i < analysis.chart.length; i++) {
      final candle = analysis.chart[i];

      if (candle.length < 2) continue;

      spots.add(FlSpot(i.toDouble(), candle[1].toDouble()));
    }

    return spots;
  }

  /// ===============================================================
  /// Highest Price
  /// ===============================================================

  double get _maxPrice {
    if (analysis.chart.isEmpty) {
      return 1;
    }

    double max = analysis.chart.first[1].toDouble();

    for (final candle in analysis.chart) {
      final price = candle[1].toDouble();

      if (price > max) {
        max = price;
      }
    }

    return max + (max * .005);
  }

  /// ===============================================================
  /// Lowest Price
  /// ===============================================================

  double get _minPrice {
    if (analysis.chart.isEmpty) {
      return 0;
    }

    double min = analysis.chart.first[1].toDouble();

    for (final candle in analysis.chart) {
      final price = candle[1].toDouble();

      if (price < min) {
        min = price;
      }
    }

    return min - (min * .005);
  }

  /// ===============================================================
  /// Bottom Axis Titles
  /// ===============================================================

  Widget _bottomTitle(double value, TitleMeta meta) {
    final index = value.toInt();

    if (index < 0 || index >= analysis.chart.length) {
      return const SizedBox();
    }

    final candle = analysis.chart[index];

    if (candle.isEmpty) {
      return const SizedBox();
    }

    final timestamp = candle[0] as int;

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

    String label;

    switch (analysis.timeframe) {
      case "1m":
      case "5m":
      case "15m":
      case "30m":
      case "1h":
        label =
            "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
        break;

      case "4h":
      case "1d":
        label = "${date.day}/${date.month}";
        break;

      default:
        label = "${date.day}/${date.month}";
    }

    return SideTitleWidget(
      meta: meta,
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: Colors.white60),
      ),
    );
  }

  /// ===============================================================
  /// Left Axis Titles
  /// ===============================================================

  Widget _leftTitle(double value, TitleMeta meta) {
    return SideTitleWidget(
      meta: meta,
      child: Text(
        value.toStringAsFixed(0),
        style: const TextStyle(fontSize: 10, color: Colors.white60),
      ),
    );
  }

  /// ===============================================================
  /// Bottom Titles Configuration
  /// ===============================================================

  AxisTitles _bottomTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: analysis.chart.length > 20 ? 5 : 2,
        getTitlesWidget: _bottomTitle,
      ),
    );
  }

  /// ===============================================================
  /// Left Titles Configuration
  /// ===============================================================

  AxisTitles _leftTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 52,
        interval: (_maxPrice - _minPrice) / 5,
        getTitlesWidget: _leftTitle,
      ),
    );
  }

  /// ===============================================================
  /// Touch Data
  /// ===============================================================

  LineTouchData _touchData() {
    return LineTouchData(
      enabled: true,

      handleBuiltInTouches: true,

      touchTooltipData: LineTouchTooltipData(
        fitInsideHorizontally: true,

        fitInsideVertically: true,

        getTooltipItems: (spots) {
          return spots.map((spot) {
            final index = spot.x.toInt();

            if (index >= analysis.chart.length) {
              return null;
            }

            final candle = analysis.chart[index];

            final timestamp = candle[0] as int;

            final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

            return LineTooltipItem(
              "${date.day}/${date.month} "
              "${date.hour}:${date.minute}\n"
              "Price : ${spot.y.toStringAsFixed(2)}",
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          }).toList();
        },
      ),

      getTouchedSpotIndicator: (barData, indexes) {
        return indexes.map((index) {
          return TouchedSpotIndicatorData(
            FlLine(color: AppColors.primary, strokeWidth: 1, dashArray: [4, 4]),

            FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(
                  radius: 5,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
          );
        }).toList();
      },
    );
  }

  /// ===============================================================
  /// Grid Style
  /// ===============================================================

  FlGridData _gridData() {
    return FlGridData(
      show: true,

      drawVerticalLine: true,

      horizontalInterval: (_maxPrice - _minPrice) / 5,

      verticalInterval: analysis.chart.length > 30 ? 5 : 2,

      getDrawingHorizontalLine: (value) {
        return FlLine(color: Colors.white10, strokeWidth: 1);
      },

      getDrawingVerticalLine: (value) {
        return FlLine(color: Colors.white10, strokeWidth: 1);
      },
    );
  }

  /// ===============================================================
  /// Border Style
  /// ===============================================================

  FlBorderData _borderData() {
    return FlBorderData(
      show: true,
      border: Border.all(color: Colors.white24, width: 1),
    );
  }

  /// ===============================================================
  /// Statistics Section
  /// ===============================================================

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        const SectionHeader(
          title: "Price Statistics",
          subtitle: "Current Market Overview",
          icon: Icons.analytics,
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "Highest",
                value: _highestPrice.toStringAsFixed(2),
                icon: Icons.arrow_upward,
                valueColor: AppColors.buy,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "Lowest",
                value: _lowestPrice.toStringAsFixed(2),
                icon: Icons.arrow_downward,
                valueColor: AppColors.sell,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildPriceSummarySection(),

        _buildPriceChangeCard(),
      ],
    );
  }

  /// ===============================================================
  /// Highest Price
  /// ===============================================================

  double get _highestPrice {
    if (analysis.chart.isEmpty) {
      return 0;
    }

    double highest = analysis.chart.first[1].toDouble();

    for (final candle in analysis.chart) {
      final price = candle[1].toDouble();

      if (price > highest) {
        highest = price;
      }
    }

    return highest;
  }

  /// ===============================================================
  /// Lowest Price
  /// ===============================================================

  double get _lowestPrice {
    if (analysis.chart.isEmpty) {
      return 0;
    }

    double lowest = analysis.chart.first[1].toDouble();

    for (final candle in analysis.chart) {
      final price = candle[1].toDouble();

      if (price < lowest) {
        lowest = price;
      }
    }

    return lowest;
  }

  /// ===============================================================
  /// Price Summary
  /// ===============================================================

  Widget _buildPriceSummarySection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(
            child: MetricTile(
              title: "Current",
              value: _currentPrice.toStringAsFixed(2),
              icon: Icons.attach_money,
              valueColor: AppColors.primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: MetricTile(
              title: "Range",
              value: _priceRange.toStringAsFixed(2),
              icon: Icons.swap_vert,
              valueColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Price Change Card
  /// ===============================================================

  Widget _buildPriceChangeCard() {
    final bool positive = _priceChange >= 0;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: DashboardCard(
        margin: EdgeInsets.zero,
        child: Row(
          children: [
            Icon(
              positive ? Icons.trending_up : Icons.trending_down,
              color: positive ? AppColors.buy : AppColors.sell,
              size: 34,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Price Change", style: AppTextStyles.title),

                  const SizedBox(height: 6),

                  ProfitLossText(value: _priceChange, showSign: true),
                ],
              ),
            ),

            StatusChip(
              text: "${_priceChangePercent.toStringAsFixed(2)}%",
              color: positive ? AppColors.buy : AppColors.sell,
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Current Price
  /// ===============================================================

  double get _currentPrice {
    if (analysis.chart.isEmpty) {
      return 0;
    }

    return analysis.chart.last[1].toDouble();
  }

  /// ===============================================================
  /// First Price
  /// ===============================================================

  double get _firstPrice {
    if (analysis.chart.isEmpty) {
      return 0;
    }

    return analysis.chart.first[1].toDouble();
  }

  /// ===============================================================
  /// Price Range
  /// ===============================================================

  double get _priceRange {
    return _highestPrice - _lowestPrice;
  }

  /// ===============================================================
  /// Price Change
  /// ===============================================================

  double get _priceChange {
    return _currentPrice - _firstPrice;
  }

  /// ===============================================================
  /// Percentage Change
  /// ===============================================================

  double get _priceChangePercent {
    if (_firstPrice == 0) {
      return 0;
    }

    return (_priceChange / _firstPrice) * 100;
  }

  /// ===============================================================
  /// Market Summary
  /// ===============================================================

  Widget _buildMarketSummary() {
    final bool bullish = _priceChange >= 0;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: DashboardCard(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: "Market Summary", icon: Icons.insights),

            const SizedBox(height: 16),

            InfoRow(title: "Symbol", value: analysis.symbol),

            const DashboardDivider(),

            InfoRow(title: "Timeframe", value: analysis.timeframe),

            const DashboardDivider(),

            InfoRow(title: "Candles", value: analysis.chart.length.toString()),

            const DashboardDivider(),

            InfoRow(
              title: "Direction",
              value: bullish ? "Bullish" : "Bearish",
              valueColor: bullish ? AppColors.buy : AppColors.sell,
            ),

            const DashboardDivider(),

            InfoRow(title: "Market Regime", value: analysis.marketRegime),

            const DashboardDivider(),

            InfoRow(title: "Higher Timeframe", value: analysis.higherTimeframe),
          ],
        ),
      ),
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
          "Showing ${analysis.chart.length} candles • ${analysis.symbol} (${analysis.timeframe})",
          style: AppTextStyles.small,
        ),
      ),
    );
  }
}
