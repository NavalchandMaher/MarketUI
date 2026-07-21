import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/analysis_model.dart';
import '../utils/constants.dart';

List<AnalysisModel> sortSignalsByConfidence(List<AnalysisModel> signals) {
  final sorted = List<AnalysisModel>.from(signals);
  sorted.sort((a, b) => b.confidence.compareTo(a.confidence));
  return sorted;
}

Color resolveSignalColor(AnalysisModel analysis) {
  if (analysis.isBuy) return AppColors.buy;
  if (analysis.isSell) return AppColors.sell;
  return AppColors.wait;
}

IconData resolveSignalIcon(AnalysisModel analysis) {
  if (analysis.isBuy) return Icons.trending_up_rounded;
  if (analysis.isSell) return Icons.trending_down_rounded;
  return Icons.pause_circle_outline_rounded;
}

String formatPrice(double value) => value == 0 ? '—' : value.toStringAsFixed(2);

String formatPercent(double value) => '${value.toStringAsFixed(1)}%';

String formatRiskReward(double entry, double tp, double sl) {
  if (entry <= 0 || tp <= 0 || sl <= 0) return '1 : 0.0';
  final rr = ((tp - entry).abs() / (entry - sl).abs()).clamp(0.0, 999.0);
  return '1 : ${rr.toStringAsFixed(1)}';
}

List<String> buildTradeJustificationBullets(AnalysisModel analysis) {
  final isBuy = analysis.isBuy;
  final bool bullish = analysis.higherTimeframe.toUpperCase() == 'BULLISH';
  final bool bearish = analysis.higherTimeframe.toUpperCase() == 'BEARISH';
  final bool strongMomentum =
      analysis.indicators.rsi > 60 || analysis.indicators.rsi < 40;

  final bullets = <String>[
    if (isBuy)
      'Price holding above major support'
    else
      'Price holding below major resistance',
    if (bullish)
      'EMA20 > EMA50 > EMA200'
    else if (bearish)
      'EMA20 < EMA50 < EMA200'
    else
      'Trend structure remains balanced',
    if (strongMomentum)
      'RSI shows clear momentum'
    else
      'Momentum is still developing',
    if (analysis.indicators.macd > analysis.indicators.macdSignal)
      'MACD bullish crossover'
    else if (analysis.indicators.macd < analysis.indicators.macdSignal)
      'MACD bearish crossover'
    else
      'MACD is neutral',
  ];

  return bullets.take(4).toList();
}

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

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onToggleExpanded,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analysis.strategy.name.isEmpty
                              ? 'Unnamed Strategy'
                              : analysis.strategy.name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${analysis.symbol} • ${analysis.timeframe}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          analysis.signal.toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${confidencePercent.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: LinearProgressIndicator(
                value: (confidencePercent / 100).clamp(0.0, 1.0),
                minHeight: 5,
                color: color,
                backgroundColor: color.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

  double get _tpPrice => _entry * (1 + (_tpPercent / 100));

  double get _slPrice {
    if (widget.analysis.isBuy) {
      return _entry * (1 - (_slPercent / 100));
    }
    return _entry * (1 + (_slPercent / 100));
  }

  String get _riskReward => formatRiskReward(_entry, _tpPrice, _slPrice);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.analysis.strategy.name.isEmpty
                                    ? 'Unnamed Strategy'
                                    : widget.analysis.strategy.name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.analysis.symbol} • ${widget.analysis.timeframe}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.analysis.signal.toUpperCase(),
                          style: TextStyle(
                            color: widget.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Confidence ${widget.confidencePercent.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: widget.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: widget.onToggleExpanded,
                    icon: const Icon(Icons.close_rounded),
                    iconSize: 20,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionTitle(label: 'Entry (Current Price)'),
              const SizedBox(height: 12),
              _ExpandedInfoTile(
                label: 'Entry',
                value: formatPrice(_entry),
                accent: widget.color,
              ),
              const SizedBox(height: 20),
              _SectionTitle(label: 'Take Profit (TP)'),
              const SizedBox(height: 12),
              TPSlider(
                value: _tpPercent,
                label: 'Adjust Take Profit',
                onChanged: (value) => setState(() => _tpPercent = value),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ExpandedInfoTile(
                      label: 'TP Price',
                      value: formatPrice(_tpPrice),
                      accent: AppColors.buy,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ExpandedInfoTile(
                      label: 'Gain',
                      value: '(+${_tpPercent.toStringAsFixed(1)}%)',
                      accent: AppColors.buy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionTitle(label: 'Stop Loss (SL)'),
              const SizedBox(height: 12),
              SLSlider(
                value: _slPercent,
                label: 'Adjust Stop Loss',
                onChanged: (value) => setState(() => _slPercent = value),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ExpandedInfoTile(
                      label: 'SL Price',
                      value: formatPrice(_slPrice),
                      accent: AppColors.sell,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ExpandedInfoTile(
                      label: 'Loss',
                      value: '(-${_slPercent.toStringAsFixed(1)}%)',
                      accent: AppColors.sell,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _SectionTitle(label: 'Risk : Reward'),
              const SizedBox(height: 12),
              _ExpandedInfoTile(
                label: 'Ratio',
                value: _riskReward,
                accent: AppColors.info,
              ),
              const SizedBox(height: 20),
              _SectionTitle(label: 'Trailing Stop Loss (TSL)'),
              const SizedBox(height: 12),
              TrailingSLSlider(
                value: _trailingStop,
                onChanged: (value) => setState(() => _trailingStop = value),
              ),
              const SizedBox(height: 12),
              _ExpandedInfoTile(
                label: 'TSL Value',
                value: '${_trailingStop.toStringAsFixed(2)}%',
                accent: AppColors.warning,
              ),
              const SizedBox(height: 20),
              _SectionTitle(label: 'Why this trade?'),
              const SizedBox(height: 12),
              TradeJustification(analysis: widget.analysis),
              const SizedBox(height: 24),
              TradeActionButtons(
                onPaperTrade: widget.onPaperTrade,
                onLiveTrade: widget.onLiveTrade,
                paperTradeLoading: widget.paperTradeLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _ExpandedInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _ExpandedInfoTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class ConfidenceBar extends StatelessWidget {
  final double value;
  final Color color;

  const ConfidenceBar({super.key, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            minHeight: 5,
            color: color,
            backgroundColor: color.withValues(alpha: 0.16),
          ),
        ),
      ],
    );
  }
}

class TPSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String label;

  const TPSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.buy,
            inactiveTrackColor: AppColors.buy.withValues(alpha: 0.2),
            thumbColor: AppColors.buy,
            overlayColor: AppColors.buy.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            min: 0.5,
            max: 8.0,
            divisions: 30,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class SLSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String label;

  const SLSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.sell,
            inactiveTrackColor: AppColors.sell.withValues(alpha: 0.2),
            thumbColor: AppColors.sell,
            overlayColor: AppColors.sell.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            min: 0.25,
            max: 6.0,
            divisions: 24,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class TrailingSLSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const TrailingSLSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trailing Stop Loss',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.warning,
            inactiveTrackColor: AppColors.warning.withValues(alpha: 0.2),
            thumbColor: AppColors.warning,
            overlayColor: AppColors.warning.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            min: 0.25,
            max: 5.0,
            divisions: 20,
            label: value.toStringAsFixed(2),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class TradeJustification extends StatelessWidget {
  final AnalysisModel analysis;

  const TradeJustification({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final bullets = buildTradeJustificationBullets(analysis);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Short Trade Justification',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...bullets.map(
          (bullet) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text('•', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(bullet)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TradeActionButtons extends StatelessWidget {
  final VoidCallback? onPaperTrade;
  final VoidCallback? onLiveTrade;
  final bool paperTradeLoading;

  const TradeActionButtons({
    super.key,
    required this.onPaperTrade,
    required this.onLiveTrade,
    required this.paperTradeLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onLiveTrade,
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: const Text('Take Real Trade'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
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
    );
  }
}
