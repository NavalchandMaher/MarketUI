import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/analysis_model.dart';
import '../service_locator.dart';
import '../services/api/v3_api_service.dart';
import '../state/app_state.dart';
import '../widgets/strategy_signal_widgets.dart';

/// Premium strategy signals screen with modern dark theme and smooth animations
class StrategySignalScreen extends StatefulWidget {
  const StrategySignalScreen({super.key});

  @override
  State<StrategySignalScreen> createState() => _StrategySignalScreenState();
}

class _StrategySignalScreenState extends State<StrategySignalScreen>
    with SingleTickerProviderStateMixin {
  late final V3ApiService _api;
  late AnimationController _refreshIconController;
  List<AnalysisModel> _signals = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _placingPaperTradeStrategyId;
  final Set<String> _expandedCards = <String>{};
  Timer? _refreshTimer;
  int _secondsUntilRefresh = 30;

  @override
  void initState() {
    super.initState();
    _refreshIconController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _api = getIt<V3ApiService>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSignals());
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _secondsUntilRefresh = 30;
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _secondsUntilRefresh--);
        if (_secondsUntilRefresh <= 0) {
          _loadSignals(forceRefresh: false);
          _startRefreshTimer();
        }
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshIconController.dispose();
    super.dispose();
  }

  Future<void> _loadSignals({bool forceRefresh = false}) async {
    final state = context.read<AppState>();
    final symbol = state.selectedSymbol;
    final timeframe = state.selectedTimeframe;

    if (!mounted) return;
    setState(() {
      _isLoading = _signals.isEmpty;
      _errorMessage = null;
    });

    if (forceRefresh) {
      _refreshIconController.repeat();
    }

    try {
      final signals = await _api.getStrategySignals(
        symbol: symbol,
        timeframe: timeframe,
        forceRefresh: forceRefresh,
      );
      if (!mounted) return;
      setState(() {
        _signals = sortSignalsByConfidence(signals);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _refreshIconController.stop();
      }
    }
  }

  Future<void> _takePaperTrade(AnalysisModel analysis, AppState state) async {
    if (analysis.isWait) return;

    setState(() => _placingPaperTradeStrategyId = analysis.strategy.id);

    try {
      await _api.startPaperTrading(
        strategyId: analysis.strategy.id,
        symbol: analysis.symbol,
        timeframe: analysis.timeframe,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paper trade started successfully!')),
        );
        state.refreshHomeData();
        _loadSignals();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _placingPaperTradeStrategyId = null);
      }
    }
  }

  void _showLiveTradeNotice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Trading'),
        content: const Text(
          'Live trading is not yet connected. Please use paper trading to test strategies.',
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

  void _toggleExpanded(String cardId) {
    setState(() {
      if (_expandedCards.contains(cardId)) {
        _expandedCards.remove(cardId);
      } else {
        _expandedCards.add(cardId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final isLoading = _isLoading;
        final signals = _signals;
        final error = _errorMessage;

        if (isLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading strategy signals...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        if (error != null && signals.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Strategy Signals'),
              elevation: 0,
              centerTitle: false,
              actions: [
                IconButton(
                  onPressed: () => _loadSignals(forceRefresh: true),
                  icon: RotationTransition(
                    turns: _refreshIconController,
                    child: const Icon(Icons.refresh_rounded),
                  ),
                ),
              ],
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading signals',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _loadSignals(forceRefresh: true),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (signals.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Strategy Signals'),
              elevation: 0,
              centerTitle: false,
              actions: [
                IconButton(
                  onPressed: () => _loadSignals(forceRefresh: true),
                  icon: RotationTransition(
                    turns: _refreshIconController,
                    child: const Icon(Icons.refresh_rounded),
                  ),
                ),
              ],
            ),
            body: const Center(
              child: Text('No BUY or SELL signals available right now.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Strategy Signals'),
            elevation: 0,
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () => _loadSignals(forceRefresh: true),
                icon: RotationTransition(
                  turns: _refreshIconController,
                  child: const Icon(Icons.refresh_rounded),
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => _loadSignals(forceRefresh: true),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: signals.length + 1,
              itemBuilder: (context, index) {
                // Header with countdown timer
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RefreshCountdownTimer(
                      duration: Duration(seconds: _secondsUntilRefresh),
                      onComplete: () => _loadSignals(forceRefresh: false),
                    ),
                  );
                }

                final analysis = signals[index - 1];
                final cardId = 'signal_${index - 1}_${analysis.strategy.id}';
                final isExpanded = _expandedCards.contains(cardId);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: SignalCard(
                        key: ValueKey(
                          '$cardId-${isExpanded ? 'expanded' : 'collapsed'}',
                        ),
                        analysis: analysis,
                        onPaperTrade:
                            _placingPaperTradeStrategyId != null ||
                                analysis.isWait
                            ? null
                            : () => _takePaperTrade(analysis, state),
                        onLiveTrade: _showLiveTradeNotice,
                        paperTradeLoading:
                            _placingPaperTradeStrategyId ==
                            analysis.strategy.id,
                        isExpanded: isExpanded,
                        onToggleExpanded: () => _toggleExpanded(cardId),
                        lastUpdatedLabel: '',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
