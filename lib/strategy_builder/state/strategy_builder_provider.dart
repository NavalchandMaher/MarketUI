import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/strategy_models.dart';
import '../../services/api_service.dart';

class StrategyBuilderProvider extends ChangeNotifier {
  StrategyModel _model;

  final _uuid = const Uuid();

  StrategyBuilderProvider({StrategyModel? initialStrategy})
    : _model = initialStrategy ?? const StrategyModel();

  StrategyModel get model => _model;

  void updateBasic({
    String? name,
    String? description,
    String? exchange,
    String? market,
    String? timeframe,
    String? strategyType,
    bool? paperMode,
    bool? liveMode,
    bool? enabled,
  }) {
    _model = _model.copyWith(
      name: name,
      description: description,
      exchange: exchange,
      market: market,
      timeframe: timeframe,
      strategyType: strategyType,
      paperMode: paperMode,
      liveMode: liveMode,
      enabled: enabled,
    );
    notifyListeners();
  }

  void addCondition({required bool buySide, required Indicator indicator}) {
    final c = Condition(id: _uuid.v4(), indicator: indicator);
    if (buySide) {
      _model = _model.copyWith(buyConditions: [..._model.buyConditions, c]);
    } else {
      _model = _model.copyWith(sellConditions: [..._model.sellConditions, c]);
    }
    notifyListeners();
  }

  void updateCondition({required bool buySide, required Condition condition}) {
    if (buySide) {
      final list = _model.buyConditions
          .map((c) => c.id == condition.id ? condition : c)
          .toList();
      _model = _model.copyWith(buyConditions: list);
    } else {
      final list = _model.sellConditions
          .map((c) => c.id == condition.id ? condition : c)
          .toList();
      _model = _model.copyWith(sellConditions: list);
    }
    notifyListeners();
  }

  void removeCondition({required bool buySide, required String conditionId}) {
    if (buySide) {
      _model = _model.copyWith(
        buyConditions: _model.buyConditions
            .where((c) => c.id != conditionId)
            .toList(),
      );
    } else {
      _model = _model.copyWith(
        sellConditions: _model.sellConditions
            .where((c) => c.id != conditionId)
            .toList(),
      );
    }
    notifyListeners();
  }

  void reorderConditions({
    required bool buySide,
    required int oldIndex,
    required int newIndex,
  }) {
    final list = [...(buySide ? _model.buyConditions : _model.sellConditions)];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    if (buySide) {
      _model = _model.copyWith(buyConditions: list);
    } else {
      _model = _model.copyWith(sellConditions: list);
    }
    notifyListeners();
  }

  void updateRisk(RiskSettings risk) {
    _model = _model.copyWith(riskSettings: risk);
    notifyListeners();
  }

  void loadTemplate(StrategyModel template) {
    _model = template;
    notifyListeners();
  }

  Map<String, dynamic> toPayload() {
    return {
      "strategy_name": model.name,
      "version": 1,
      "enabled": model.enabled,
      "paper_mode": model.paperMode,
      "live_mode": model.liveMode,
      "priority": 1,
      "symbol": model.market,
      "timeframe": model.timeframe,
      "risk_percent": model.riskSettings.riskPerTrade,
      "tp": model.riskSettings.rr,
      "sl": 1,

      "indicator_parameters": {
        "buy_conditions": model.buyConditions.map((e) => e.toJson()).toList(),

        "sell_conditions": model.sellConditions.map((e) => e.toJson()).toList(),
      },
    };
  }
}
