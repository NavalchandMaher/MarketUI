import 'dart:convert';

/// ===============================================================
/// Paper Trade Dashboard Model
/// Compatible with GET /paper-trades
/// ===============================================================

class PaperTradeModel {
  final int openTrades;

  final int closedTrades;

  final int wins;

  final int losses;

  final double winRate;

  final double totalProfit;

  const PaperTradeModel({
    required this.openTrades,
    required this.closedTrades,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.totalProfit,
  });

  factory PaperTradeModel.empty() {
    return const PaperTradeModel(
      openTrades: 0,
      closedTrades: 0,
      wins: 0,
      losses: 0,
      winRate: 0,
      totalProfit: 0,
    );
  }

  factory PaperTradeModel.fromJson(Map<String, dynamic> json) {
    return PaperTradeModel(
      openTrades: json["open_trades"] ?? 0,

      closedTrades: json["closed_trades"] ?? 0,

      wins: json["wins"] ?? 0,

      losses: json["losses"] ?? 0,

      winRate: (json["win_rate"] ?? 0).toDouble(),

      totalProfit: (json["total_profit"] ?? 0).toDouble(),
    );
  }

  factory PaperTradeModel.fromRawJson(String source) =>
      PaperTradeModel.fromJson(jsonDecode(source));

  Map<String, dynamic> toJson() {
    return {
      "open_trades": openTrades,
      "closed_trades": closedTrades,
      "wins": wins,
      "losses": losses,
      "win_rate": winRate,
      "total_profit": totalProfit,
    };
  }

  String toRawJson() => jsonEncode(toJson());

  PaperTradeModel copyWith({
    int? openTrades,
    int? closedTrades,
    int? wins,
    int? losses,
    double? winRate,
    double? totalProfit,
  }) {
    return PaperTradeModel(
      openTrades: openTrades ?? this.openTrades,
      closedTrades: closedTrades ?? this.closedTrades,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      winRate: winRate ?? this.winRate,
      totalProfit: totalProfit ?? this.totalProfit,
    );
  }

  /// ===========================================================
  /// Helper Getters
  /// ===========================================================

  int get totalTrades => openTrades + closedTrades;

  bool get hasOpenTrades => openTrades > 0;

  bool get hasClosedTrades => closedTrades > 0;

  bool get isProfitable => totalProfit > 0;

  bool get isLoss => totalProfit < 0;

  double get lossRate {
    if ((wins + losses) == 0) {
      return 0;
    }

    return (losses / (wins + losses)) * 100;
  }

  String get summary => "Wins: $wins | Losses: $losses";

  @override
  String toString() {
    return '''
PaperTradeModel(
openTrades : $openTrades
closedTrades : $closedTrades
wins : $wins
losses : $losses
winRate : $winRate
totalProfit : $totalProfit
)
''';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PaperTradeModel &&
            runtimeType == other.runtimeType &&
            openTrades == other.openTrades &&
            closedTrades == other.closedTrades &&
            wins == other.wins &&
            losses == other.losses &&
            winRate == other.winRate &&
            totalProfit == other.totalProfit;
  }

  @override
  int get hashCode =>
      Object.hash(openTrades, closedTrades, wins, losses, winRate, totalProfit);
}
