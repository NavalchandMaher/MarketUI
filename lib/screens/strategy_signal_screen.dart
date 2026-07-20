import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/analysis_model.dart';
import '../service_locator.dart';
import '../services/api/v3_api_service.dart';
import '../state/app_state.dart';
import '../utils/constants.dart';
import '../widgets/common_widgets.dart';

/// Shows every strategy visible to the user together with its live market signal.
class StrategySignalScreen extends StatefulWidget {
  const StrategySignalScreen({super.key});

  @override
  State<StrategySignalScreen> createState() => _StrategySignalScreenState();
}

class _StrategySignalScreenState extends State<StrategySignalScreen> {
  late final V3ApiService _api;
  List<AnalysisModel> _signals = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _placingPaperTradeStrategyId;
  String? _loadedSymbol;
  String? _loadedTimeframe;

  @override
  void initState() {
    super.initState();
    _api = getIt<V3ApiService>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSignals());
  }

  Future<void> _loadSignals({bool forceRefresh = false}) async {
    final state = context.read<AppState>();
    final symbol = state.selectedSymbol;
    final timeframe = state.selectedTimeframe;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final signals = await _api.getStrategySignals(
        symbol: symbol,
        timeframe: timeframe,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _signals = signals;
        _loadedSymbol = symbol;
        _loadedTimeframe = timeframe;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _loadedSymbol = symbol;
        _loadedTimeframe = timeframe;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _takePaperTrade(AnalysisModel analysis, AppState state) async {
    if (analysis.isWait) return;

    setState(() => _placingPaperTradeStrategyId = analysis.strategy.id);
    try {
      final response = await _api.startPaperTrading(
        symbol: state.selectedSymbol,
        timeframe: state.selectedTimeframe,
        strategyId: analysis.strategy.id,
      );
      if (!mounted) return;

      final success = response['success'] == true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ??
                (success ? 'Paper trade opened.' : 'Unable to open paper trade.'),
          ),
          backgroundColor: success ? AppColors.buy : AppColors.sell,
        ),
      );
      if (success) {
        await state.refreshHomeData(forceRefresh: true);
        await _loadSignals(forceRefresh: true);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open paper trade: $error'),
          backgroundColor: AppColors.sell,
        ),
      );
    } finally {
      if (mounted) setState(() => _placingPaperTradeStrategyId = null);
    }
  }

  void _showLiveTradeNotice() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live trading is not connected'),
        content: const Text(
          'Connect a broker and configure live-order execution before placing a real trade. '
          'Until then, use paper trading to validate this signal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strategy Signals'),
        actions: [
          IconButton(
            tooltip: 'Refresh signals',
            onPressed: () => _loadSignals(forceRefresh: true),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          if (_loadedSymbol != state.selectedSymbol ||
              _loadedTimeframe != state.selectedTimeframe) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_isLoading) _loadSignals();
            });
          }

          if (_isLoading && _signals.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_errorMessage != null && _signals.isEmpty) {
            return _ErrorState(
              message: _errorMessage!,
              onRetry: () => _loadSignals(forceRefresh: true),
            );
          }
          if (_signals.isEmpty) {
            return const Center(child: Text('No strategies are available yet.'));
          }

          return RefreshIndicator(
            onRefresh: () => _loadSignals(forceRefresh: true),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Live strategy signals', style: AppTextStyles.title),
                const SizedBox(height: 4),
                Text(
                  'Each signal uses that strategy’s thresholds and risk settings.',
                  style: AppTextStyles.subtitle,
                ),
                const SizedBox(height: 16),
                ..._signals.map(
                  (analysis) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StrategySignalCard(
                      analysis: analysis,
                      onPaperTrade:
                          _placingPaperTradeStrategyId != null || analysis.isWait
                              ? null
                              : () => _takePaperTrade(analysis, state),
                      onLiveTrade: _showLiveTradeNotice,
                      paperTradeLoading:
                          _placingPaperTradeStrategyId == analysis.strategy.id,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StrategySignalCard extends StatelessWidget {
  final AnalysisModel analysis;
  final VoidCallback? onPaperTrade;
  final VoidCallback onLiveTrade;
  final bool paperTradeLoading;

  const _StrategySignalCard({
    required this.analysis,
    required this.onPaperTrade,
    required this.onLiveTrade,
    required this.paperTradeLoading,
  });

  Color get _signalColor {
    if (analysis.isBuy) return AppColors.buy;
    if (analysis.isSell) return AppColors.sell;
    return AppColors.wait;
  }

  double get _entry => analysis.price;

  double get _takeProfit {
    if (analysis.isBuy) return _entry * (1 + analysis.strategy.tpPercent / 100);
    if (analysis.isSell) return _entry * (1 - analysis.strategy.tpPercent / 100);
    return 0;
  }

  double get _stopLoss {
    if (analysis.isBuy) return _entry * (1 - analysis.strategy.slPercent / 100);
    if (analysis.isSell) return _entry * (1 + analysis.strategy.slPercent / 100);
    return 0;
  }

  String _price(double value) => value == 0 ? '—' : value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _signalColor.withOpacity(0.14),
          child: Icon(
            analysis.isBuy
                ? Icons.trending_up
                : analysis.isSell
                    ? Icons.trending_down
                    : Icons.pause_circle_outline,
            color: _signalColor,
          ),
        ),
        title: Text(
          analysis.strategy.name.isEmpty
              ? 'Unnamed Strategy'
              : analysis.strategy.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${analysis.symbol} • ${analysis.timeframe}'),
        trailing: StatusChip(text: analysis.signal, color: _signalColor),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          const Divider(),
          _DetailGrid(
            children: [
              _Detail(label: 'Live Signal', value: analysis.signal),
              _Detail(label: 'Confidence', value: '${analysis.confidence}%'),
              _Detail(label: 'Entry', value: _price(_entry)),
              _Detail(label: 'TP', value: _price(_takeProfit)),
              _Detail(label: 'SL', value: _price(_stopLoss)),
              _Detail(label: 'Score', value: analysis.score.toString()),
            ],
          ),
          const SizedBox(height: 16),
          InfoRow(title: 'Market regime', value: analysis.marketRegime),
          const Divider(),
          InfoRow(title: 'Higher timeframe', value: analysis.higherTimeframe),
          const Divider(),
          InfoRow(
            title: 'Risk / reward',
            value:
                '${analysis.strategy.slPercent.toStringAsFixed(1)}% / ${analysis.strategy.tpPercent.toStringAsFixed(1)}%',
          ),
          const Divider(),
          InfoRow(
            title: 'Indicator snapshot',
            value:
                'RSI ${analysis.indicators.rsi.toStringAsFixed(1)} • MACD ${analysis.indicators.macd.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 16),
          Text('Signal rationale', style: AppTextStyles.subtitle),
          const SizedBox(height: 6),
          Text(analysis.reason.isEmpty ? 'No rationale was returned.' : analysis.reason),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onLiveTrade,
                  icon: const Icon(Icons.account_balance),
                  label: const Text('Take Real Trade'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onPaperTrade,
                  icon: paperTradeLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.description_outlined),
                  label: const Text('Take Paper Trade'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final List<_Detail> children;

  const _DetailGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: children
          .map(
            (detail) => SizedBox(
              width: (MediaQuery.of(context).size.width - 56) / 2,
              child: _DetailTile(detail: detail),
            ),
          )
          .toList(),
    );
  }
}

class _Detail {
  final String label;
  final String value;

  const _Detail({required this.label, required this.value});
}

class _DetailTile extends StatelessWidget {
  final _Detail detail;

  const _DetailTile({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(detail.label, style: AppTextStyles.small),
          const SizedBox(height: 4),
          Text(detail.value, style: AppTextStyles.subtitle),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.sell),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
