import 'package:flutter/material.dart';

import '../models/analysis_model.dart';
import '../services/api/v3_api_service.dart';
import '../service_locator.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';
import '../widgets/chart_card.dart';
import '../widgets/common_widgets.dart';
import '../widgets/symbol_timeframe_selector.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  // Use authenticated V3 API service (ensures Authorization header present)
  final V3ApiService _api = getIt<V3ApiService>();

  String _selectedSymbol = AppConstants.defaultSymbol;
  String _selectedTimeframe = AppConstants.defaultTimeframe;
  bool _loading = true;
  bool _refreshing = false;
  String? _error;
  AnalysisModel? _analysis;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.getAnalysis(
        symbol: _selectedSymbol,
        timeframe: _selectedTimeframe,
      );
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

  Future<void> _refreshAnalysis() async {
    setState(() {
      _refreshing = true;
    });

    try {
      final result = await _api.getAnalysis(
        symbol: _selectedSymbol,
        timeframe: _selectedTimeframe,
      );
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

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Market Analysis',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
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
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAnalysis,
          ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

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
              'Unable to load analysis',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(_error ?? 'Unknown Error', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAnalysis,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

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
              'No Analysis Available',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Please refresh to fetch market analysis.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisDashboard() {
    if (_analysis == null) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: _refreshAnalysis,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: ResponsiveSize.getPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SymbolTimeframeSelector(
              symbol: _selectedSymbol,
              timeframe: _selectedTimeframe,
              onSymbolChanged: (value) {
                setState(() {
                  _selectedSymbol = value;
                });
                _loadAnalysis();
              },
              onTimeframeChanged: (value) {
                setState(() {
                  _selectedTimeframe = value;
                });
                _loadAnalysis();
              },
            ),
            const SizedBox(height: 16),
            _buildOverviewCard(_analysis!),
            const SizedBox(height: 16),
            ChartCard(analysis: _analysis!),
            const SizedBox(height: 16),
            _buildIndicatorGrid(_analysis!),
            const SizedBox(height: 16),
            _buildStrategySummary(_analysis!),
            const SizedBox(height: 16),
            _buildReasonCard(_analysis!),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(AnalysisModel analysis) {
    final signalColor = analysis.isBuy
        ? AppColors.buy
        : analysis.isSell
        ? AppColors.sell
        : AppColors.wait;

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: signalColor.withAlpha((0.14 * 255).round()),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  analysis.isBuy
                      ? Icons.trending_up
                      : analysis.isSell
                      ? Icons.trending_down
                      : Icons.pause_circle_outline,
                  color: signalColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      analysis.signal,
                      style: AppTextStyles.value.copyWith(color: signalColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${analysis.symbol} • ${analysis.timeframe}',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              ),
              StatusChip(
                text: analysis.marketRegime,
                color: analysis.isBullish
                    ? AppColors.buy
                    : analysis.isBearish
                    ? AppColors.sell
                    : AppColors.wait,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              MetricTile(
                title: 'Confidence',
                value: '${analysis.confidence}%',
                icon: Icons.shield,
                valueColor: signalColor,
              ),
              MetricTile(
                title: 'Score',
                value: analysis.score.toString(),
                icon: Icons.speed,
                valueColor: AppColors.primary,
              ),
              MetricTile(
                title: 'Price',
                value: '₹${analysis.price.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                valueColor: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorGrid(AnalysisModel analysis) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Market Indicators',
            subtitle: 'Visual indicator summary',
            icon: Icons.bar_chart,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: ResponsiveBreakpoints.isTablet(context) ? 3 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              MetricTile(
                title: 'RSI',
                value: analysis.indicators.rsi.toStringAsFixed(2),
                icon: Icons.speed,
                valueColor: _getRsiColor(analysis.indicators.rsi),
              ),
              MetricTile(
                title: 'ADX',
                value: analysis.indicators.adx.toStringAsFixed(2),
                icon: Icons.trending_up,
                valueColor: _getAdxColor(analysis.indicators.adx),
              ),
              MetricTile(
                title: 'MACD',
                value: analysis.indicators.macd.toStringAsFixed(2),
                icon: Icons.timeline,
                valueColor: analysis.indicators.macd >= 0
                    ? AppColors.buy
                    : AppColors.sell,
              ),
              MetricTile(
                title: 'PCR',
                value: analysis.indicators.pcr.toStringAsFixed(2),
                icon: Icons.balance,
                valueColor: _getPcrColor(analysis.indicators.pcr),
              ),
              MetricTile(
                title: 'Volume',
                value: analysis.indicators.volumeRatio.toStringAsFixed(2),
                icon: Icons.bar_chart,
                valueColor: _getVolumeColor(analysis.indicators.volumeRatio),
              ),
              MetricTile(
                title: 'OI Change',
                value: '${analysis.indicators.oiChangePct.toStringAsFixed(2)}%',
                icon: Icons.swap_vert,
                valueColor: analysis.indicators.oiChangePct >= 0
                    ? AppColors.buy
                    : AppColors.sell,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStrategySummary(AnalysisModel analysis) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Strategy Summary',
            subtitle: 'Core trade configuration',
            icon: Icons.auto_graph,
          ),
          const SizedBox(height: 16),
          InfoRow(title: 'Strategy', value: analysis.strategy.name),
          const Divider(),
          InfoRow(title: 'TP', value: '${analysis.strategy.tpPercent}%'),
          const Divider(),
          InfoRow(title: 'SL', value: '${analysis.strategy.slPercent}%'),
          const Divider(),
          InfoRow(
            title: 'Buy Threshold',
            value: analysis.strategy.buyThreshold.toString(),
          ),
          const Divider(),
          InfoRow(
            title: 'Sell Threshold',
            value: analysis.strategy.sellThreshold.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard(AnalysisModel analysis) {
    final theme = Theme.of(context);
    final signalColor = analysis.isBuy
        ? AppColors.buy
        : analysis.isSell
        ? AppColors.sell
        : AppColors.wait;

    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            title: 'AI Insight',
            subtitle: 'Why this signal was generated',
            icon: Icons.psychology,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: signalColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI generated market insight',
                      style: AppTextStyles.title.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Key details and reasoning behind the current recommendation.',
                      style: AppTextStyles.small.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildDetailChip(
                label: 'Signal',
                value: analysis.signal,
                color: signalColor,
              ),
              _buildDetailChip(
                label: 'Confidence',
                value: '${analysis.confidence}%',
                color: theme.colorScheme.primary,
              ),
              _buildDetailChip(
                label: 'Regime',
                value: analysis.marketRegime,
                color: AppColors.info,
              ),
              _buildDetailChip(
                label: 'Higher TF',
                value: analysis.higherTimeframe,
                color: theme.colorScheme.primary.withAlpha(180),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Reason',
            style: AppTextStyles.subtitle.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            analysis.reason,
            style: AppTextStyles.body.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withAlpha(90)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.small.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRsiColor(double rsi) {
    if (rsi >= 70) return AppColors.sell;
    if (rsi <= 30) return AppColors.buy;
    return AppColors.wait;
  }

  Color _getAdxColor(double adx) {
    return adx >= 25 ? AppColors.buy : AppColors.wait;
  }

  Color _getPcrColor(double pcr) {
    if (pcr > 1.2) return AppColors.buy;
    if (pcr < 0.7) return AppColors.sell;
    return AppColors.wait;
  }

  Color _getVolumeColor(double ratio) {
    if (ratio >= 1.5) return AppColors.buy;
    if (ratio <= 0.5) return AppColors.sell;
    return AppColors.primary;
  }

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
