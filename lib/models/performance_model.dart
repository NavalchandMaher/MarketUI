import 'dart:convert';

/// ===============================================================
/// Performance Model
/// Compatible with GET /performance
/// ===============================================================

class PerformanceModel {
  final AccountModel account;

  final SnapshotModel snapshot;

  final List<dynamic> daily;

  final List<dynamic> weekly;

  final List<dynamic> monthly;

  final List<dynamic> symbols;

  final List<dynamic> strategies;

  final List<dynamic> equityCurve;

  const PerformanceModel({
    required this.account,
    required this.snapshot,
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.symbols,
    required this.strategies,
    required this.equityCurve,
  });

  factory PerformanceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PerformanceModel(
      account: AccountModel.fromJson(
        json["account"] ?? {},
      ),

      snapshot: SnapshotModel.fromJson(
        json["snapshot"] ?? {},
      ),

      daily: List<dynamic>.from(
        json["daily"] ?? [],
      ),

      weekly: List<dynamic>.from(
        json["weekly"] ?? [],
      ),

      monthly: List<dynamic>.from(
        json["monthly"] ?? [],
      ),

      symbols: List<dynamic>.from(
        json["symbols"] ?? [],
      ),

      strategies: List<dynamic>.from(
        json["strategies"] ?? [],
      ),

      equityCurve: List<dynamic>.from(
        json["equity_curve"] ?? [],
      ),
    );
  }

  factory PerformanceModel.fromRawJson(
    String source,
  ) =>
      PerformanceModel.fromJson(
        jsonDecode(source),
      );

  Map<String, dynamic> toJson() {
    return {
      "account": account.toJson(),
      "snapshot": snapshot.toJson(),
      "daily": daily,
      "weekly": weekly,
      "monthly": monthly,
      "symbols": symbols,
      "strategies": strategies,
      "equity_curve": equityCurve,
    };
  }

  String toRawJson() =>
      jsonEncode(toJson());

  PerformanceModel copyWith({
    AccountModel? account,
    SnapshotModel? snapshot,
    List<dynamic>? daily,
    List<dynamic>? weekly,
    List<dynamic>? monthly,
    List<dynamic>? symbols,
    List<dynamic>? strategies,
    List<dynamic>? equityCurve,
  }) {
    return PerformanceModel(
      account: account ?? this.account,
      snapshot: snapshot ?? this.snapshot,
      daily: daily ?? this.daily,
      weekly: weekly ?? this.weekly,
      monthly: monthly ?? this.monthly,
      symbols: symbols ?? this.symbols,
      strategies:
          strategies ?? this.strategies,
      equityCurve:
          equityCurve ?? this.equityCurve,
    );
  }

  bool get hasData =>
      account.totalTrades > 0;

  bool get isProfitable =>
      account.netProfit > 0;

  @override
  String toString() {
    return '''
PerformanceModel(
Trades : ${account.totalTrades}
Win Rate : ${account.winRate}
Net Profit : ${account.netProfit}
)
''';
  }
}

/// ===============================================================
/// Account Model
/// ===============================================================

class AccountModel {
  final double initialBalance;

  final double currentBalance;

  final double netProfit;

  final double winRate;

  final int totalTrades;

  final int wins;

  final int losses;

  const AccountModel({
    required this.initialBalance,
    required this.currentBalance,
    required this.netProfit,
    required this.winRate,
    required this.totalTrades,
    required this.wins,
    required this.losses,
  });

  factory AccountModel.fromJson(
      Map<String, dynamic> json) {
    return AccountModel(
      initialBalance:
          (json["initial_balance"] ?? 0)
              .toDouble(),

      currentBalance:
          (json["current_balance"] ?? 0)
              .toDouble(),

      netProfit:
          (json["net_profit"] ?? 0)
              .toDouble(),

      winRate:
          (json["win_rate"] ?? 0)
              .toDouble(),

      totalTrades:
          json["total_trades"] ?? 0,

      wins:
          json["wins"] ?? 0,

      losses:
          json["losses"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "initial_balance":
          initialBalance,
      "current_balance":
          currentBalance,
      "net_profit": netProfit,
      "win_rate": winRate,
      "total_trades":
          totalTrades,
      "wins": wins,
      "losses": losses,
    };
  }

  AccountModel copyWith({
    double? initialBalance,
    double? currentBalance,
    double? netProfit,
    double? winRate,
    int? totalTrades,
    int? wins,
    int? losses,
  }) {
    return AccountModel(
      initialBalance:
          initialBalance ??
              this.initialBalance,
      currentBalance:
          currentBalance ??
              this.currentBalance,
      netProfit:
          netProfit ?? this.netProfit,
      winRate:
          winRate ?? this.winRate,
      totalTrades:
          totalTrades ??
              this.totalTrades,
      wins:
          wins ?? this.wins,
      losses:
          losses ?? this.losses,
    );
  }

  bool get isProfitable =>
      netProfit > 0;

  bool get hasTrades =>
      totalTrades > 0;

  double get lossRate {
    if ((wins + losses) == 0) {
      return 0;
    }

    return (losses / (wins + losses)) *
        100;
  }

  @override
  String toString() {
    return '''
AccountModel(
Balance : $currentBalance
Profit : $netProfit
Trades : $totalTrades
)
''';
  }
}

/// ===============================================================
/// Snapshot Model
/// ===============================================================

class SnapshotModel {
  final SummaryModel summary;

  final MetricsModel metrics;

  const SnapshotModel({
    required this.summary,
    required this.metrics,
  });

  factory SnapshotModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SnapshotModel(
      summary: SummaryModel.fromJson(
        json["summary"] ?? {},
      ),
      metrics: MetricsModel.fromJson(
        json["metrics"] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "summary": summary.toJson(),
      "metrics": metrics.toJson(),
    };
  }

  SnapshotModel copyWith({
    SummaryModel? summary,
    MetricsModel? metrics,
  }) {
    return SnapshotModel(
      summary: summary ?? this.summary,
      metrics: metrics ?? this.metrics,
    );
  }

  @override
  String toString() {
    return '''
SnapshotModel(
summary: $summary
metrics: $metrics
)
''';
  }
}

/// ===============================================================
/// Summary Model
/// ===============================================================

class SummaryModel {
  final double initialBalance;

  final double currentBalance;

  final double netProfit;

  final double winRate;

  final int totalTrades;

  final int wins;

  final int losses;

  const SummaryModel({
    required this.initialBalance,
    required this.currentBalance,
    required this.netProfit,
    required this.winRate,
    required this.totalTrades,
    required this.wins,
    required this.losses,
  });

  factory SummaryModel.fromJson(
      Map<String, dynamic> json) {
    return SummaryModel(
      initialBalance:
          (json["initial_balance"] ?? 0).toDouble(),

      currentBalance:
          (json["current_balance"] ?? 0).toDouble(),

      netProfit:
          (json["net_profit"] ?? 0).toDouble(),

      winRate:
          (json["win_rate"] ?? 0).toDouble(),

      totalTrades:
          json["total_trades"] ?? 0,

      wins:
          json["wins"] ?? 0,

      losses:
          json["losses"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "initial_balance": initialBalance,
      "current_balance": currentBalance,
      "net_profit": netProfit,
      "win_rate": winRate,
      "total_trades": totalTrades,
      "wins": wins,
      "losses": losses,
    };
  }

  SummaryModel copyWith({
    double? initialBalance,
    double? currentBalance,
    double? netProfit,
    double? winRate,
    int? totalTrades,
    int? wins,
    int? losses,
  }) {
    return SummaryModel(
      initialBalance:
          initialBalance ?? this.initialBalance,
      currentBalance:
          currentBalance ?? this.currentBalance,
      netProfit:
          netProfit ?? this.netProfit,
      winRate:
          winRate ?? this.winRate,
      totalTrades:
          totalTrades ?? this.totalTrades,
      wins:
          wins ?? this.wins,
      losses:
          losses ?? this.losses,
    );
  }

  bool get isProfitable =>
      netProfit > 0;

  bool get hasTrades =>
      totalTrades > 0;

  double get lossRate {
    if ((wins + losses) == 0) {
      return 0;
    }

    return (losses / (wins + losses)) * 100;
  }

  @override
  String toString() {
    return '''
SummaryModel(
Balance : $currentBalance
Profit : $netProfit
Trades : $totalTrades
WinRate : $winRate
)
''';
  }
}
/// ===============================================================
/// Metrics Model
/// ===============================================================

class MetricsModel {
  final double profitFactor;

  final double maxDrawdown;

  final double sharpeRatio;

  final double averageWin;

  final double averageLoss;

  final double riskReward;

  const MetricsModel({
    required this.profitFactor,
    required this.maxDrawdown,
    required this.sharpeRatio,
    required this.averageWin,
    required this.averageLoss,
    required this.riskReward,
  });

  factory MetricsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MetricsModel(
      profitFactor:
          (json["profit_factor"] ?? 0).toDouble(),

      maxDrawdown:
          (json["max_drawdown"] ?? 0).toDouble(),

      sharpeRatio:
          (json["sharpe_ratio"] ?? 0).toDouble(),

      averageWin:
          (json["average_win"] ?? 0).toDouble(),

      averageLoss:
          (json["average_loss"] ?? 0).toDouble(),

      riskReward:
          (json["risk_reward"] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "profit_factor": profitFactor,
      "max_drawdown": maxDrawdown,
      "sharpe_ratio": sharpeRatio,
      "average_win": averageWin,
      "average_loss": averageLoss,
      "risk_reward": riskReward,
    };
  }

  MetricsModel copyWith({
    double? profitFactor,
    double? maxDrawdown,
    double? sharpeRatio,
    double? averageWin,
    double? averageLoss,
    double? riskReward,
  }) {
    return MetricsModel(
      profitFactor:
          profitFactor ?? this.profitFactor,
      maxDrawdown:
          maxDrawdown ?? this.maxDrawdown,
      sharpeRatio:
          sharpeRatio ?? this.sharpeRatio,
      averageWin:
          averageWin ?? this.averageWin,
      averageLoss:
          averageLoss ?? this.averageLoss,
      riskReward:
          riskReward ?? this.riskReward,
    );
  }

  /// ===========================================================
  /// Helper Getters
  /// ===========================================================

  bool get isProfitable =>
      profitFactor >= 1.0;

  bool get hasGoodSharpe =>
      sharpeRatio >= 1.0;

  bool get hasExcellentSharpe =>
      sharpeRatio >= 2.0;

  bool get hasDrawdown =>
      maxDrawdown > 0;

  bool get hasRiskReward =>
      riskReward > 0;

  String get rating {
    if (profitFactor >= 2 &&
        sharpeRatio >= 2) {
      return "Excellent";
    }

    if (profitFactor >= 1.5 &&
        sharpeRatio >= 1.5) {
      return "Very Good";
    }

    if (profitFactor >= 1.2) {
      return "Good";
    }

    if (profitFactor >= 1) {
      return "Average";
    }

    return "Poor";
  }

  @override
  String toString() {
    return '''
MetricsModel(
Profit Factor : $profitFactor
Sharpe Ratio : $sharpeRatio
Max Drawdown : $maxDrawdown
Average Win : $averageWin
Average Loss : $averageLoss
Risk Reward : $riskReward
)
''';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MetricsModel &&
            runtimeType == other.runtimeType &&
            profitFactor == other.profitFactor &&
            maxDrawdown == other.maxDrawdown &&
            sharpeRatio == other.sharpeRatio &&
            averageWin == other.averageWin &&
            averageLoss == other.averageLoss &&
            riskReward == other.riskReward;
  }

  @override
  int get hashCode => Object.hash(
        profitFactor,
        maxDrawdown,
        sharpeRatio,
        averageWin,
        averageLoss,
        riskReward,
      );
}