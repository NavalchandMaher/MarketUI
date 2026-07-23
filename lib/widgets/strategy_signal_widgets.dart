import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/analysis_model.dart';

// Color constants for premium dark theme
const _bgPrimary = Color(0xFF111418);
const _bgSecondary = Color(0xFF20242C);
const _bgTertiary = Color(0xFF171B22);
const _colorGreen = Color(0xFF22C55E);
const _colorRed = Color(0xFFEF4444);
const _colorPurple = Color(0xFF6366F1);
const _colorYellow = Color(0xFFFCD34D);
const _textPrimary = Colors.white;
const _textSecondary = Color(0xFF9CA3AF);

// Helper functions
List<AnalysisModel> sortSignalsByConfidence(List<AnalysisModel> signals) {
  final sorted = List<AnalysisModel>.from(signals);
  sorted.sort((a, b) => b.confidence.compareTo(a.confidence));
  return sorted;
}

Color resolveSignalColor(AnalysisModel analysis) {
  if (analysis.isBuy) return _colorGreen;
  if (analysis.isSell) return _colorRed;
  return _colorYellow;
}

IconData resolveSignalIcon(AnalysisModel analysis) {
  if (analysis.isBuy) return Icons.trending_up_rounded;
  if (analysis.isSell) return Icons.trending_down_rounded;
  return Icons.pause_circle_outline_rounded;
}

String formatPrice(double value) => value == 0 ? '—' : value.toStringAsFixed(2);

String formatPercent(double value) => '${value.toStringAsFixed(1)}%';

double calculateTakeProfitPrice(
  double entry,
  double percentage,
  String signal,
) {
  final multiplier = percentage / 100;
  return signal.toUpperCase() == 'SELL'
      ? entry * (1 - multiplier)
      : entry * (1 + multiplier);
}

double calculateStopLossPrice(
  double entry,
  double percentage,
  String signal,
) {
  final multiplier = percentage / 100;
  return signal.toUpperCase() == 'SELL'
      ? entry * (1 + multiplier)
      : entry * (1 - multiplier);
}

String formatRiskReward(double entry, double tp, double sl) {
  if (entry <= 0 || tp <= 0 || sl <= 0) return '1 : 0.0';
  final rr = ((tp - entry).abs() / (entry - sl).abs()).clamp(0.0, 999.0);
  return '1 : ${rr.toStringAsFixed(2)}';
}

List<String> buildTradeJustificationBullets(AnalysisModel analysis) {
  if (analysis.tradeJustification.isNotEmpty) {
    return analysis.tradeJustification.take(5).toList();
  }

  final isBuy = analysis.isBuy;
  final bool bullish = analysis.higherTimeframe.toUpperCase() == 'BULLISH';
  final bool bearish = analysis.higherTimeframe.toUpperCase() == 'BEARISH';
  final bool strongMomentum =
      analysis.indicators.rsi > 60 || analysis.indicators.rsi < 40;

  final bullets = <String>[
    if (isBuy)
      'Price holding above key support level'
    else
      'Price holding below key resistance level',
    if (bullish)
      'EMA20 > EMA50 > EMA200 (bullish structure)'
    else if (bearish)
      'EMA20 < EMA50 < EMA200 (bearish structure)'
    else
      'Trend structure remains balanced',
    if (strongMomentum)
      'RSI showing strong momentum signal'
    else
      'Momentum building strength',
    if (analysis.indicators.macd > analysis.indicators.macdSignal)
      'MACD bullish crossover confirmed'
    else if (analysis.indicators.macd < analysis.indicators.macdSignal)
      'MACD bearish crossover confirmed'
    else
      'MACD approaching signal crossover',
  ];

  return bullets.take(5).toList();
}

// Premium collapsed signal card
class SignalCard extends StatelessWidget {
  final AnalysisModel analysis;
  final VoidCallback? onPaperTrade;
  final VoidCallback? onLiveTrade;
  final bool paperTradeLoading;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final String lastUpdatedLabel;
  final bool showHeader;

  const SignalCard({
    super.key,
    required this.analysis,
    required this.onPaperTrade,
    required this.onLiveTrade,
    required this.paperTradeLoading,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.lastUpdatedLabel,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = resolveSignalColor(analysis);
    final icon = resolveSignalIcon(analysis);
    final confidencePercent = math
        .max(0, math.min(100, analysis.confidence))
        .toDouble();

    if (isExpanded) {
      return _ExpandedSignalCard(
        analysis: analysis,
        color: color,
        confidencePercent: confidencePercent,
        onToggleExpanded: onToggleExpanded,
        onPaperTrade: onPaperTrade,
        onLiveTrade: onLiveTrade,
        paperTradeLoading: paperTradeLoading,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_bgSecondary, _bgTertiary],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggleExpanded,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Row(
                  children: [
                    // Circular icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.15),
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    // Center: Name and symbol
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            analysis.strategy.name.isEmpty
                                ? 'Unnamed Strategy'
                                : analysis.strategy.name,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${analysis.symbol} • ${analysis.timeframe}',
                            style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right: Signal badge and confidence
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: color.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            analysis.signal.toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${confidencePercent.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Bottom progress bar
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                child: AnimatedBuilder(
                  animation: AlwaysStoppedAnimation(
                    (confidencePercent / 100).clamp(0.0, 1.0),
                  ),
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: (confidencePercent / 100).clamp(0.0, 1.0),
                      minHeight: 5,
                      color: color,
                      backgroundColor: color.withValues(alpha: 0.12),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Expanded card with premium layout
class _ExpandedSignalCard extends StatefulWidget {
  final AnalysisModel analysis;
  final Color color;
  final double confidencePercent;
  final VoidCallback onToggleExpanded;
  final VoidCallback? onPaperTrade;
  final VoidCallback? onLiveTrade;
  final bool paperTradeLoading;

  const _ExpandedSignalCard({
    required this.analysis,
    required this.color,
    required this.confidencePercent,
    required this.onToggleExpanded,
    required this.onPaperTrade,
    required this.onLiveTrade,
    required this.paperTradeLoading,
  });

  @override
  State<_ExpandedSignalCard> createState() => _ExpandedSignalCardState();
}

class _ExpandedSignalCardState extends State<_ExpandedSignalCard> {
  late double _tpPercent;
  late double _slPercent;
  late double _trailingStop;

  @override
  void initState() {
    super.initState();
    _tpPercent = widget.analysis.strategy.tpPercent.clamp(0.5, 8.0);
    _slPercent = widget.analysis.strategy.slPercent.clamp(0.25, 6.0);
    _trailingStop = 1.0;
  }

  double get _entry => widget.analysis.price;
  double get _tpPrice =>
      calculateTakeProfitPrice(_entry, _tpPercent, widget.analysis.signal);
  double get _slPrice =>
      calculateStopLossPrice(_entry, _slPercent, widget.analysis.signal);

  String get _riskReward => formatRiskReward(_entry, _tpPrice, _slPrice);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_bgSecondary, _bgTertiary],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                resolveSignalIcon(widget.analysis),
                                color: widget.color,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  widget.analysis.strategy.name.isEmpty
                                      ? 'Unnamed Strategy'
                                      : widget.analysis.strategy.name,
                                  style: const TextStyle(
                                    color: _textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${widget.analysis.symbol} • ${widget.analysis.timeframe}',
                            style: const TextStyle(
                              color: _textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onToggleExpanded,
                      icon: const Icon(Icons.close_rounded, size: 22),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Summary cards grid (3x2)
                GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _MetricCard(
                      label: 'Entry',
                      value: formatPrice(_entry),
                      color: widget.color,
                    ),
                    _MetricCard(
                      label: 'Take Profit',
                      value: formatPrice(_tpPrice),
                      color: _colorGreen,
                    ),
                    _MetricCard(
                      label: 'Stop Loss',
                      value: formatPrice(_slPrice),
                      color: _colorRed,
                    ),
                    _MetricCard(
                      label: 'Risk : Reward',
                      value: _riskReward,
                      color: _colorPurple,
                    ),
                    _MetricCard(
                      label: 'TSL',
                      value: '${_trailingStop.toStringAsFixed(2)}%',
                      color: _colorYellow,
                    ),
                    _MetricCard(
                      label: 'Confidence',
                      value: '${widget.confidencePercent.toStringAsFixed(0)}%',
                      color: widget.color,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // TP Control
                _ControlSection(
                  title: 'Take Profit (TP)',
                  color: _colorGreen,
                  child: _SliderControl(
                    value: _tpPercent,
                    minValue: 0.5,
                    maxValue: 8.0,
                    onMinus: () => setState(
                      () => _tpPercent = (_tpPercent - 0.1).clamp(0.5, 8.0),
                    ),
                    onPlus: () => setState(
                      () => _tpPercent = (_tpPercent + 0.1).clamp(0.5, 8.0),
                    ),
                    onChanged: (value) => setState(() => _tpPercent = value),
                    displayValue:
                        '${_tpPrice.toStringAsFixed(2)} (${widget.analysis.isSell ? '-' : '+'}${_tpPercent.toStringAsFixed(1)}%)',
                    color: _colorGreen,
                  ),
                ),
                const SizedBox(height: 16),

                // SL Control
                _ControlSection(
                  title: 'Stop Loss (SL)',
                  color: _colorRed,
                  child: _SliderControl(
                    value: _slPercent,
                    minValue: 0.25,
                    maxValue: 6.0,
                    onMinus: () => setState(
                      () => _slPercent = (_slPercent - 0.1).clamp(0.25, 6.0),
                    ),
                    onPlus: () => setState(
                      () => _slPercent = (_slPercent + 0.1).clamp(0.25, 6.0),
                    ),
                    onChanged: (value) => setState(() => _slPercent = value),
                    displayValue:
                        '${_slPrice.toStringAsFixed(2)} (${widget.analysis.isSell ? '+' : '-'}${_slPercent.toStringAsFixed(1)}%)',
                    color: _colorRed,
                  ),
                ),
                const SizedBox(height: 16),

                // TSL Control
                _ControlSection(
                  title: 'Trailing Stop Loss (TSL)',
                  color: _colorYellow,
                  child: _SliderControl(
                    value: _trailingStop,
                    minValue: 0.25,
                    maxValue: 5.0,
                    onMinus: () => setState(
                      () => _trailingStop = (_trailingStop - 0.1).clamp(
                        0.25,
                        5.0,
                      ),
                    ),
                    onPlus: () => setState(
                      () => _trailingStop = (_trailingStop + 0.1).clamp(
                        0.25,
                        5.0,
                      ),
                    ),
                    onChanged: (value) => setState(() => _trailingStop = value),
                    displayValue: '${_trailingStop.toStringAsFixed(2)}%',
                    color: _colorYellow,
                  ),
                ),
                const SizedBox(height: 20),

                // Trade justification
                _TradeJustificationSection(analysis: widget.analysis),
                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onLiveTrade,
                        icon: const Icon(Icons.account_balance_wallet_outlined),
                        label: const Text('Take Real Trade'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colorGreen,
                          foregroundColor: _textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onPaperTrade,
                        icon: widget.paperTradeLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _textPrimary,
                                  ),
                                ),
                              )
                            : const Icon(Icons.description_outlined),
                        label: const Text('Take Paper Trade'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colorPurple,
                          foregroundColor: _textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Premium metric card for summary section
class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_bgTertiary, _bgPrimary],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Control section header
class _ControlSection extends StatelessWidget {
  final String title;
  final Color color;
  final Widget child;

  const _ControlSection({
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

// Slider control with buttons
class _SliderControl extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final ValueChanged<double> onChanged;
  final String displayValue;
  final Color color;

  const _SliderControl({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onMinus,
    required this.onPlus,
    required this.onChanged,
    required this.displayValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Minus button
            Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: onMinus,
                icon: Icon(Icons.remove_rounded, color: color, size: 18),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 10),
            // Slider
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: color,
                  inactiveTrackColor: color.withValues(alpha: 0.2),
                  thumbColor: color,
                  thumbShape: RoundSliderThumbShape(
                    elevation: 6,
                    enabledThumbRadius: 8,
                  ),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 14),
                  overlayColor: color.withValues(alpha: 0.2),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: value,
                  min: minValue,
                  max: maxValue,
                  onChanged: onChanged,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Plus button
            Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                onPressed: onPlus,
                icon: Icon(Icons.add_rounded, color: color, size: 18),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Display value
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayValue,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Trade justification section
class _TradeJustificationSection extends StatelessWidget {
  final AnalysisModel analysis;

  const _TradeJustificationSection({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final bullets = buildTradeJustificationBullets(analysis);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why this trade?',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...bullets.map(
          (bullet) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 10),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: _colorGreen,
                    size: 16,
                  ),
                ),
                Expanded(
                  child: Text(
                    bullet,
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Countdown timer widget for header
class RefreshCountdownTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback onComplete;

  const RefreshCountdownTimer({
    super.key,
    required this.duration,
    required this.onComplete,
  });

  @override
  State<RefreshCountdownTimer> createState() => _RefreshCountdownTimerState();
}

class _RefreshCountdownTimerState extends State<RefreshCountdownTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _remaining = _remaining - const Duration(milliseconds: 100);
        if (_remaining.isNegative) {
          _timer.cancel();
          widget.onComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_remaining.inMilliseconds / widget.duration.inMilliseconds)
        .clamp(0.0, 1.0);

    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 2,
            color: _colorGreen,
            backgroundColor: _colorGreen.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Refreshing in ${(_remaining.inSeconds + 1)}s',
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
