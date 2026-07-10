import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/scheduler_provider.dart';

/// ===============================================================
/// Scheduler Dashboard Screen
/// ===============================================================
class SchedulerDashboardScreen extends StatefulWidget {
  const SchedulerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SchedulerDashboardScreen> createState() =>
      _SchedulerDashboardScreenState();
}

class _SchedulerDashboardScreenState extends State<SchedulerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load scheduler data on first open
    Future.microtask(() {
      final provider = context.read<SchedulerProvider>();
      provider.loadSchedulerStatus();
      provider.loadSchedulerDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        title: const Text('Scheduler'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<SchedulerProvider>(
        builder: (context, provider, _) => RefreshIndicator(
          onRefresh: () => provider.refreshAll(),
          backgroundColor: const Color(0xFF24292F),
          color: Colors.green,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Section
                _buildStatusSection(provider),
                const SizedBox(height: 24),

                // Dashboard Metrics
                if (provider.dashboard != null) _buildMetricsSection(provider),
                const SizedBox(height: 24),

                // Quick Actions
                _buildActionsSection(provider),
                const SizedBox(height: 24),

                // Jobs List
                if (provider.jobs.isNotEmpty) _buildJobsList(provider),

                // Last Operation Result
                if (provider.lastOperation != null)
                  Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildOperationResult(provider),
                    ],
                  ),

                // Error Message
                if (provider.errorMessage != null)
                  Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildErrorMessage(provider),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection(SchedulerProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF24292F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: provider.isSchedulerRunning
              ? Colors.green.withOpacity(0.5)
              : Colors.red.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Scheduler Status",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: provider.isSchedulerRunning
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                provider.isSchedulerRunning ? "Running" : "Stopped",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: provider.isSchedulerRunning
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            provider.status?['message'] ?? "No status available",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(SchedulerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dashboard Metrics",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                "Completed",
                provider.completedJobs.toString(),
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                "Failed",
                provider.failedJobs.toString(),
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF24292F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(SchedulerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          provider.runMarketNow();
                        },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Run Market"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          provider.runNightlyNow();
                        },
                  icon: const Icon(Icons.dark_mode),
                  label: const Text("Run Nightly"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobsList(SchedulerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Scheduled Jobs",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...provider.jobs.map((job) {
          return Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF24292F),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.green, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job is String ? job : job['name'] ?? 'Unknown Job',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (job is Map && job['schedule'] != null)
                        Text(
                          "Schedule: ${job['schedule']}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildOperationResult(SchedulerProvider provider) {
    final isSuccess = !provider.lastOperation!.startsWith('Failed');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSuccess
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess ? Colors.green : Colors.red,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.lastOperation!,
              style: TextStyle(
                color: isSuccess ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(SchedulerProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red, width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
