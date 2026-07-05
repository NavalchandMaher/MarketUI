import 'package:flutter/material.dart';

import '../models/scheduler_model.dart';
import '../utils/constants.dart';
import 'common_widgets.dart';

/// ===============================================================
/// Scheduler Card
/// Displays scheduler status and job information
/// ===============================================================

class SchedulerCard extends StatelessWidget {
  final SchedulerDashboardModel scheduler;

  final VoidCallback? onRefresh;

  const SchedulerCard({super.key, required this.scheduler, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),

          const SizedBox(height: 20),

          _buildSchedulerStatus(),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Header
  /// ===============================================================

  Widget _buildHeader() {
    return SectionHeader(
      title: "Scheduler",
      subtitle: "Background Jobs & Automation",
      icon: Icons.schedule,
      trailing: onRefresh == null
          ? null
          : IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh Scheduler",
            ),
    );
  }

  /// ===============================================================
  /// Placeholder Widgets
  /// ===============================================================

  /// ===============================================================
  /// Scheduler Status
  /// ===============================================================

  Widget _buildSchedulerStatus() {
    final schedulerInfo = scheduler.scheduler;

    final bool isRunning = schedulerInfo.running;

    final marketHealth = scheduler.marketHealth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "Scheduler",
                value: isRunning ? "RUNNING" : "STOPPED",
                icon: isRunning
                    ? Icons.play_circle_fill
                    : Icons.pause_circle_filled,
                valueColor: isRunning ? AppColors.buy : AppColors.sell,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "Jobs",
                value: schedulerInfo.totalJobs.toString(),
                icon: Icons.work_outline,
                valueColor: AppColors.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: MetricTile(
                title: "Market Health",
                value: marketHealth.marketCycle,
                icon: Icons.favorite,
                valueColor: marketHealth.isRunning
                    ? AppColors.buy
                    : AppColors.sell,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: MetricTile(
                title: "Timestamp",
                value: scheduler.timestamp == null
                    ? "-"
                    : "${scheduler.timestamp!.day}/${scheduler.timestamp!.month}/${scheduler.timestamp!.year}",
                icon: Icons.access_time,
                valueColor: Colors.orange,
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
                title: "Scheduler Status",
                value: isRunning ? "Running" : "Stopped",
                valueColor: isRunning ? AppColors.buy : AppColors.sell,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Total Jobs",
                value: schedulerInfo.totalJobs.toString(),
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Market Cycle",
                value: marketHealth.marketCycle,
                valueColor: marketHealth.isRunning
                    ? AppColors.buy
                    : AppColors.sell,
              ),

              const DashboardDivider(),

              InfoRow(
                title: "Last Update",
                value: scheduler.timestamp == null
                    ? "-"
                    : scheduler.timestamp!.toLocal().toString().substring(
                        0,
                        19,
                      ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _buildJobList(),
      ],
    );
  }

  /// ===============================================================
  /// Scheduled Jobs
  /// ===============================================================

  Widget _buildJobList() {
    final jobs = scheduler.scheduler.jobs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Scheduled Jobs",
          subtitle: "Background Tasks",
          icon: Icons.work_history,
        ),

        const SizedBox(height: 16),

        if (jobs.isEmpty)
          const DashboardCard(
            margin: EdgeInsets.zero,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text("No scheduled jobs available."),
              ),
            ),
          )
        else
          ...jobs.map(
            (job) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DashboardCard(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withOpacity(.15),
                          child: const Icon(
                            Icons.schedule,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(job.id, style: AppTextStyles.title),
                        ),

                        StatusChip(text: "ACTIVE", color: AppColors.buy),
                      ],
                    ),

                    const SizedBox(height: 16),

                    InfoRow(
                      title: "Next Run",
                      value: job.nextRun == null
                          ? "-"
                          : job.nextRun!
                                .toLocal()
                                .toString()
                                .replaceFirst("T", " ")
                                .substring(0, 19),
                    ),

                    const DashboardDivider(),

                    InfoRow(title: "Trigger", value: job.trigger),
                  ],
                ),
              ),
            ),
          ),

        const SizedBox(height: 20),

        DashboardCard(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Dashboard Jobs",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              if (scheduler.jobs.isEmpty)
                const Text("No dashboard jobs found.")
              else
                ...scheduler.jobs.map(
                  (dashboardJob) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.task_alt,
                          color: AppColors.primary,
                          size: 20,
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            dashboardJob.name,
                            style: AppTextStyles.body,
                          ),
                        ),

                        Text(
                          dashboardJob.frequency,
                          style: AppTextStyles.small,
                        ),
                      ],
                    ),
                  ),
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
    final schedulerInfo = scheduler.scheduler;

    final bool running = schedulerInfo.running;

    final Color statusColor = running ? AppColors.buy : AppColors.sell;

    final String statusText = running
        ? "Scheduler Running"
        : "Scheduler Stopped";

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
                      running ? Icons.check_circle : Icons.cancel,
                      color: statusColor,
                      size: 40,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      statusText,
                      style: AppTextStyles.title.copyWith(color: statusColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              Container(width: 1, height: 80, color: Colors.white12),

              Expanded(
                child: Column(
                  children: [
                    StatusChip(
                      text: "${schedulerInfo.totalJobs} Jobs",
                      color: AppColors.primary,
                    ),

                    const SizedBox(height: 10),

                    Text("Active Jobs", style: AppTextStyles.small),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        DashboardCard(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),

                  const SizedBox(width: 8),

                  Text("Scheduler Summary", style: AppTextStyles.title),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                running
                    ? "The scheduler is currently active and executing background jobs automatically based on their configured intervals and cron schedules."
                    : "The scheduler is currently stopped. No background jobs are being executed until it is started again.",
                style: AppTextStyles.body,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: MetricTile(
                      title: "Jobs",
                      value: schedulerInfo.totalJobs.toString(),
                      icon: Icons.work,
                      valueColor: AppColors.primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: MetricTile(
                      title: "Health",
                      value: running ? "Healthy" : "Stopped",
                      icon: Icons.favorite,
                      valueColor: statusColor,
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
            "Last Updated",
            style: AppTextStyles.small.copyWith(color: Colors.white60),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          scheduler.timestamp == null
              ? "-"
              : scheduler.timestamp!.toLocal().toString().substring(0, 19),
          textAlign: TextAlign.center,
          style: AppTextStyles.small,
        ),
      ],
    );
  }
}
