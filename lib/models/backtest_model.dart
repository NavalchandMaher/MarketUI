import 'dart:convert';

/// ===============================================================
/// Backtest Model
/// Compatible with:
/// GET /backtest
/// GET /backtest/history
/// ===============================================================

class BacktestModel {
  final bool success;

  final String message;

  final BacktestDashboard dashboard;

  const BacktestModel({
    required this.success,
    required this.message,
    required this.dashboard,
  });

  factory BacktestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BacktestModel(
      success: json["success"] ?? false,

      message: json["message"] ?? "",

      dashboard: BacktestDashboard.fromJson(
        json["dashboard"] ?? {},
      ),
    );
  }

  factory BacktestModel.fromRawJson(
    String source,
  ) =>
      BacktestModel.fromJson(
        jsonDecode(source),
      );

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "dashboard": dashboard.toJson(),
    };
  }

  String toRawJson() =>
      jsonEncode(toJson());

  BacktestModel copyWith({
    bool? success,
    String? message,
    BacktestDashboard? dashboard,
  }) {
    return BacktestModel(
      success: success ?? this.success,
      message: message ?? this.message,
      dashboard:
          dashboard ?? this.dashboard,
    );
  }

  bool get isSuccess => success;

  @override
  String toString() {
    return '''
BacktestModel(
success : $success
message : $message
dashboard : $dashboard
)
''';
  }
}

/// ===============================================================
/// Backtest Dashboard
/// ===============================================================

class BacktestDashboard {
  final String symbol;

  final String timeframe;

  final int backtestDays;

  final int totalStrategies;

  final BacktestResult bestStrategy;

  final List<BacktestResult> allResults;

  const BacktestDashboard({
    required this.symbol,
    required this.timeframe,
    required this.backtestDays,
    required this.totalStrategies,
    required this.bestStrategy,
    required this.allResults,
  });

  factory BacktestDashboard.fromJson(
    Map<String, dynamic> json,
  ) {
    return BacktestDashboard(
      symbol: json["symbol"] ?? "",

      timeframe: json["timeframe"] ?? "",

      backtestDays:
          json["backtest_days"] ?? 0,

      totalStrategies:
          json["total_strategies"] ?? 0,

      bestStrategy:
          BacktestResult.fromJson(
        json["best_strategy"] ?? {},
      ),

      allResults:
          (json["all_results"] as List? ?? [])
              .map(
                (e) =>
                    BacktestResult.fromJson(
                  e,
                ),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "symbol": symbol,
      "timeframe": timeframe,
      "backtest_days": backtestDays,
      "total_strategies":
          totalStrategies,
      "best_strategy":
          bestStrategy.toJson(),
      "all_results":
          allResults
              .map((e) => e.toJson())
              .toList(),
    };
  }

  BacktestDashboard copyWith({
    String? symbol,
    String? timeframe,
    int? backtestDays,
    int? totalStrategies,
    BacktestResult? bestStrategy,
    List<BacktestResult>? allResults,
  }) {
    return BacktestDashboard(
      symbol: symbol ?? this.symbol,
      timeframe:
          timeframe ?? this.timeframe,
      backtestDays:
          backtestDays ??
              this.backtestDays,
      totalStrategies:
          totalStrategies ??
              this.totalStrategies,
      bestStrategy:
          bestStrategy ??
              this.bestStrategy,
      allResults:
          allResults ??
              this.allResults,
    );
  }

  bool get hasResults =>
      allResults.isNotEmpty;

  @override
  String toString() {
    return '''
BacktestDashboard(
symbol : $symbol
timeframe : $timeframe
days : $backtestDays
strategies : $totalStrategies
)
''';
  }
}
/// ===============================================================
/// Backtest Result
/// Used by:
/// - best_strategy
/// - all_results
/// - /backtest/history
/// ===============================================================

class BacktestResult {
  final int totalTrades;

  final int wins;

  final int losses;

  final double winRate;

  final double grossProfit;

  final double grossLoss;

  final double netProfit;

  final double profitFactor;

  final double drawdown;

  final double sharpeRatio;

  final double expectancy;

  final String strategyName;

  final int strategyVersion;

  final String symbol;

  final String timeframe;

  final int days;

  final DateTime? createdAt;

  final String id;

  const BacktestResult({
    required this.totalTrades,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.grossProfit,
    required this.grossLoss,
    required this.netProfit,
    required this.profitFactor,
    required this.drawdown,
    required this.sharpeRatio,
    required this.expectancy,
    required this.strategyName,
    required this.strategyVersion,
    required this.symbol,
    required this.timeframe,
    required this.days,
    required this.createdAt,
    required this.id,
  });

  factory BacktestResult.fromJson(
    Map<String, dynamic> json,
  ) {
    return BacktestResult(
      totalTrades: json["total_trades"] ?? 0,

      wins: json["wins"] ?? 0,

      losses: json["losses"] ?? 0,

      winRate:
          (json["win_rate"] ?? 0).toDouble(),

      grossProfit:
          (json["gross_profit"] ?? 0)
              .toDouble(),

      grossLoss:
          (json["gross_loss"] ?? 0)
              .toDouble(),

      netProfit:
          (json["net_profit"] ?? 0)
              .toDouble(),

      profitFactor:
          (json["profit_factor"] ?? 0)
              .toDouble(),

      drawdown:
          (json["drawdown"] ?? 0)
              .toDouble(),

      sharpeRatio:
          (json["sharpe_ratio"] ?? 0)
              .toDouble(),

      expectancy:
          (json["expectancy"] ?? 0)
              .toDouble(),

      strategyName:
          json["strategy_name"] ?? "",

      strategyVersion:
          json["strategy_version"] ?? 1,

      symbol:
          json["symbol"] ?? "",

      timeframe:
          json["timeframe"] ?? "",

      days:
          json["days"] ?? 0,

      createdAt: json["created_at"] != null
          ? DateTime.tryParse(
              json["created_at"],
            )
          : null,

      id: json["_id"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "total_trades": totalTrades,
      "wins": wins,
      "losses": losses,
      "win_rate": winRate,
      "gross_profit": grossProfit,
      "gross_loss": grossLoss,
      "net_profit": netProfit,
      "profit_factor": profitFactor,
      "drawdown": drawdown,
      "sharpe_ratio": sharpeRatio,
      "expectancy": expectancy,
      "strategy_name": strategyName,
      "strategy_version": strategyVersion,
      "symbol": symbol,
      "timeframe": timeframe,
      "days": days,
      "created_at":
          createdAt?.toIso8601String(),
      "_id": id,
    };
  }

  BacktestResult copyWith({
    int? totalTrades,
    int? wins,
    int? losses,
    double? winRate,
    double? grossProfit,
    double? grossLoss,
    double? netProfit,
    double? profitFactor,
    double? drawdown,
    double? sharpeRatio,
    double? expectancy,
    String? strategyName,
    int? strategyVersion,
    String? symbol,
    String? timeframe,
    int? days,
    DateTime? createdAt,
    String? id,
  }) {
    return BacktestResult(
      totalTrades:
          totalTrades ?? this.totalTrades,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      winRate: winRate ?? this.winRate,
      grossProfit:
          grossProfit ?? this.grossProfit,
      grossLoss:
          grossLoss ?? this.grossLoss,
      netProfit:
          netProfit ?? this.netProfit,
      profitFactor:
          profitFactor ?? this.profitFactor,
      drawdown:
          drawdown ?? this.drawdown,
      sharpeRatio:
          sharpeRatio ?? this.sharpeRatio,
      expectancy:
          expectancy ?? this.expectancy,
      strategyName:
          strategyName ?? this.strategyName,
      strategyVersion: strategyVersion ??
          this.strategyVersion,
      symbol: symbol ?? this.symbol,
      timeframe:
          timeframe ?? this.timeframe,
      days: days ?? this.days,
      createdAt:
          createdAt ?? this.createdAt,
      id: id ?? this.id,
    );
  }

  /// ===========================================================
  /// Helper Getters
  /// ===========================================================

  bool get isProfitable => netProfit > 0;

  bool get hasTrades => totalTrades > 0;

  double get lossRate {
    if (totalTrades == 0) return 0;
    return (losses / totalTrades) * 100;
  }

  double get averageProfitPerTrade {
    if (totalTrades == 0) return 0;
    return netProfit / totalTrades;
  }

  String get displayName =>
      "$strategyName v$strategyVersion";

  @override
  String toString() {
    return '''
BacktestResult(
Strategy : $displayName
Trades : $totalTrades
Win Rate : $winRate
Net Profit : $netProfit
Profit Factor : $profitFactor
Sharpe Ratio : $sharpeRatio
)
''';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BacktestResult &&
          runtimeType == other.runtimeType &&
          strategyName == other.strategyName &&
          strategyVersion ==
              other.strategyVersion &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      Object.hash(
        strategyName,
        strategyVersion,
        createdAt,
      );
}

/// ===============================================================
/// Backtest History Model
/// Compatible with GET /backtest/history
/// ===============================================================

class BacktestHistoryModel {
  final List<BacktestResult> history;

  const BacktestHistoryModel({
    required this.history,
  });

  factory BacktestHistoryModel.empty() {
    return const BacktestHistoryModel(
      history: [],
    );
  }

  factory BacktestHistoryModel.fromJson(
    List<dynamic> json,
  ) {
    return BacktestHistoryModel(
      history: json
          .map(
            (e) => BacktestResult.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  factory BacktestHistoryModel.fromRawJson(
    String source,
  ) =>
      BacktestHistoryModel.fromJson(
        jsonDecode(source),
      );

  List<Map<String, dynamic>> toJson() {
    return history
        .map(
          (e) => e.toJson(),
        )
        .toList();
  }

  String toRawJson() =>
      jsonEncode(toJson());

  BacktestHistoryModel copyWith({
    List<BacktestResult>? history,
  }) {
    return BacktestHistoryModel(
      history: history ?? this.history,
    );
  }

  /// ===========================================================
  /// Helper Getters
  /// ===========================================================

  bool get isEmpty => history.isEmpty;

  bool get isNotEmpty => history.isNotEmpty;

  int get totalBacktests => history.length;

  BacktestResult? get latestResult {
    if (history.isEmpty) return null;

    final sorted = [...history];

    sorted.sort(
      (a, b) =>
          (b.createdAt ?? DateTime(1970))
              .compareTo(
        a.createdAt ?? DateTime(1970),
      ),
    );

    return sorted.first;
  }

  BacktestResult? get bestResult {
    if (history.isEmpty) return null;

    final sorted = [...history];

    sorted.sort(
      (a, b) =>
          b.netProfit.compareTo(a.netProfit),
    );

    return sorted.first;
  }

  double get totalNetProfit {
    return history.fold(
      0.0,
      (sum, item) => sum + item.netProfit,
    );
  }

  double get averageWinRate {
    if (history.isEmpty) return 0;

    return history.fold(
          0.0,
          (sum, item) => sum + item.winRate,
        ) /
        history.length;
  }

  double get averageProfitFactor {
    if (history.isEmpty) return 0;

    return history.fold(
          0.0,
          (sum, item) =>
              sum + item.profitFactor,
        ) /
        history.length;
  }

  double get averageSharpe {
    if (history.isEmpty) return 0;

    return history.fold(
          0.0,
          (sum, item) =>
              sum + item.sharpeRatio,
        ) /
        history.length;
  }

  @override
  String toString() {
    return '''
BacktestHistoryModel(
Total Backtests : $totalBacktests
Average Win Rate : ${averageWinRate.toStringAsFixed(2)}%
Average Profit Factor : ${averageProfitFactor.toStringAsFixed(2)}
Average Sharpe : ${averageSharpe.toStringAsFixed(2)}
)
''';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BacktestHistoryModel &&
          runtimeType == other.runtimeType &&
          history == other.history;

  @override
  int get hashCode => history.hashCode;
}