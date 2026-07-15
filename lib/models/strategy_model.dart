import 'dart:convert';

/// ===============================================================
/// Strategy Model
/// Compatible with GET /strategy
/// ===============================================================

class StrategyModel {
  final String id;

  final String name;

  final int version;

  final bool isDefault;

  final int buyThreshold;

  final int sellThreshold;

  final double tpPercent;

  final double slPercent;

  final int emaFast;

  final int emaSlow;

  final int rsiBuy;

  final int rsiSell;

  const StrategyModel({
    required this.id,
    required this.name,
    required this.version,
    required this.isDefault,
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
      id: "",
      name: "",
      version: 1,
      isDefault: false,
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

  factory StrategyModel.fromJson(Map<String, dynamic> json) {
    // Extract indicator_parameters if available
    final indicatorParams = json["indicator_parameters"] ?? {};

    return StrategyModel(
      id: json["id"] ?? json["_id"]?.toString() ?? "",
      name: json["strategy_name"] ?? json["name"] ?? "",

      version: json["version"] ?? 1,

      isDefault: json["is_default"] ?? false,

      buyThreshold:
          indicatorParams["buy_threshold"] ?? json["buy_threshold"] ?? 3,

      sellThreshold:
          indicatorParams["sell_threshold"] ?? json["sell_threshold"] ?? -3,

      tpPercent: (json["tp"] ?? json["tp_percent"] ?? 2).toDouble(),

      slPercent: (json["sl"] ?? json["sl_percent"] ?? 1).toDouble(),

      emaFast: indicatorParams["ema_fast"] ?? json["ema_fast"] ?? 20,

      emaSlow: indicatorParams["ema_slow"] ?? json["ema_slow"] ?? 50,

      rsiBuy: indicatorParams["rsi_buy"] ?? json["rsi_buy"] ?? 40,

      rsiSell: indicatorParams["rsi_sell"] ?? json["rsi_sell"] ?? 65,
    );
  }

  factory StrategyModel.fromRawJson(String source) =>
      StrategyModel.fromJson(jsonDecode(source));

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "version": version,
      "buy_threshold": buyThreshold,
      "sell_threshold": sellThreshold,
      "is_default": isDefault,
      "tp_percent": tpPercent,
      "sl_percent": slPercent,
      "ema_fast": emaFast,
      "ema_slow": emaSlow,
      "rsi_buy": rsiBuy,
      "rsi_sell": rsiSell,
    };
  }

  String toRawJson() => jsonEncode(toJson());

  StrategyModel copyWith({
    String? id,
    String? name,
    int? version,
    bool? isDefault,
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
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      isDefault: isDefault ?? this.isDefault,
      buyThreshold: buyThreshold ?? this.buyThreshold,
      sellThreshold: sellThreshold ?? this.sellThreshold,
      tpPercent: tpPercent ?? this.tpPercent,
      slPercent: slPercent ?? this.slPercent,
      emaFast: emaFast ?? this.emaFast,
      emaSlow: emaSlow ?? this.emaSlow,
      rsiBuy: rsiBuy ?? this.rsiBuy,
      rsiSell: rsiSell ?? this.rsiSell,
    );
  }

  /// ===========================================================
  /// Helper Getters
  /// ===========================================================

  bool get isValid => name.isNotEmpty;

  double get riskRewardRatio {
    if (slPercent == 0) return 0;
    return tpPercent / slPercent;
  }

  String get displayName => "$name v$version";

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
            id == other.id &&
            name == other.name &&
            version == other.version;
  }

  @override
  int get hashCode => Object.hash(id, name, version);
}
