import 'package:flutter/material.dart';

import '../models/learning_log_model.dart';
import '../utils/constants.dart';
import 'common_widgets.dart';

/// ===============================================================
/// Learning Card
/// Displays AI learning logs and training history.
/// ===============================================================

class LearningCard extends StatelessWidget {
  final LearningLogModel learning;

  final VoidCallback? onRefresh;

  const LearningCard({super.key, required this.learning, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildLearningContent(),
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
      title: "Learning Center",
      subtitle: "AI Learning & Strategy Logs",
      icon: Icons.school,
      trailing: onRefresh == null
          ? null
          : IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh Learning Logs",
            ),
    );
  }

  /// ===============================================================
  /// Placeholder Widgets
  /// ===============================================================

  /// ===============================================================
  /// Learning Content
  /// ===============================================================

  Widget _buildLearningContent() {
    if (learning.logs.isEmpty) {
      return DashboardCard(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            children: [
              const Icon(Icons.school_outlined, size: 70, color: Colors.grey),

              const SizedBox(height: 20),

              Text(
                "No Learning Logs Available",
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                "The AI learning engine has not generated any learning records yet.",
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...learning.logs.map(
          (log) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildLearningItem(log),
          ),
        ),

        const SizedBox(height: 20),

        _buildLearningStatistics(),
      ],
    );
  }

  /// ===============================================================
  /// Learning Item
  /// ===============================================================

  Widget _buildLearningItem(LearningLog log) {
    return DashboardCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(.15),
                child: const Icon(Icons.psychology, color: AppColors.primary),
              ),

              const SizedBox(width: 12),

              Expanded(child: Text(log.strategy, style: AppTextStyles.title)),

              StatusChip(
                text: log.status,
                color: log.status.toUpperCase() == "SUCCESS"
                    ? AppColors.buy
                    : AppColors.wait,
              ),
            ],
          ),

          const SizedBox(height: 16),

          InfoRow(title: "Parameter", value: log.parameter),

          const DashboardDivider(),

          InfoRow(title: "Old Value", value: log.oldValue),

          const DashboardDivider(),

          InfoRow(title: "New Value", value: log.newValue),

          const DashboardDivider(),

          InfoRow(title: "Reason", value: log.reason),

          const DashboardDivider(),

          InfoRow(
            title: "Created",
            value: log.createdAt == null
                ? "-"
                : log.createdAt!.toLocal().toString().substring(0, 19),
          ),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Learning Statistics
  /// ===============================================================

  Widget _buildLearningStatistics() {
    final totalLogs = learning.logs.length;

    final successLogs = learning.logs
        .where((e) => e.status.toUpperCase() == "SUCCESS")
        .length;

    final failedLogs = totalLogs - successLogs;

    final successRate = totalLogs == 0 ? 0.0 : (successLogs / totalLogs) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Learning Statistics",
          subtitle: "AI Training Summary",
          icon: Icons.analytics,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "Logs",
                value: totalLogs.toString(),
                icon: Icons.menu_book,
                valueColor: AppColors.primary,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "Success",
                value: "${successRate.toStringAsFixed(1)}%",
                icon: Icons.check_circle,
                valueColor: AppColors.buy,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        DashboardCard(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              InfoRow(title: "Total Logs", value: totalLogs.toString()),

              const DashboardDivider(),

              InfoRow(
                title: "Successful",
                value: successLogs.toString(),
                valueColor: AppColors.buy,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Failed",
                value: failedLogs.toString(),
                valueColor: AppColors.sell,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Success Rate",
                value: "${successRate.toStringAsFixed(1)}%",
                valueColor: AppColors.buy,
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
    return DashboardCard(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          const Icon(Icons.school, color: AppColors.primary, size: 40),

          const SizedBox(height: 12),

          Text("AI Learning Engine", style: AppTextStyles.title),

          const SizedBox(height: 8),

          Text(
            learning.logs.isEmpty
                ? "No learning data available."
                : "The learning engine continuously analyzes completed trades to improve future trading decisions.",
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          StatusChip(
            text: learning.logs.isEmpty ? "IDLE" : "ACTIVE",
            color: learning.logs.isEmpty ? AppColors.wait : AppColors.buy,
          ),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Footer
  /// ===============================================================
}
