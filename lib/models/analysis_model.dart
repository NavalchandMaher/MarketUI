import 'dart:convert';

/// ===============================================================
/// Analysis Model
/// Compatible with GET /analysis
/// ===============================================================

class AnalysisModel {
  final String symbol;
  final String timeframe;

  final String signal;

  final int confidence;

  final int score;

  final String reason;

  final String marketRegime;

  final String higherTimeframe;

  final double price;

  final StrategyInfo strategy;

  final IndicatorInfo indicators;

  final PaperTradeInfo paperTrade;

  final List<List<double>> chart;

  const AnalysisModel({
    required this.symbol,
    required this.timeframe,
    required this.signal,
    required this.confidence,
    required this.score,
    required this.reason,
    required this.marketRegime,
    required this.higherTimeframe,
    required this.price,
    required this.strategy,
    required this.indicators,
    required this.paperTrade,
    required this.chart,
  });

  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    return AnalysisModel(
      symbol: json["symbol"] ?? "",

      timeframe: json["timeframe"] ?? "",

      signal: json["signal"] ?? "WAIT",

      confidence: json["confidence"] ?? 0,

      score: json["score"] ?? 0,

      reason: json["reason"] ?? "",

      marketRegime: json["market_regime"] ?? "",

      higherTimeframe: json["higher_timeframe"] ?? "",

      price: (json["price"] ?? 0).toDouble(),

      strategy: StrategyInfo.fromJson(json["strategy"] ?? {}),

      indicators: IndicatorInfo.fromJson(json["indicators"] ?? {}),

      paperTrade: PaperTradeInfo.fromJson(json["paper_trade"] ?? {}),

      chart: (json["chart"] as List? ?? [])
          .map<List<double>>(
            (item) => (item as List).map((e) => (e as num).toDouble()).toList(),
          )
          .toList(),
    );
  }

  factory AnalysisModel.fromRawJson(String source) =>
      AnalysisModel.fromJson(jsonDecode(source));

  Map<String, dynamic> toJson() {
    return {
      "symbol": symbol,
      "timeframe": timeframe,
      "signal": signal,
      "confidence": confidence,
      "score": score,
      "reason": reason,
      "market_regime": marketRegime,
      "higher_timeframe": higherTimeframe,
      "price": price,
      "strategy": strategy.toJson(),
      "indicators": indicators.toJson(),
      "paper_trade": paperTrade.toJson(),
      "chart": chart,
    };
  }

  String toRawJson() => jsonEncode(toJson());

  AnalysisModel copyWith({
    String? symbol,
    String? timeframe,
    String? signal,
    int? confidence,
    int? score,
    String? reason,
    String? marketRegime,
    String? higherTimeframe,
    double? price,
    StrategyInfo? strategy,
    IndicatorInfo? indicators,
    PaperTradeInfo? paperTrade,
    List<List<double>>? chart,
  }) {
    return AnalysisModel(
      symbol: symbol ?? this.symbol,
      timeframe: timeframe ?? this.timeframe,
      signal: signal ?? this.signal,
      confidence: confidence ?? this.confidence,
      score: score ?? this.score,
      reason: reason ?? this.reason,
      marketRegime: marketRegime ?? this.marketRegime,
      higherTimeframe: higherTimeframe ?? this.higherTimeframe,
      price: price ?? this.price,
      strategy: strategy ?? this.strategy,
      indicators: indicators ?? this.indicators,
      paperTrade: paperTrade ?? this.paperTrade,
      chart: chart ?? this.chart,
    );
  }

  bool get isBuy => signal.toUpperCase() == "BUY";

  bool get isSell => signal.toUpperCase() == "SELL";

  bool get isWait => signal.toUpperCase() == "WAIT";

  bool get isBullish => higherTimeframe == "BULLISH";

  bool get isBearish => higherTimeframe == "BEARISH";

  @override
  String toString() {
    return '''
AnalysisModel(
symbol: $symbol
signal: $signal
confidence: $confidence
score: $score
price: $price
)
''';
  }
}

/// ===============================================================
/// Strategy Info
/// ===============================================================

class StrategyInfo {
  final String name;

  final int version;

  final int buyThreshold;

  final int sellThreshold;

  final double tpPercent;

  final double slPercent;

  const StrategyInfo({
    required this.name,
    required this.version,
    required this.buyThreshold,
    required this.sellThreshold,
    required this.tpPercent,
    required this.slPercent,
  });

  factory StrategyInfo.fromJson(Map<String, dynamic> json) {
    return StrategyInfo(
      name: json["name"] ?? "",
      version: json["version"] ?? 1,
      buyThreshold: json["buy_threshold"] ?? 0,
      sellThreshold: json["sell_threshold"] ?? 0,
      tpPercent: (json["tp_percent"] ?? 0).toDouble(),
      slPercent: (json["sl_percent"] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "version": version,
      "buy_threshold": buyThreshold,
      "sell_threshold": sellThreshold,
      "tp_percent": tpPercent,
      "sl_percent": slPercent,
    };
  }

  StrategyInfo copyWith({
    String? name,
    int? version,
    int? buyThreshold,
    int? sellThreshold,
    double? tpPercent,
    double? slPercent,
  }) {
    return StrategyInfo(
      name: name ?? this.name,
      version: version ?? this.version,
      buyThreshold: buyThreshold ?? this.buyThreshold,
      sellThreshold: sellThreshold ?? this.sellThreshold,
      tpPercent: tpPercent ?? this.tpPercent,
      slPercent: slPercent ?? this.slPercent,
    );
  }
}

/// ===============================================================
/// Indicator Info
/// ===============================================================

class IndicatorInfo {
  final double ema20;
  final double ema50;
  final double ema100;
  final double ema200;

  final double rsi;

  final double macd;
  final double macdSignal;

  final double adx;
  final double atr;

  final double pcr;

  final double volumeRatio;

  final double oiChangePct;

  const IndicatorInfo({
    required this.ema20,
    required this.ema50,
    required this.ema100,
    required this.ema200,
    required this.rsi,
    required this.macd,
    required this.macdSignal,
    required this.adx,
    required this.atr,
    required this.pcr,
    required this.volumeRatio,
    required this.oiChangePct,
  });

  factory IndicatorInfo.fromJson(Map<String, dynamic> json) {
    return IndicatorInfo(
      ema20: (json["ema20"] ?? 0).toDouble(),

      ema50: (json["ema50"] ?? 0).toDouble(),

      ema100: (json["ema100"] ?? 0).toDouble(),

      ema200: (json["ema200"] ?? 0).toDouble(),

      rsi: (json["rsi"] ?? 0).toDouble(),

      macd: (json["macd"] ?? 0).toDouble(),

      macdSignal: (json["macd_signal"] ?? 0).toDouble(),

      adx: (json["adx"] ?? 0).toDouble(),

      atr: (json["atr"] ?? 0).toDouble(),

      pcr: (json["pcr"] ?? 0).toDouble(),

      volumeRatio: (json["volume_ratio"] ?? 0).toDouble(),

      oiChangePct: (json["oi_change_pct"] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "ema20": ema20,
      "ema50": ema50,
      "ema100": ema100,
      "ema200": ema200,
      "rsi": rsi,
      "macd": macd,
      "macd_signal": macdSignal,
      "adx": adx,
      "atr": atr,
      "pcr": pcr,
      "volume_ratio": volumeRatio,
      "oi_change_pct": oiChangePct,
    };
  }

  IndicatorInfo copyWith({
    double? ema20,
    double? ema50,
    double? ema100,
    double? ema200,
    double? rsi,
    double? macd,
    double? macdSignal,
    double? adx,
    double? atr,
    double? pcr,
    double? volumeRatio,
    double? oiChangePct,
  }) {
    return IndicatorInfo(
      ema20: ema20 ?? this.ema20,
      ema50: ema50 ?? this.ema50,
      ema100: ema100 ?? this.ema100,
      ema200: ema200 ?? this.ema200,
      rsi: rsi ?? this.rsi,
      macd: macd ?? this.macd,
      macdSignal: macdSignal ?? this.macdSignal,
      adx: adx ?? this.adx,
      atr: atr ?? this.atr,
      pcr: pcr ?? this.pcr,
      volumeRatio: volumeRatio ?? this.volumeRatio,
      oiChangePct: oiChangePct ?? this.oiChangePct,
    );
  }

  bool get isBullish => ema20 > ema50 && ema50 > ema100 && ema100 > ema200;

  bool get isBearish => ema20 < ema50 && ema50 < ema100 && ema100 < ema200;

  bool get macdBullish => macd > macdSignal;

  bool get macdBearish => macd < macdSignal;

  bool get strongTrend => adx >= 25;

  bool get weakTrend => adx < 20;

  bool get overBought => rsi >= 70;

  bool get overSold => rsi <= 30;

  @override
  String toString() {
    return '''
IndicatorInfo(
EMA20 : $ema20
EMA50 : $ema50
EMA100: $ema100
EMA200: $ema200
RSI   : $rsi
MACD  : $macd
ADX   : $adx
PCR   : $pcr
)
''';
  }
}

/// ===============================================================
/// Paper Trade Info
/// ===============================================================

class PaperTradeInfo {
  final String signal;

  final double entryPrice;

  final double takeProfit;

  final double stopLoss;

  final String openedAt;

  const PaperTradeInfo({
    required this.signal,
    required this.entryPrice,
    required this.takeProfit,
    required this.stopLoss,
    required this.openedAt,
  });

  factory PaperTradeInfo.fromJson(Map<String, dynamic> json) {
    return PaperTradeInfo(
      signal: json["signal"] ?? "WAIT",

      entryPrice: (json["entry_price"] ?? 0).toDouble(),

      takeProfit: (json["take_profit"] ?? 0).toDouble(),

      stopLoss: (json["stop_loss"] ?? 0).toDouble(),

      openedAt: json["opened_at"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "signal": signal,
      "entry_price": entryPrice,
      "take_profit": takeProfit,
      "stop_loss": stopLoss,
      "opened_at": openedAt,
    };
  }

  PaperTradeInfo copyWith({
    String? signal,
    double? entryPrice,
    double? takeProfit,
    double? stopLoss,
    String? openedAt,
  }) {
    return PaperTradeInfo(
      signal: signal ?? this.signal,
      entryPrice: entryPrice ?? this.entryPrice,
      takeProfit: takeProfit ?? this.takeProfit,
      stopLoss: stopLoss ?? this.stopLoss,
      openedAt: openedAt ?? this.openedAt,
    );
  }

  bool get isBuy => signal.toUpperCase() == "BUY";

  bool get isSell => signal.toUpperCase() == "SELL";

  bool get isWait => signal.toUpperCase() == "WAIT";

  bool get hasOpenTrade =>
      openedAt.isNotEmpty && openedAt.toLowerCase() != "none";

  double get risk => (entryPrice - stopLoss).abs();

  double get reward => (takeProfit - entryPrice).abs();

  double get riskRewardRatio {
    if (risk == 0) return 0;
    return reward / risk;
  }

  @override
  String toString() {
    return '''
PaperTradeInfo(
signal: $signal
entryPrice: $entryPrice
takeProfit: $takeProfit
stopLoss: $stopLoss
openedAt: $openedAt
)
''';
  }
}
