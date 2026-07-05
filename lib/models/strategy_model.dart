import 'dart:convert';

/// ===============================================================
/// Strategy Model
/// Compatible with GET /strategy
/// ===============================================================

class StrategyModel {
  final String name;

  final int version;

  final int buyThreshold;

  final int sellThreshold;

  final double tpPercent;

  final double slPercent;

  final int emaFast;

  final int emaSlow;

  final int rsiBuy;

  final int rsiSell;

  const StrategyModel({
    required this.name,
    required this.version,
    required this.buyThreshold,
    required this.sellThreshold,
    required this.tpPercent,
    required this.slPercent,
    required this.emaFast,
    required this.emaSlow,
    required this.rsiBuy,
    required this.rsiSell,
  });

  factory StrategyModel.empty() {
    return const StrategyModel(
      name: "",
      version: 1,
      buyThreshold: 3,
      sellThreshold: -3,
      tpPercent: 2,
      slPercent: 1,
      emaFast: 20,
      emaSlow: 50,
      rsiBuy: 40,
      rsiSell: 65,
    );
  }

  factory StrategyModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StrategyModel(
      name: json["name"] ?? "",

      version: json["version"] ?? 1,

      buyThreshold:
          json["buy_threshold"] ?? 3,

      sellThreshold:
          json["sell_threshold"] ?? -3,

      tpPercent:
          (json["tp_percent"] ?? 2)
              .toDouble(),

      slPercent:
          (json["sl_percent"] ?? 1)
              .toDouble(),

      emaFast:
          json["ema_fast"] ?? 20,

      emaSlow:
          json["ema_slow"] ?? 50,

      rsiBuy:
          json["rsi_buy"] ?? 40,

      rsiSell:
          json["rsi_sell"] ?? 65,
    );
  }

  factory StrategyModel.fromRawJson(
    String source,
  ) =>
      StrategyModel.fromJson(
        jsonDecode(source),
      );

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "version": version,
      "buy_threshold": buyThreshold,
      "sell_threshold": sellThreshold,
      "tp_percent": tpPercent,
      "sl_percent": slPercent,
      "ema_fast": emaFast,
      "ema_slow": emaSlow,
      "rsi_buy": rsiBuy,
      "rsi_sell": rsiSell,
    };
  }

  String toRawJson() =>
      jsonEncode(toJson());

  StrategyModel copyWith({
    String? name,
    int? version,
    int? buyThreshold,
    int? sellThreshold,
    double? tpPercent,
    double? slPercent,
    int? emaFast,
    int? emaSlow,
    int? rsiBuy,
    int? rsiSell,
  }) {
    return StrategyModel(
      name: name ?? this.name,
      version: version ?? this.version,
      buyThreshold:
          buyThreshold ??
              this.buyThreshold,
      sellThreshold:
          sellThreshold ??
              this.sellThreshold,
      tpPercent:
          tpPercent ?? this.tpPercent,
      slPercent:
          slPercent ?? this.slPercent,
      emaFast:
          emaFast ?? this.emaFast,
      emaSlow:
          emaSlow ?? this.emaSlow,
      rsiBuy:
          rsiBuy ?? this.rsiBuy,
      rsiSell:
          rsiSell ?? this.rsiSell,
    );
  }

  /// ===========================================================
  /// Helper Getters
  /// ===========================================================

  bool get isValid =>
      name.isNotEmpty;

  double get riskRewardRatio {
    if (slPercent == 0) return 0;
    return tpPercent / slPercent;
  }

  String get displayName =>
      "$name v$version";

  @override
  String toString() {
    return '''
StrategyModel(
name: $name
version: $version
buyThreshold: $buyThreshold
sellThreshold: $sellThreshold
tpPercent: $tpPercent
slPercent: $slPercent
emaFast: $emaFast
emaSlow: $emaSlow
rsiBuy: $rsiBuy
rsiSell: $rsiSell
)
''';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StrategyModel &&
            runtimeType == other.runtimeType &&
            name == other.name &&
            version == other.version;
  }

  @override
  int get hashCode =>
      Object.hash(name, version);
}