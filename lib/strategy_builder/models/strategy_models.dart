import 'package:flutter/foundation.dart';
import '../../models/strategy_model.dart' as legacy;

/// =======================================================
/// Indicator Apply
/// =======================================================

enum IndicatorApply { buy, sell, both }

/// =======================================================
/// Indicator Parameters
/// =======================================================

@immutable
class IndicatorParameter {
  final Map<String, dynamic> params;

  const IndicatorParameter(this.params);

  dynamic operator [](String key) => params[key];

  IndicatorParameter copyWith({Map<String, dynamic>? params}) {
    return IndicatorParameter(params ?? this.params);
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(params);

  factory IndicatorParameter.fromJson(Map<String, dynamic>? json) {
    return IndicatorParameter(json ?? {});
  }
}

/// =======================================================
/// Indicator
/// =======================================================

@immutable
class Indicator {
  final String id;
  final String name;
  final String category;
  final IndicatorParameter parameter;
  final IndicatorApply applyTo;

  const Indicator({
    required this.id,
    required this.name,
    required this.category,
    required this.parameter,
    this.applyTo = IndicatorApply.buy,
  });

  Indicator copyWith({
    String? id,
    String? name,
    String? category,
    IndicatorParameter? parameter,
    IndicatorApply? applyTo,
  }) {
    return Indicator(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      parameter: parameter ?? this.parameter,
      applyTo: applyTo ?? this.applyTo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "category": category,
      "parameter": parameter.toJson(),
      "applyTo": applyTo.name,
    };
  }

  factory Indicator.fromJson(Map<String, dynamic> json) {
    return Indicator(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      category: json["category"] ?? "",
      parameter: IndicatorParameter.fromJson(
        json["parameter"] as Map<String, dynamic>?,
      ),
      applyTo: IndicatorApply.values.firstWhere(
        (e) => e.name == (json["applyTo"] ?? "buy"),
        orElse: () => IndicatorApply.buy,
      ),
    );
  }
}

/// =======================================================
/// Condition
/// =======================================================

@immutable
class Condition {
  final String id;
  final Indicator indicator;
  final bool enabled;

  const Condition({
    required this.id,
    required this.indicator,
    this.enabled = true,
  });

  Condition copyWith({String? id, Indicator? indicator, bool? enabled}) {
    return Condition(
      id: id ?? this.id,
      indicator: indicator ?? this.indicator,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "indicator": indicator.toJson(), "enabled": enabled};
  }

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      id: json["id"] ?? "",
      indicator: Indicator.fromJson(json["indicator"] as Map<String, dynamic>),
      enabled: json["enabled"] ?? true,
    );
  }
}

/// =======================================================
/// Risk Settings
/// =======================================================

@immutable
class RiskSettings {
  final double riskPerTrade;
  final double rr;
  final int maxDailyTrades;
  final int maxOpenTrades;

  const RiskSettings({
    this.riskPerTrade = 1.0,
    this.rr = 2.0,
    this.maxDailyTrades = 10,
    this.maxOpenTrades = 3,
  });

  RiskSettings copyWith({
    double? riskPerTrade,
    double? rr,
    int? maxDailyTrades,
    int? maxOpenTrades,
  }) {
    return RiskSettings(
      riskPerTrade: riskPerTrade ?? this.riskPerTrade,
      rr: rr ?? this.rr,
      maxDailyTrades: maxDailyTrades ?? this.maxDailyTrades,
      maxOpenTrades: maxOpenTrades ?? this.maxOpenTrades,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "riskPerTrade": riskPerTrade,
      "rr": rr,
      "maxDailyTrades": maxDailyTrades,
      "maxOpenTrades": maxOpenTrades,
    };
  }

  factory RiskSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const RiskSettings();
    }

    return RiskSettings(
      riskPerTrade: (json["riskPerTrade"] ?? 1.0).toDouble(),
      rr: (json["rr"] ?? 2.0).toDouble(),
      maxDailyTrades: json["maxDailyTrades"] ?? 10,
      maxOpenTrades: json["maxOpenTrades"] ?? 3,
    );
  }

  /// Build RiskSettings from API payload
  factory RiskSettings.fromApiPayload(Map<String, dynamic> json) {
    return RiskSettings(
      riskPerTrade: (json["risk_percent"] ?? 1.0).toDouble(),
      rr: (json["tp"] ?? 2.0).toDouble(),
      maxDailyTrades: 10,
      maxOpenTrades: 3,
    );
  }
}

/// =======================================================
/// Strategy Model
/// =======================================================

@immutable
class StrategyModel {
  /// Used for Edit API
  final String? id;

  final String name;
  final String description;
  final String exchange;
  final String market;
  final String timeframe;
  final String strategyType;

  final bool paperMode;
  final bool liveMode;
  final bool enabled;

  final List<Condition> buyConditions;
  final List<Condition> sellConditions;

  final RiskSettings riskSettings;

  const StrategyModel({
    this.id,
    this.name = '',
    this.description = '',
    this.exchange = 'BINANCE',
    this.market = 'BTCUSDT',
    this.timeframe = '5m',
    this.strategyType = 'Scalping',
    this.paperMode = true,
    this.liveMode = false,
    this.enabled = true,
    this.buyConditions = const [],
    this.sellConditions = const [],
    this.riskSettings = const RiskSettings(),
  });

  StrategyModel copyWith({
    String? id,
    String? name,
    String? description,
    String? exchange,
    String? market,
    String? timeframe,
    String? strategyType,
    bool? paperMode,
    bool? liveMode,
    bool? enabled,
    List<Condition>? buyConditions,
    List<Condition>? sellConditions,
    RiskSettings? riskSettings,
  }) {
    return StrategyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exchange: exchange ?? this.exchange,
      market: market ?? this.market,
      timeframe: timeframe ?? this.timeframe,
      strategyType: strategyType ?? this.strategyType,
      paperMode: paperMode ?? this.paperMode,
      liveMode: liveMode ?? this.liveMode,
      enabled: enabled ?? this.enabled,
      buyConditions: buyConditions ?? this.buyConditions,
      sellConditions: sellConditions ?? this.sellConditions,
      riskSettings: riskSettings ?? this.riskSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "exchange": exchange,
      "market": market,
      "timeframe": timeframe,
      "strategyType": strategyType,
      "paperMode": paperMode,
      "liveMode": liveMode,
      "enabled": enabled,
      "buyConditions": buyConditions.map((e) => e.toJson()).toList(),
      "sellConditions": sellConditions.map((e) => e.toJson()).toList(),
      "riskSettings": riskSettings.toJson(),
    };
  }

  /// Used only for old Strategy screen compatibility
  factory StrategyModel.fromLegacy(legacy.StrategyModel legacyModel) {
    return StrategyModel(
      id: legacyModel.id,
      name: legacyModel.name,
      description: '',
      exchange: 'BINANCE',
      market: 'BTCUSDT',
      timeframe: '5m',
      strategyType: 'Scalping',
      paperMode: true,
      liveMode: false,
      enabled: true,
      buyConditions: const [],
      sellConditions: const [],
      riskSettings: RiskSettings(riskPerTrade: 1, rr: legacyModel.tpPercent),
    );
  }
  factory StrategyModel.fromApiPayload(Map<String, dynamic> json) {
    final indicatorParameters =
        (json["indicator_parameters"] as Map<String, dynamic>?) ?? {};

    return StrategyModel(
      id: json["id"],
      name: json["strategy_name"] ?? "",
      description: json["description"] ?? "",
      exchange: json["exchange"] ?? "BINANCE",
      market: json["symbol"] ?? "BTCUSDT",
      timeframe: json["timeframe"] ?? "5m",
      strategyType: json["strategy_type"] ?? "Scalping",
      paperMode: json["paper_mode"] ?? true,
      liveMode: json["live_mode"] ?? false,
      enabled: json["enabled"] ?? true,

      buyConditions:
          (indicatorParameters["buy_conditions"] as List<dynamic>? ?? [])
              .map((e) => Condition.fromJson(Map<String, dynamic>.from(e)))
              .toList(),

      sellConditions:
          (indicatorParameters["sell_conditions"] as List<dynamic>? ?? [])
              .map((e) => Condition.fromJson(Map<String, dynamic>.from(e)))
              .toList(),

      riskSettings: RiskSettings(
        riskPerTrade: (json["risk_percent"] ?? 1.0).toDouble(),
        rr: (json["tp"] ?? 2.0).toDouble(),
        maxDailyTrades: 10,
        maxOpenTrades: 3,
      ),
    );
  }
}
