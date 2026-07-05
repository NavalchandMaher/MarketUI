import 'package:flutter/material.dart';

import '../models/analysis_model.dart';
import '../services/api_service.dart';

import '../widgets/analysis_card.dart';
import '../widgets/chart_card.dart';
import '../widgets/signal_card.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
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

  AnalysisModel? _analysis;

  /// ===============================================================
  /// Init
  /// ===============================================================

  @override
  void initState() {
    super.initState();

    _loadAnalysis();
  }

  /// ===============================================================
  /// Load Analysis
  /// ===============================================================

  Future<void> _loadAnalysis() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.getAnalysis();

      if (!mounted) return;

      setState(() {
        _analysis = result;
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
  /// Refresh Analysis
  /// ===============================================================

  Future<void> _refreshAnalysis() async {
    setState(() {
      _refreshing = true;
    });

    try {
      final result = await _api.getAnalysis();

      if (!mounted) return;

      setState(() {
        _analysis = result;
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
  /// App Bar
  /// ===============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Market Analysis",
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
            onPressed: _refreshAnalysis,
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
            const Icon(Icons.error_outline, color: Colors.red, size: 70),

            const SizedBox(height: 20),

            const Text(
              "Unable to load analysis",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text(_error ?? "Unknown Error", textAlign: TextAlign.center),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _loadAnalysis,
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
            Icon(Icons.analytics_outlined, size: 70, color: Colors.grey),

            SizedBox(height: 20),

            Text(
              "No Analysis Available",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),

            Text(
              "Please refresh to fetch market analysis.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Analysis Dashboard
  /// ===============================================================

  Widget _buildAnalysisDashboard() {
    if (_analysis == null) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: _refreshAnalysis,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// ===================================================
            /// Analysis Card
            /// ===================================================
            AnalysisCard(analysis: _analysis!, onRefresh: _refreshAnalysis),

            const SizedBox(height: 16),

            /// ===================================================
            /// Signal Card
            /// ===================================================
            SignalCard(analysis: _analysis!),

            const SizedBox(height: 16),

            /// ===================================================
            /// Chart Card
            /// ===================================================
            ChartCard(analysis: _analysis!),

            const SizedBox(height: 24),
          ],
        ),
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
                : _buildAnalysisDashboard(),
      ),
    );
  }
}
