import 'dart:convert';

/// ===============================================================
/// Trading Report Model
///
/// This model is used by the Reports screen.
/// It aggregates statistics from Performance,
/// Backtest, Paper Trading and Strategy.
/// ===============================================================

class ReportModel {
  final String title;

  final DateTime generatedAt;

  final String symbol;

  final String timeframe;

  final double currentBalance;

  final double netProfit;

  final double grossProfit;

  final double grossLoss;

  final double winRate;

  final int totalTrades;

  final int wins;

  final int losses;

  final double profitFactor;

  final double sharpeRatio;

  final double drawdown;

  final double expectancy;

  final String strategyName;

  final int strategyVersion;

  final double tpPercent;

  final double slPercent;

  const ReportModel({
    required this.title,
    required this.generatedAt,
    required this.symbol,
    required this.timeframe,
    required this.currentBalance,
    required this.netProfit,
    required this.grossProfit,
    required this.grossLoss,
    required this.winRate,
    required this.totalTrades,
    required this.wins,
    required this.losses,
    required this.profitFactor,
    required this.sharpeRatio,
    required this.drawdown,
    required this.expectancy,
    required this.strategyName,
    required this.strategyVersion,
    required this.tpPercent,
    required this.slPercent,
  });

  factory ReportModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ReportModel(
      title: json["title"] ?? "Trading Report",

      generatedAt:
          DateTime.tryParse(
                json["generated_at"] ?? "",
              ) ??
              DateTime.now(),

      symbol: json["symbol"] ?? "",

      timeframe: json["timeframe"] ?? "",

      currentBalance:
          (json["current_balance"] ?? 0).toDouble(),

      netProfit:
          (json["net_profit"] ?? 0).toDouble(),

      grossProfit:
          (json["gross_profit"] ?? 0).toDouble(),

      grossLoss:
          (json["gross_loss"] ?? 0).toDouble(),

      winRate:
          (json["win_rate"] ?? 0).toDouble(),

      totalTrades:
          json["total_trades"] ?? 0,

      wins:
          json["wins"] ?? 0,

      losses:
          json["losses"] ?? 0,

      profitFactor:
          (json["profit_factor"] ?? 0).toDouble(),

      sharpeRatio:
          (json["sharpe_ratio"] ?? 0).toDouble(),

      drawdown:
          (json["drawdown"] ?? 0).toDouble(),

      expectancy:
          (json["expectancy"] ?? 0).toDouble(),

      strategyName:
          json["strategy_name"] ?? "",

      strategyVersion:
          json["strategy_version"] ?? 1,

      tpPercent:
          (json["tp_percent"] ?? 0).toDouble(),

      slPercent:
          (json["sl_percent"] ?? 0).toDouble(),
    );
  }

  factory ReportModel.fromRawJson(
    String source,
  ) =>
      ReportModel.fromJson(
        jsonDecode(source),
      );

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "generated_at":
          generatedAt.toIso8601String(),
      "symbol": symbol,
      "timeframe": timeframe,
      "current_balance": currentBalance,
      "net_profit": netProfit,
      "gross_profit": grossProfit,
      "gross_loss": grossLoss,
      "win_rate": winRate,
      "total_trades": totalTrades,
      "wins": wins,
      "losses": losses,
      "profit_factor": profitFactor,
      "sharpe_ratio": sharpeRatio,
      "drawdown": drawdown,
      "expectancy": expectancy,
      "strategy_name": strategyName,
      "strategy_version": strategyVersion,
      "tp_percent": tpPercent,
      "sl_percent": slPercent,
    };
  }

  String toRawJson() =>
      jsonEncode(toJson());

  ReportModel copyWith({
    String? title,
    DateTime? generatedAt,
    String? symbol,
    String? timeframe,
    double? currentBalance,
    double? netProfit,
    double? grossProfit,
    double? grossLoss,
    double? winRate,
    int? totalTrades,
    int? wins,
    int? losses,
    double? profitFactor,
    double? sharpeRatio,
    double? drawdown,
    double? expectancy,
    String? strategyName,
    int? strategyVersion,
    double? tpPercent,
    double? slPercent,
  }) {
    return ReportModel(
      title: title ?? this.title,
      generatedAt:
          generatedAt ?? this.generatedAt,
      symbol: symbol ?? this.symbol,
      timeframe:
          timeframe ?? this.timeframe,
      currentBalance:
          currentBalance ??
              this.currentBalance,
      netProfit:
          netProfit ?? this.netProfit,
      grossProfit:
          grossProfit ??
              this.grossProfit,
      grossLoss:
          grossLoss ?? this.grossLoss,
      winRate:
          winRate ?? this.winRate,
      totalTrades:
          totalTrades ??
              this.totalTrades,
      wins: wins ?? this.wins,
      losses:
          losses ?? this.losses,
      profitFactor:
          profitFactor ??
              this.profitFactor,
      sharpeRatio:
          sharpeRatio ??
              this.sharpeRatio,
      drawdown:
          drawdown ?? this.drawdown,
      expectancy:
          expectancy ??
              this.expectancy,
      strategyName:
          strategyName ??
              this.strategyName,
      strategyVersion:
          strategyVersion ??
              this.strategyVersion,
      tpPercent:
          tpPercent ?? this.tpPercent,
      slPercent:
          slPercent ?? this.slPercent,
    );
  }

  bool get isProfitable =>
      netProfit > 0;

  bool get hasTrades =>
      totalTrades > 0;

  double get lossRate {
    if ((wins + losses) == 0) return 0;
    return (losses / (wins + losses)) * 100;
  }

  double get riskRewardRatio {
    if (slPercent == 0) return 0;
    return tpPercent / slPercent;
  }

  @override
  String toString() {
    return '''
ReportModel(
title: $title
symbol: $symbol
strategy: $strategyName
netProfit: $netProfit
winRate: $winRate
)
''';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportModel &&
          runtimeType == other.runtimeType &&
          generatedAt == other.generatedAt &&
          symbol == other.symbol &&
          strategyName == other.strategyName;

  @override
  int get hashCode =>
      Object.hash(
        generatedAt,
        symbol,
        strategyName,
      );
}