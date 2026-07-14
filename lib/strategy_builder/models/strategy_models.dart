import 'package:flutter/foundation.dart';
import '../../models/strategy_model.dart' as legacy;

enum IndicatorApply { buy, sell, both }

@immutable
class IndicatorParameter {
  final Map<String, dynamic> params;
  const IndicatorParameter(this.params);

  Map<String, dynamic> toJson() => params;
}

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'parameter': parameter.toJson(),
    'applyTo': applyTo.name,
  };
}

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'indicator': indicator.toJson(),
    'enabled': enabled,
  };
}

@immutable
class RiskSettings {
  final double riskPerTrade; // percent
  final double rr; // risk reward
  final int maxDailyTrades;
  final int maxOpenTrades;

  const RiskSettings({
    this.riskPerTrade = 1.0,
    this.rr = 2.0,
    this.maxDailyTrades = 10,
    this.maxOpenTrades = 3,
  });

  Map<String, dynamic> toJson() => {
    'riskPerTrade': riskPerTrade,
    'rr': rr,
    'maxDailyTrades': maxDailyTrades,
    'maxOpenTrades': maxOpenTrades,
  };
}

@immutable
class StrategyModel {
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

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'exchange': exchange,
    'market': market,
    'timeframe': timeframe,
    'strategyType': strategyType,
    'paperMode': paperMode,
    'liveMode': liveMode,
    'enabled': enabled,
    'buyConditions': buyConditions.map((c) => c.toJson()).toList(),
    'sellConditions': sellConditions.map((c) => c.toJson()).toList(),
    'riskSettings': riskSettings.toJson(),
  };

  factory StrategyModel.fromLegacy(legacy.StrategyModel legacyModel) {
    final emaFast = legacyModel.emaFast;
    final emaSlow = legacyModel.emaSlow;
    final riskSettings = RiskSettings(
      riskPerTrade: legacyModel.tpPercent != 0
          ? legacyModel.tpPercent / legacyModel.slPercent
          : 1.0,
      rr:
          legacyModel.tpPercent /
          (legacyModel.slPercent == 0 ? 1 : legacyModel.slPercent),
      maxDailyTrades: 10,
      maxOpenTrades: 3,
    );

    return StrategyModel(
      name: legacyModel.name,
      description: '',
      exchange: 'BINANCE',
      market: 'BTCUSDT',
      timeframe: '5m',
      strategyType: 'Scalping',
      paperMode: true,
      liveMode: false,
      enabled: true,
      buyConditions: [
        Condition(
          id: legacyModel.id,
          indicator: Indicator(
            id: 'ema_fast',
            name: 'EMA Fast',
            category: 'Trend',
            parameter: IndicatorParameter({'period': emaFast}),
          ),
        ),
      ],
      sellConditions: [
        Condition(
          id: '${legacyModel.id}_sell',
          indicator: Indicator(
            id: 'ema_slow',
            name: 'EMA Slow',
            category: 'Trend',
            parameter: IndicatorParameter({'period': emaSlow}),
          ),
        ),
      ],
      riskSettings: riskSettings,
    );
  }
}
