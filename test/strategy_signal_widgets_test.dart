import 'package:flutter_test/flutter_test.dart';
import 'package:market_app/models/analysis_model.dart';
import 'package:market_app/widgets/strategy_signal_widgets.dart';

void main() {
  group('Strategy signal helpers', () {
    test('SELL take profit is below entry and stop loss is above entry', () {
      expect(calculateTakeProfitPrice(100, 2, 'SELL'), 98);
      expect(calculateStopLossPrice(100, 1, 'SELL'), 101);
      expect(calculateTakeProfitPrice(100, 2, 'BUY'), 102);
      expect(calculateStopLossPrice(100, 1, 'BUY'), 99);
    });

    test('sortSignalsByConfidence orders highest confidence first', () {
      final signals = [
        const AnalysisModel(
          symbol: 'BTCUSDT',
          timeframe: '5m',
          signal: 'SELL',
          confidence: 62,
          score: 80,
          reason: '',
          marketRegime: 'TRENDING',
          higherTimeframe: 'BULLISH',
          price: 100.0,
          strategy: StrategyInfo(
            id: 's1',
            name: 'Momentum',
            version: 1,
            buyThreshold: 60,
            sellThreshold: 40,
            tpPercent: 1.5,
            slPercent: 0.8,
          ),
          indicators: IndicatorInfo(
            ema20: 101,
            ema50: 100,
            ema100: 99,
            ema200: 98,
            rsi: 68,
            macd: 0.8,
            macdSignal: 0.2,
            adx: 18,
            atr: 0.4,
            pcr: 0.3,
            volumeRatio: 1.2,
            oiChangePct: 0.5,
          ),
          paperTrade: PaperTradeInfo(
            signal: 'BUY',
            entryPrice: 100.0,
            takeProfit: 101.5,
            stopLoss: 99.2,
            openedAt: '2024-01-01',
          ),
          chart: [],
        ),
        const AnalysisModel(
          symbol: 'ETHUSDT',
          timeframe: '15m',
          signal: 'BUY',
          confidence: 88,
          score: 90,
          reason: '',
          marketRegime: 'TRENDING',
          higherTimeframe: 'BULLISH',
          price: 200.0,
          strategy: StrategyInfo(
            id: 's2',
            name: 'Trend',
            version: 1,
            buyThreshold: 60,
            sellThreshold: 40,
            tpPercent: 2.2,
            slPercent: 1.1,
          ),
          indicators: IndicatorInfo(
            ema20: 201,
            ema50: 199,
            ema100: 195,
            ema200: 190,
            rsi: 72,
            macd: 1.2,
            macdSignal: 0.3,
            adx: 24,
            atr: 0.6,
            pcr: 0.4,
            volumeRatio: 1.4,
            oiChangePct: 0.8,
          ),
          paperTrade: PaperTradeInfo(
            signal: 'SELL',
            entryPrice: 200.0,
            takeProfit: 198.0,
            stopLoss: 202.0,
            openedAt: '2024-01-02',
          ),
          chart: [],
        ),
      ];

      final sorted = sortSignalsByConfidence(signals);

      expect(sorted.first.symbol, 'ETHUSDT');
      expect(sorted.last.symbol, 'BTCUSDT');
    });

    test('buildTradeJustificationBullets returns short insight list', () {
      const analysis = AnalysisModel(
        symbol: 'BTCUSDT',
        timeframe: '5m',
        signal: 'BUY',
        confidence: 84,
        score: 88,
        reason: '',
        marketRegime: 'TRENDING',
        higherTimeframe: 'BULLISH',
        price: 100.0,
        strategy: StrategyInfo(
          id: 's1',
          name: 'Momentum',
          version: 1,
          buyThreshold: 60,
          sellThreshold: 40,
          tpPercent: 1.5,
          slPercent: 0.8,
        ),
        indicators: IndicatorInfo(
          ema20: 101,
          ema50: 100,
          ema100: 99,
          ema200: 98,
          rsi: 68,
          macd: 0.8,
          macdSignal: 0.2,
          adx: 18,
          atr: 0.4,
          pcr: 0.3,
          volumeRatio: 1.2,
          oiChangePct: 0.5,
        ),
        paperTrade: PaperTradeInfo(
          signal: 'BUY',
          entryPrice: 100.0,
          takeProfit: 101.5,
          stopLoss: 99.2,
          openedAt: '2024-01-01',
        ),
        chart: [],
      );

      final bullets = buildTradeJustificationBullets(analysis);

      expect(bullets.length, 4);
      expect(bullets.first, contains('support'));
    });

    test('buildTradeJustificationBullets uses contextual API justification', () {
      const analysis = AnalysisModel(
        symbol: 'BTCUSDT',
        timeframe: '5m',
        signal: 'SELL',
        confidence: 84,
        score: -6,
        reason: '',
        tradeJustification: [
          'Short Momentum produced a SELL from its configured RSI rule.',
          'Market sentiment is bearish and open interest is falling.',
        ],
        marketRegime: 'TRENDING',
        higherTimeframe: 'BEARISH',
        price: 100.0,
        strategy: StrategyInfo(
          id: 's1',
          name: 'Short Momentum',
          version: 1,
          buyThreshold: 3,
          sellThreshold: -3,
          tpPercent: 1.5,
          slPercent: 0.8,
        ),
        indicators: IndicatorInfo(
          ema20: 99,
          ema50: 100,
          ema100: 101,
          ema200: 102,
          rsi: 68,
          macd: -0.8,
          macdSignal: -0.2,
          adx: 28,
          atr: 0.4,
          pcr: 0.7,
          volumeRatio: 1.2,
          oiChangePct: -0.5,
        ),
        paperTrade: PaperTradeInfo(
          signal: 'WAIT',
          entryPrice: 0,
          takeProfit: 0,
          stopLoss: 0,
          openedAt: '',
        ),
        chart: [],
      );

      expect(
        buildTradeJustificationBullets(analysis),
        analysis.tradeJustification,
      );
    });
  });
}
