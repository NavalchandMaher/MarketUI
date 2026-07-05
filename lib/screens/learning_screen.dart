import 'package:flutter/material.dart';

import '../models/learning_log_model.dart';
import '../services/api_service.dart';
import '../widgets/learning_card.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  /// ===============================================================
  /// API
  /// ===============================================================

  final ApiService _api = ApiService.instance;

  /// ===============================================================
  /// State
  /// ===============================================================

  bool _loading = true;

  bool _refreshing = false;

  String? _error;

  LearningLogModel? _learning;

  /// ===============================================================
  /// Init
  /// ===============================================================

  @override
  void initState() {
    super.initState();

    _loadLearningLogs();
  }

  /// ===============================================================
  /// Load Learning Logs
  /// ===============================================================

  Future<void> _loadLearningLogs() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.getLearningLogs();

      if (!mounted) return;

      setState(() {
        _learning = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  /// ===============================================================
  /// Refresh Learning Logs
  /// ===============================================================

  Future<void> _refreshLearningLogs() async {
    setState(() {
      _refreshing = true;
    });

    try {
      final result = await _api.getLearningLogs();

      if (!mounted) return;

      setState(() {
        _learning = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
        });
      }
    }
  }

  /// ===============================================================
  /// Helper Methods
  /// ===============================================================

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case "SUCCESS":
      case "COMPLETED":
      case "ACTIVE":
        return Colors.green;

      case "FAILED":
      case "ERROR":
      case "REJECTED":
        return Colors.red;

      case "PENDING":
      case "RUNNING":
        return Colors.orange;

      default:
        return Colors.blue;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case "SUCCESS":
      case "COMPLETED":
      case "ACTIVE":
        return Icons.check_circle;

      case "FAILED":
      case "ERROR":
      case "REJECTED":
        return Icons.cancel;

      case "PENDING":
      case "RUNNING":
        return Icons.schedule;

      default:
        return Icons.info;
    }
  }

  /// ===============================================================
  /// App Bar
  /// ===============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Learning Logs",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      elevation: 0,
      actions: [
        if (_refreshing)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLearningLogs,
          ),
      ],
    );
  }

  /// ===============================================================
  /// Loading Widget
  /// ===============================================================

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  /// ===============================================================
  /// Error Widget
  /// ===============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 70, color: Colors.red),

            const SizedBox(height: 20),

            const Text(
              "Unable to load learning logs",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(_error ?? "Unknown Error", textAlign: TextAlign.center),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _loadLearningLogs,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Empty Widget
  /// ===============================================================

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 70, color: Colors.grey),

            SizedBox(height: 20),

            Text(
              "No Learning Logs",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text(
              "The AI learning engine has not generated any learning logs yet.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Learning Dashboard
  /// ===============================================================

  Widget _buildLearningDashboard() {
    if (_learning == null || _learning!.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: _refreshLearningLogs,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// =====================================================
            /// Learning Card
            /// =====================================================
            LearningCard(learning: _learning!, onRefresh: _refreshLearningLogs),

            const SizedBox(height: 20),

            /// =====================================================
            /// Summary
            /// =====================================================
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Learning Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _summaryRow(
                      "Total Learning Logs",
                      _learning!.count.toString(),
                    ),

                    _summaryRow(
                      "Latest Strategy",
                      _learning!.logs.first.strategy,
                    ),

                    _summaryRow(
                      "Latest Parameter",
                      _learning!.logs.first.parameter,
                    ),

                    _summaryRow("Latest Status", _learning!.logs.first.status),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// =====================================================
            /// Recent Learning Logs
            /// =====================================================
            const Text(
              "Recent Learning Logs",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            ..._learning!.logs.map(
              (log) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(log.status).withOpacity(.15),
                    child: Icon(
                      _statusIcon(log.status),
                      color: _statusColor(log.status),
                    ),
                  ),

                  title: Text(
                    log.strategy,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),

                      Text("Parameter : ${log.parameter}"),

                      Text("${log.oldValue} → ${log.newValue}"),

                      if (log.reason.isNotEmpty) Text("Reason : ${log.reason}"),
                    ],
                  ),

                  trailing: Chip(
                    label: Text(log.status),
                    backgroundColor: _statusColor(log.status).withOpacity(.15),
                    labelStyle: TextStyle(color: _statusColor(log.status)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Summary Row
  /// ===============================================================

  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          Flexible(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Build
  /// ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),

      body: SafeArea(
        child: _loading
            ? _buildLoading()
            : _error != null
            ? _buildError()
            : _buildLearningDashboard(),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _refreshLearningLogs,
        tooltip: "Refresh Learning Logs",
        child: _refreshing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.refresh),
      ),
    );
  }
}
