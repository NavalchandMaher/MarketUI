
import 'analysis_model.dart';
import 'backtest_model.dart';
import 'paper_trade_model.dart';
import 'performance_model.dart';
import 'scheduler_model.dart';
import 'strategy_model.dart';

/// ===============================================================
/// Dashboard View Model
///
/// This is NOT a backend model.
/// It combines all API responses into one object
/// used by DashboardScreen.
/// ===============================================================

class DashboardModel {
  final AnalysisModel analysis;

  final StrategyModel strategy;

  final PaperTradeModel paperTrade;

  final PerformanceModel performance;

  final BacktestModel? backtest;

  final SchedulerDashboardModel scheduler;

  final DateTime lastUpdated;

  const DashboardModel({
    required this.analysis,
    required this.strategy,
    required this.paperTrade,
    required this.performance,
    required this.scheduler,
    required this.lastUpdated,
    this.backtest,
  });

  DashboardModel copyWith({
    AnalysisModel? analysis,
    StrategyModel? strategy,
    PaperTradeModel? paperTrade,
    PerformanceModel? performance,
    BacktestModel? backtest,
    SchedulerDashboardModel? scheduler,
    DateTime? lastUpdated,
  }) {
    return DashboardModel(
      analysis: analysis ?? this.analysis,
      strategy: strategy ?? this.strategy,
      paperTrade: paperTrade ?? this.paperTrade,
      performance: performance ?? this.performance,
      scheduler: scheduler ?? this.scheduler,
      backtest: backtest ?? this.backtest,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  //==========================================================
  // Market
  //==========================================================

  String get symbol => analysis.symbol;

  String get timeframe => analysis.timeframe;

  double get currentPrice => analysis.price;

  String get signal => analysis.signal;

  int get confidence => analysis.confidence;

  int get score => analysis.score;

  //==========================================================
  // Performance
  //==========================================================

  double get balance =>
      performance.account.currentBalance;

  double get netProfit =>
      performance.account.netProfit;

  double get winRate =>
      performance.account.winRate;

  int get totalTrades =>
      performance.account.totalTrades;

  //==========================================================
  // Paper Trading
  //==========================================================

  int get openTrades =>
      paperTrade.openTrades;

  //==========================================================
  // Strategy
  //==========================================================

  String get strategyName =>
      strategy.displayName;

  //==========================================================
  // Scheduler
  //==========================================================

  bool get schedulerRunning =>
      scheduler.scheduler.running;

  //==========================================================
  // Backtest
  //==========================================================

  bool get hasBacktest =>
      backtest != null;

  double get bestProfit =>
      backtest?.dashboard.bestStrategy.netProfit ??
      0;

  double get bestWinRate =>
      backtest?.dashboard.bestStrategy.winRate ??
      0;

  //==========================================================
  // Dashboard Status
  //==========================================================

  bool get isBullish => analysis.isBuy;

  bool get isBearish => analysis.isSell;

  bool get isWaiting => analysis.isWait;

  bool get isProfitable => netProfit > 0;

  bool get hasOpenTrade => openTrades > 0;

  @override
  String toString() {
    return '''
DashboardModel(
Signal : $signal
Confidence : $confidence
Balance : $balance
Profit : $netProfit
Strategy : $strategyName
)
''';
  }
}