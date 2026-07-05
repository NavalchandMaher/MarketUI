import 'package:flutter/material.dart';

import '../models/analysis_model.dart';
import '../utils/constants.dart';
import 'common_widgets.dart';

/// ===============================================================
/// Signal Card
/// ===============================================================

class SignalCard extends StatelessWidget {
  final AnalysisModel analysis;

  final VoidCallback? onRefresh;

  const SignalCard({super.key, required this.analysis, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 20),

          _buildSignalBadge(),

          const SizedBox(height: 20),

          _buildConfidenceCard(),

          const SizedBox(height: 20),

          _buildScoreCard(),

          const SizedBox(height: 20),

          _buildReasonCard(),

          const SizedBox(height: 20),

          _buildRecommendationCard(),

          _buildActionButtons(),

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
      title: "Trading Signal",
      subtitle: "${analysis.symbol} • ${analysis.timeframe}",
      icon: Icons.notifications_active,
      trailing: onRefresh == null
          ? null
          : IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh)),
    );
  }

  /// ===============================================================
  /// Signal Badge
  /// ===============================================================

  Widget _buildSignalBadge() {
    Color color;

    IconData icon;

    switch (analysis.signal.toUpperCase()) {
      case "BUY":
        color = AppColors.buy;
        icon = Icons.trending_up;
        break;

      case "SELL":
        color = AppColors.sell;
        icon = Icons.trending_down;
        break;

      default:
        color = AppColors.wait;
        icon = Icons.pause_circle_filled;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 60, color: color),

          const SizedBox(height: 12),

          Text(
            analysis.signal,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 8),

          Text(analysis.marketRegime, style: AppTextStyles.subtitle),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Confidence Card
  /// ===============================================================

  Widget _buildConfidenceCard() {
    Color progressColor;

    if (analysis.confidence >= 70) {
      progressColor = AppColors.buy;
    } else if (analysis.confidence >= 40) {
      progressColor = AppColors.wait;
    } else {
      progressColor = AppColors.sell;
    }

    return DashboardCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: AppColors.primary),

              const SizedBox(width: 8),

              Text("Confidence", style: AppTextStyles.title),
            ],
          ),

          const SizedBox(height: 18),

          LinearProgressIndicator(
            value: analysis.confidence / 100,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(progressColor),
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${analysis.confidence}%",
              style: AppTextStyles.value.copyWith(color: progressColor),
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Score Card
  /// ===============================================================

  Widget _buildScoreCard() {
    return DashboardCard(
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: MetricTile(
              title: "Score",
              value: analysis.score.toString(),
              icon: Icons.speed,
              valueColor: AppColors.primary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: MetricTile(
              title: "HTF",
              value: analysis.higherTimeframe,
              icon: Icons.show_chart,
              valueColor: analysis.higherTimeframe == "BULLISH"
                  ? AppColors.buy
                  : analysis.higherTimeframe == "BEARISH"
                  ? AppColors.sell
                  : AppColors.wait,
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================================================
  /// AI Reason
  /// ===============================================================

  Widget _buildReasonCard() {
    return DashboardCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: AppColors.primary),

              const SizedBox(width: 8),

              Text("AI Analysis", style: AppTextStyles.title),
            ],
          ),

          const SizedBox(height: 16),

          Text(analysis.reason, style: AppTextStyles.body),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Recommendation
  /// ===============================================================

  Widget _buildRecommendationCard() {
    Color color;

    IconData icon;

    String title;

    String message;

    switch (analysis.signal.toUpperCase()) {
      case "BUY":
        color = AppColors.buy;

        icon = Icons.trending_up;

        title = "Bullish Opportunity";

        message =
            "Momentum is positive. Consider long positions while following your risk management rules.";

        break;

      case "SELL":
        color = AppColors.sell;

        icon = Icons.trending_down;

        title = "Bearish Opportunity";

        message =
            "Market momentum is weakening. Short opportunities may exist if your strategy confirms.";

        break;

      default:
        color = AppColors.wait;

        icon = Icons.pause_circle;

        title = "Wait";

        message =
            "Current market conditions are not ideal. Wait for confirmation before opening a trade.";
    }

    return DashboardCard(
      margin: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(.10),
          borderRadius: BorderRadius.circular(14),
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

            Text(message, style: AppTextStyles.body),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: MetricTile(
                    title: "Signal",
                    value: analysis.signal,
                    valueColor: color,
                    icon: icon,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: MetricTile(
                    title: "Confidence",
                    value: "${analysis.confidence}%",
                    valueColor: color,
                    icon: Icons.verified,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Action Buttons
  /// ===============================================================

  Widget _buildActionButtons() {
    return Column(
      children: [
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text: analysis.signal == "BUY"
                    ? "Buy"
                    : analysis.signal == "SELL"
                    ? "Sell"
                    : "Wait",
                icon: analysis.signal == "BUY"
                    ? Icons.trending_up
                    : analysis.signal == "SELL"
                    ? Icons.trending_down
                    : Icons.pause,
                onPressed: () {},
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: SecondaryButton(
                text: "Refresh",
                icon: Icons.refresh,
                onPressed: onRefresh ?? () {},
              ),
            ),
          ],
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
      child: Column(
        children: [
          const Divider(),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Strategy", style: AppTextStyles.small),

              Text(
                analysis.strategy.name,
                style: AppTextStyles.small.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Version", style: AppTextStyles.small),

              Text(
                "v${analysis.strategy.version}",
                style: AppTextStyles.small.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Market", style: AppTextStyles.small),

              Text(
                analysis.marketRegime,
                style: AppTextStyles.small.copyWith(
                  color: analysis.marketRegime == "TRENDING"
                      ? AppColors.buy
                      : AppColors.wait,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
