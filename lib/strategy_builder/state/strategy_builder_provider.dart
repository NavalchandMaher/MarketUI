import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/strategy_models.dart';

class StrategyBuilderProvider extends ChangeNotifier {
  StrategyModel _model;

  final Uuid _uuid = const Uuid();

  /// Null = Create Mode
  /// Non-null = Edit Mode
  String? _editingStrategyId;

  StrategyBuilderProvider({StrategyModel? initialStrategy})
    : _model = initialStrategy ?? const StrategyModel();

  StrategyModel get model => _model;

  String? get editingStrategyId => _editingStrategyId;

  bool get isEdit => _editingStrategyId != null;

  void loadTemplate(StrategyModel template) {
    _model = template;
    notifyListeners();
  }

  void loadForEdit({
    required String strategyId,
    required StrategyModel strategy,
  }) {
    _editingStrategyId = strategyId;
    _model = strategy;
    notifyListeners();
  }

  void clear() {
    _editingStrategyId = null;
    _model = const StrategyModel();
    notifyListeners();
  }

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
    bool? isDefault,
    bool? published,
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
      isDefault: isDefault,
      published: published,
    );

    notifyListeners();
  }

  void addCondition({required bool buySide, required Indicator indicator}) {
    final condition = Condition(id: _uuid.v4(), indicator: indicator);

    if (buySide) {
      _model = _model.copyWith(
        buyConditions: [..._model.buyConditions, condition],
      );
    } else {
      _model = _model.copyWith(
        sellConditions: [..._model.sellConditions, condition],
      );
    }

    notifyListeners();
  }

  void updateCondition({required bool buySide, required Condition condition}) {
    if (buySide) {
      final updated = _model.buyConditions
          .map((c) => c.id == condition.id ? condition : c)
          .toList();

      _model = _model.copyWith(buyConditions: updated);
    } else {
      final updated = _model.sellConditions
          .map((c) => c.id == condition.id ? condition : c)
          .toList();

      _model = _model.copyWith(sellConditions: updated);
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

  Map<String, dynamic> toPayload() {
    return {
      "strategy_name": _model.name,
      "description": _model.description,
      "version": 1,
      "enabled": _model.enabled,
      "paper_mode": _model.paperMode,
      "live_mode": _model.liveMode,
      "priority": 1,
      "exchange": _model.exchange,
      "symbol": _model.market,
      "timeframe": _model.timeframe,
      "strategy_type": _model.strategyType,

      "risk_percent": _model.riskSettings.riskPerTrade,
      "tp": _model.riskSettings.rr,
      "sl": 1,
      "is_default": _model.isDefault,
      if (_model.strategyType.toLowerCase() == 'system')
        "published": _model.published,

      "indicator_parameters": {
        "buy_conditions": _model.buyConditions
            .map((condition) => condition.toJson())
            .toList(),

        "sell_conditions": _model.sellConditions
            .map((condition) => condition.toJson())
            .toList(),
      },
    };
  }
}
