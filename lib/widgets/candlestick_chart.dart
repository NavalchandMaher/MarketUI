import 'dart:math';

import 'package:flutter/material.dart';

import '../models/analysis_model.dart';
import '../utils/constants.dart';

class CandleData {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double? ema20;
  final double? ema50;
  final double? ema100;
  final double? ema200;
  final double? volume;

  CandleData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.ema20,
    this.ema50,
    this.ema100,
    this.ema200,
    this.volume,
  });

  bool get isBullish => close >= open;
}

class CandlestickChart extends StatelessWidget {
  final AnalysisModel analysis;

  const CandlestickChart({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final candles = _parseCandles(analysis.chart);

    if (candles.isEmpty) {
      return const SizedBox(
        height: 280,
        child: Center(child: Text('No candle data available')),
      );
    }

    return SizedBox(
      height: 320,
      child: CustomPaint(
        painter: _CandlestickPainter(
          candles: candles,
          ema20: analysis.indicators.ema20,
          ema50: analysis.indicators.ema50,
          ema100: analysis.indicators.ema100,
          ema200: analysis.indicators.ema200,
          theme: Theme.of(context),
        ),
      ),
    );
  }

  List<CandleData> _parseCandles(List<List<double>> raw) {
    final candles = <CandleData>[];

    for (final item in raw) {
      if (item.length < 5) continue;

      final timestamp = DateTime.fromMillisecondsSinceEpoch(item[0].toInt());
      final open = item[1];
      final high = item[2];
      final low = item[3];
      final close = item[4];

      final ema20 = item.length > 5 ? item[5] : null;
      final ema50 = item.length > 6 ? item[6] : null;
      final ema100 = item.length > 7 ? item[7] : null;
      final ema200 = item.length > 8 ? item[8] : null;
      final volume = item.length > 9 ? item[9] : null;

      candles.add(
        CandleData(
          timestamp: timestamp,
          open: open,
          high: high,
          low: low,
          close: close,
          ema20: ema20,
          ema50: ema50,
          ema100: ema100,
          ema200: ema200,
          volume: volume,
        ),
      );
    }

    return candles;
  }
}

class _CandlestickPainter extends CustomPainter {
  final List<CandleData> candles;
  final double? ema20;
  final double? ema50;
  final double? ema100;
  final double? ema200;
  final ThemeData theme;

  _CandlestickPainter({
    required this.candles,
    required this.ema20,
    required this.ema50,
    required this.ema100,
    required this.ema200,
    required this.theme,
  });

  late final Color bullishColor = AppColors.buy;
  late final Color bearishColor = AppColors.sell;
  late final Color gridColor = theme.dividerColor;
  late final Color axisColor = theme.textTheme.bodySmall!.color!.withAlpha(190);
  late final Color volumeColor = theme.colorScheme.primary.withAlpha(80);

  @override
  void paint(Canvas canvas, Size size) {
    final chartHeight = size.height * 0.72;
    final volumeHeight = size.height - chartHeight - 12;
    final padding = 12.0;
    final innerWidth = size.width - padding * 2;
    final candleWidth = innerWidth / (candles.length * 1.5);
    final maxPrice = candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    final minPrice = candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
    final priceRange = max(1.0, maxPrice - minPrice);
    final maxVolume = candles
        .map((c) => c.volume ?? 0)
        .fold<double>(0.0, (a, b) => a > b ? a : b);

    _drawGrid(canvas, size, chartHeight, padding);
    _drawCandles(
      canvas,
      size,
      chartHeight,
      padding,
      candleWidth,
      minPrice,
      priceRange,
      maxPrice,
    );
    _drawEmaLines(
      canvas,
      size,
      chartHeight,
      padding,
      candleWidth,
      minPrice,
      priceRange,
      maxPrice,
    );
    _drawVolume(
      canvas,
      size,
      chartHeight,
      volumeHeight,
      padding,
      candleWidth,
      maxVolume,
    );
    _drawPriceLabels(
      canvas,
      size,
      chartHeight,
      padding,
      minPrice,
      priceRange,
      maxPrice,
    );
  }

  void _drawGrid(Canvas canvas, Size size, double chartHeight, double padding) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;
    for (int row = 0; row <= 4; row++) {
      final y = padding + row * (chartHeight / 4);
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        paint,
      );
    }
  }

  void _drawCandles(
    Canvas canvas,
    Size size,
    double chartHeight,
    double padding,
    double candleWidth,
    double minPrice,
    double priceRange,
    double maxPrice,
  ) {
    for (int index = 0; index < candles.length; index++) {
      final candle = candles[index];
      final x = padding + index * candleWidth * 1.5 + candleWidth / 2;
      final highY =
          padding + (maxPrice - candle.high) / priceRange * chartHeight;
      final lowY = padding + (maxPrice - candle.low) / priceRange * chartHeight;
      final openY =
          padding + (maxPrice - candle.open) / priceRange * chartHeight;
      final closeY =
          padding + (maxPrice - candle.close) / priceRange * chartHeight;
      final bodyTop = candle.isBullish ? closeY : openY;
      final bodyBottom = candle.isBullish ? openY : closeY;
      final candlePaint = Paint()
        ..color = candle.isBullish ? bullishColor : bearishColor;
      canvas.drawLine(
        Offset(x, highY),
        Offset(x, lowY),
        candlePaint..strokeWidth = 1.5,
      );
      final rect = Rect.fromLTRB(
        x - candleWidth * 0.4,
        bodyTop,
        x + candleWidth * 0.4,
        bodyBottom.clamp(bodyTop, chartHeight + padding),
      );
      canvas.drawRect(rect, candlePaint);
    }
  }

  void _drawEmaLines(
    Canvas canvas,
    Size size,
    double chartHeight,
    double padding,
    double candleWidth,
    double minPrice,
    double priceRange,
    double maxPrice,
  ) {
    _drawEma(
      canvas,
      Colors.amber.shade300,
      candles.map((c) => c.ema20).toList(),
      chartHeight,
      padding,
      candleWidth,
      minPrice,
      priceRange,
      maxPrice,
    );
    _drawEma(
      canvas,
      Colors.blue.shade300,
      candles.map((c) => c.ema50).toList(),
      chartHeight,
      padding,
      candleWidth,
      minPrice,
      priceRange,
      maxPrice,
    );
    _drawEma(
      canvas,
      Colors.purple.shade300,
      candles.map((c) => c.ema100).toList(),
      chartHeight,
      padding,
      candleWidth,
      minPrice,
      priceRange,
      maxPrice,
    );
    _drawEma(
      canvas,
      Colors.teal.shade300,
      candles.map((c) => c.ema200).toList(),
      chartHeight,
      padding,
      candleWidth,
      minPrice,
      priceRange,
      maxPrice,
    );
  }

  void _drawEma(
    Canvas canvas,
    Color color,
    List<double?> emaValues,
    double chartHeight,
    double padding,
    double candleWidth,
    double minPrice,
    double priceRange,
    double maxPrice,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    var hasStarted = false;
    for (int index = 0; index < emaValues.length; index++) {
      final value = emaValues[index];
      if (value == null || value <= 0) continue;
      final x = padding + index * candleWidth * 1.5 + candleWidth / 2;
      final y = padding + (maxPrice - value) / priceRange * chartHeight;
      if (!hasStarted) {
        path.moveTo(x, y);
        hasStarted = true;
      } else {
        path.lineTo(x, y);
      }
    }
    if (hasStarted) {
      canvas.drawPath(path, paint);
    }
  }

  void _drawVolume(
    Canvas canvas,
    Size size,
    double chartHeight,
    double volumeHeight,
    double padding,
    double candleWidth,
    double maxVolume,
  ) {
    final baseY = chartHeight + padding + 8;
    final paint = Paint()..color = volumeColor;
    if (maxVolume <= 0) return;
    for (int index = 0; index < candles.length; index++) {
      final volume = candles[index].volume ?? 0;
      final barHeight = volume / maxVolume * volumeHeight;
      final x = padding + index * candleWidth * 1.5;
      final barRect = Rect.fromLTRB(
        x,
        baseY + volumeHeight - barHeight,
        x + candleWidth * 0.8,
        baseY + volumeHeight,
      );
      canvas.drawRect(barRect, paint);
    }
  }

  void _drawPriceLabels(
    Canvas canvas,
    Size size,
    double chartHeight,
    double padding,
    double minPrice,
    double priceRange,
    double maxPrice,
  ) {
    final paint = TextPainter(
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );
    for (int row = 0; row <= 4; row++) {
      final price = maxPrice - row * (priceRange / 4);
      final text = TextSpan(
        text: price.toStringAsFixed(2),
        style: TextStyle(color: axisColor, fontSize: 11),
      );
      paint.text = text;
      paint.layout();
      paint.paint(
        canvas,
        Offset(
          size.width - padding - paint.width,
          padding + row * (chartHeight / 4) - paint.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
