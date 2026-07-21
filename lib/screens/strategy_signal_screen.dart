import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/analysis_model.dart';
import '../service_locator.dart';
import '../services/api/v3_api_service.dart';
import '../state/app_state.dart';
import '../utils/constants.dart';
import '../widgets/strategy_signal_widgets.dart';

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
  bool _isRefreshing = false;
  String? _errorMessage;
  String? _placingPaperTradeStrategyId;
  String? _loadedSymbol;
  String? _loadedTimeframe;
  String _lastUpdatedLabel = 'just now';
  final Set<String> _expandedCards = <String>{};
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _api = getIt<V3ApiService>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSignals());
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _loadSignals(forceRefresh: false);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSignals({bool forceRefresh = false}) async {
    final state = context.read<AppState>();
    final symbol = state.selectedSymbol;
    final timeframe = state.selectedTimeframe;

    if (!mounted) return;
    setState(() {
      _isLoading = _signals.isEmpty;
      _isRefreshing = forceRefresh || _signals.isNotEmpty;
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
        _signals = sortSignalsByConfidence(signals);
        _loadedSymbol = symbol;
        _loadedTimeframe = timeframe;
        _lastUpdatedLabel = _formatLastUpdated();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _loadedSymbol = symbol;
        _loadedTimeframe = timeframe;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  String _formatLastUpdated() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _takePaperTrade(AnalysisModel analysis, AppState state) async {
    if (analysis.isWait) return;

    setState(() => _placingPaperTradeStrategyId = analysis.strategy.id);
    try {
      final response = await _api.startPaperTrading(
        symbol: analysis.symbol,
        timeframe: analysis.timeframe,
        strategyId: analysis.strategy.id,
      );
      if (!mounted) return;

      final success = response['success'] == true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ??
                (success
                    ? 'Paper trade opened.'
                    : 'Unable to open paper trade.'),
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

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedCards.contains(id)) {
        _expandedCards.remove(id);
      } else {
        _expandedCards.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strategy Signals'),
        actions: [
          AnimatedRotation(
            turns: _isRefreshing ? 1 / 2 : 0,
            duration: AppConstants.animation,
            child: IconButton(
              tooltip: 'Refresh signals',
              onPressed: () => _loadSignals(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded),
            ),
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
            return const Center(
              child: Text('No BUY or SELL signals are available right now.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _loadSignals(forceRefresh: true),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: _signals.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live strategy signals',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Auto-refreshing every 30s • Tap any card to inspect your levels.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Last Updated $_lastUpdatedLabel',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }

                final analysis = _signals[index - 1];
                final isExpanded = _expandedCards.contains(
                  analysis.strategy.id,
                );
                return AnimatedSwitcher(
                  duration: AppConstants.animation,
                  child: SignalCard(
                    key: ValueKey(
                      '${analysis.strategy.id}-${isExpanded ? 'expanded' : 'collapsed'}',
                    ),
                    analysis: analysis,
                    onPaperTrade:
                        _placingPaperTradeStrategyId != null || analysis.isWait
                        ? null
                        : () => _takePaperTrade(analysis, state),
                    onLiveTrade: _showLiveTradeNotice,
                    paperTradeLoading:
                        _placingPaperTradeStrategyId == analysis.strategy.id,
                    isExpanded: isExpanded,
                    onToggleExpanded: () =>
                        _toggleExpanded(analysis.strategy.id),
                    lastUpdatedLabel: _lastUpdatedLabel,
                  ),
                );
              },
            ),
          );
        },
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
            Icon(Icons.error_outline_rounded, size: 56, color: AppColors.sell),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
