import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/strategy_model.dart';
import '../../state/backtest_provider.dart';
import '../../state/strategies_provider.dart';

class StrategyBuilderScreen extends StatefulWidget {
  final StrategyModel? strategy;

  const StrategyBuilderScreen({super.key, this.strategy});

  @override
  State<StrategyBuilderScreen> createState() => _StrategyBuilderScreenState();
}

class _StrategyBuilderScreenState extends State<StrategyBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isSaving = false;
  bool _isLoadingDetails = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController(
    text: 'BTCUSDT',
  );
  String _symbol = 'BTCUSDT';
  String _exchange = 'Binance';
  String _timeframe = '5m';
  String _strategyType = 'Intraday';
  String _tradingMode = 'Paper';
  bool _enabled = true;

  List<Map<String, dynamic>> _conditions = [];
  String _conditionLogic = 'AND';

  String _stopLossType = 'Percentage';
  String _takeProfitType = 'Percentage';
  bool _trailingStop = false;
  bool _breakEven = false;
  bool _timeExit = false;
  final TextEditingController _timeExitController = TextEditingController(
    text: '0',
  );

  final TextEditingController _riskPerTradeController = TextEditingController(
    text: '1',
  );
  final TextEditingController _riskRewardController = TextEditingController(
    text: '2.5',
  );
  final TextEditingController _maxOpenTradesController = TextEditingController(
    text: '3',
  );
  String _positionSize = '% of Balance';
  final TextEditingController _maxDailyLossController = TextEditingController(
    text: '5',
  );
  final TextEditingController _maxDailyTradesController = TextEditingController(
    text: '10',
  );

  final TextEditingController _emaFastController = TextEditingController(
    text: '20',
  );
  final TextEditingController _emaSlowController = TextEditingController(
    text: '50',
  );
  final TextEditingController _emaLongController = TextEditingController(
    text: '200',
  );
  final TextEditingController _supertrendAtrController = TextEditingController(
    text: '10',
  );
  final TextEditingController _supertrendMultController = TextEditingController(
    text: '3',
  );
  final TextEditingController _rsiLengthController = TextEditingController(
    text: '14',
  );
  final TextEditingController _rsiBuyController = TextEditingController(
    text: '40',
  );
  final TextEditingController _rsiSellController = TextEditingController(
    text: '65',
  );
  final TextEditingController _macdFastController = TextEditingController(
    text: '12',
  );
  final TextEditingController _macdSlowController = TextEditingController(
    text: '26',
  );
  final TextEditingController _macdSignalController = TextEditingController(
    text: '9',
  );
  final TextEditingController _adxLengthController = TextEditingController(
    text: '14',
  );
  final TextEditingController _atrLengthController = TextEditingController(
    text: '14',
  );
  final TextEditingController _bollLengthController = TextEditingController(
    text: '20',
  );
  final TextEditingController _bollDevController = TextEditingController(
    text: '2',
  );
  bool _vwapEnabled = true;
  final TextEditingController _volumeSmaController = TextEditingController(
    text: '20',
  );
  bool _pivotEnabled = false;

  String _tradingSession = 'All Sessions';
  final TextEditingController _minVolumeController = TextEditingController(
    text: '100000',
  );
  final TextEditingController _minAdxController = TextEditingController(
    text: '25',
  );
  bool _avoidNews = false;
  bool _trendingMarket = false;
  bool _allowLong = true;
  bool _allowShort = true;

  final TextEditingController _confidenceThresholdController =
      TextEditingController(text: '75');
  final TextEditingController _indicatorAgreementController =
      TextEditingController(text: '3');
  bool _enableAiConfirmation = true;
  bool _enableLearning = false;
  bool _autoOptimize = false;

  bool _autoExecutePaper = true;
  final TextEditingController _paperCapitalController = TextEditingController(
    text: '10000',
  );
  final TextEditingController _leverageController = TextEditingController(
    text: '1',
  );
  String _broker = 'Binance';

  DateTimeRange? _backtestRange;
  final TextEditingController _backtestCapitalController =
      TextEditingController(text: '10000');
  final TextEditingController _commissionController = TextEditingController(
    text: '0.1',
  );
  final TextEditingController _slippageController = TextEditingController(
    text: '0.1',
  );

  @override
  void initState() {
    super.initState();
    _loadInitialStrategy();
    if (widget.strategy != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadStrategyDetails();
      });
    }
  }

  void _loadInitialStrategy() {
    if (widget.strategy == null) {
      _conditions = [
        {"indicator": "EMA 20", "operator": ">", "value": "EMA 50"},
      ];
      return;
    }

    _nameController.text = widget.strategy!.name;
    _symbol = 'BTCUSDT';
    _conditions = [
      {"indicator": "EMA 20", "operator": ">", "value": "EMA 50"},
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _symbolController.dispose();
    _timeExitController.dispose();
    _riskPerTradeController.dispose();
    _riskRewardController.dispose();
    _maxOpenTradesController.dispose();
    _maxDailyLossController.dispose();
    _maxDailyTradesController.dispose();
    _emaFastController.dispose();
    _emaSlowController.dispose();
    _emaLongController.dispose();
    _supertrendAtrController.dispose();
    _supertrendMultController.dispose();
    _rsiLengthController.dispose();
    _rsiBuyController.dispose();
    _rsiSellController.dispose();
    _macdFastController.dispose();
    _macdSlowController.dispose();
    _macdSignalController.dispose();
    _adxLengthController.dispose();
    _atrLengthController.dispose();
    _bollLengthController.dispose();
    _bollDevController.dispose();
    _volumeSmaController.dispose();
    _confidenceThresholdController.dispose();
    _indicatorAgreementController.dispose();
    _paperCapitalController.dispose();
    _leverageController.dispose();
    _backtestCapitalController.dispose();
    _commissionController.dispose();
    _slippageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _stepCount - 1) {
      setState(() => _currentStep += 1);
    }
  }

  void _backStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  int get _stepCount => 4;

  void _addCondition() {
    setState(() {
      _conditions.add({
        "indicator": "EMA 20",
        "operator": ">",
        "value": "EMA 50",
      });
    });
  }

  void _removeCondition(int index) {
    setState(() {
      _conditions.removeAt(index);
    });
  }

  Future<void> _pickBacktestRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange:
          _backtestRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
    );
    if (picked != null) {
      setState(() {
        _backtestRange = picked;
      });
    }
  }

  Future<void> _loadStrategyDetails() async {
    final provider = context.read<StrategiesProvider>();
    setState(() => _isLoadingDetails = true);
    try {
      final payload = await provider.getStrategyPayload(widget.strategy!.id);
      _populateFromPayload(payload);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load strategy details: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    }
  }

  void _populateFromPayload(Map<String, dynamic> payload) {
    final indicatorParams = Map<String, dynamic>.from(
      payload['indicator_parameters'] ?? {},
    );
    final entryConditions = indicatorParams['entry_conditions'];
    final exitConditions = Map<String, dynamic>.from(
      indicatorParams['exit_conditions'] ?? {},
    );
    final riskManagement = Map<String, dynamic>.from(
      indicatorParams['risk_management'] ?? {},
    );
    final indicators = Map<String, dynamic>.from(
      indicatorParams['indicators'] ?? {},
    );
    final marketFilters = Map<String, dynamic>.from(
      indicatorParams['market_filters'] ?? {},
    );
    final aiSettings = Map<String, dynamic>.from(
      indicatorParams['ai_settings'] ?? {},
    );
    final paperTrading = Map<String, dynamic>.from(
      indicatorParams['paper_trading'] ?? {},
    );
    final backtesting = Map<String, dynamic>.from(
      indicatorParams['backtesting'] ?? {},
    );

    _nameController.text = payload['strategy_name'] ?? payload['name'] ?? '';
    _descriptionController.text = payload['description'] ?? '';
    _symbol = payload['symbol'] ?? _symbol;
    _exchange = payload['exchange'] ?? _exchange;
    _timeframe = payload['timeframe'] ?? _timeframe;
    _strategyType = payload['strategy_type'] ?? _strategyType;
    _enabled = payload['enabled'] ?? _enabled;

    final paperMode = payload['paper_mode'];
    final liveMode = payload['live_mode'];
    if (paperMode == true && liveMode == true) {
      _tradingMode = 'Both';
    } else if (liveMode == true) {
      _tradingMode = 'Live';
    } else {
      _tradingMode = 'Paper';
    }

    _riskPerTradeController.text =
        (payload['risk_percent'] ??
                riskManagement['risk_per_trade'] ??
                _riskPerTradeController.text)
            .toString();
    final ratio =
        riskManagement['risk_reward_ratio'] ??
        ((payload['tp'] != null && payload['sl'] != null && payload['sl'] != 0)
            ? (payload['tp'] / payload['sl'])
            : null);
    _riskRewardController.text = (ratio ?? _riskRewardController.text)
        .toString();
    _maxOpenTradesController.text =
        (riskManagement['max_open_trades'] ?? _maxOpenTradesController.text)
            .toString();
    _positionSize = riskManagement['position_size'] ?? _positionSize;
    _maxDailyLossController.text =
        (riskManagement['max_daily_loss'] ?? _maxDailyLossController.text)
            .toString();
    _maxDailyTradesController.text =
        (riskManagement['max_daily_trades'] ?? _maxDailyTradesController.text)
            .toString();

    _conditions = [];
    if (entryConditions is List) {
      for (final item in entryConditions) {
        if (item is Map) {
          _conditions.add(Map<String, dynamic>.from(item));
        }
      }
    }
    if (_conditions.isEmpty) {
      _conditions = [
        {"indicator": "EMA 20", "operator": ">", "value": "EMA 50"},
      ];
    }
    _conditionLogic = indicatorParams['condition_logic'] ?? _conditionLogic;

    _stopLossType = exitConditions['stop_loss'] ?? _stopLossType;
    _takeProfitType = exitConditions['take_profit'] ?? _takeProfitType;
    _trailingStop = exitConditions['trailing_stop'] ?? _trailingStop;
    _breakEven = exitConditions['break_even'] ?? _breakEven;
    _timeExit = exitConditions['time_based_exit'] ?? _timeExit;
    _timeExitController.text =
        (exitConditions['exit_delay_minutes'] ?? _timeExitController.text)
            .toString();

    _emaFastController.text =
        (indicators['ema_fast'] ?? _emaFastController.text).toString();
    _emaSlowController.text =
        (indicators['ema_slow'] ?? _emaSlowController.text).toString();
    _emaLongController.text =
        (indicators['ema_long'] ?? _emaLongController.text).toString();
    _supertrendAtrController.text =
        (indicators['supertrend_atr_length'] ?? _supertrendAtrController.text)
            .toString();
    _supertrendMultController.text =
        (indicators['supertrend_multiplier'] ?? _supertrendMultController.text)
            .toString();
    _rsiLengthController.text =
        (indicators['rsi_length'] ?? _rsiLengthController.text).toString();
    _rsiBuyController.text = (indicators['rsi_buy'] ?? _rsiBuyController.text)
        .toString();
    _rsiSellController.text =
        (indicators['rsi_sell'] ?? _rsiSellController.text).toString();
    _macdFastController.text =
        (indicators['macd_fast'] ?? _macdFastController.text).toString();
    _macdSlowController.text =
        (indicators['macd_slow'] ?? _macdSlowController.text).toString();
    _macdSignalController.text =
        (indicators['macd_signal'] ?? _macdSignalController.text).toString();
    _adxLengthController.text =
        (indicators['adx_length'] ?? _adxLengthController.text).toString();
    _atrLengthController.text =
        (indicators['atr_length'] ?? _atrLengthController.text).toString();
    _bollLengthController.text =
        (indicators['bollinger_length'] ?? _bollLengthController.text)
            .toString();
    _bollDevController.text =
        (indicators['bollinger_deviation'] ?? _bollDevController.text)
            .toString();
    _vwapEnabled = indicators['vwap_enabled'] ?? _vwapEnabled;
    _volumeSmaController.text =
        (indicators['volume_sma_length'] ?? _volumeSmaController.text)
            .toString();
    _pivotEnabled = indicators['pivot_enabled'] ?? _pivotEnabled;

    _tradingSession = marketFilters['session'] ?? _tradingSession;
    _minVolumeController.text =
        (marketFilters['min_volume'] ?? _minVolumeController.text).toString();
    _minAdxController.text =
        (marketFilters['min_adx'] ?? _minAdxController.text).toString();
    _avoidNews = marketFilters['avoid_news'] ?? _avoidNews;
    _trendingMarket = marketFilters['trending_market'] ?? _trendingMarket;
    _allowLong = marketFilters['allow_long'] ?? _allowLong;
    _allowShort = marketFilters['allow_short'] ?? _allowShort;

    _confidenceThresholdController.text =
        (aiSettings['confidence_threshold'] ??
                _confidenceThresholdController.text)
            .toString();
    _indicatorAgreementController.text =
        (aiSettings['minimum_indicator_agreement'] ??
                _indicatorAgreementController.text)
            .toString();
    _enableAiConfirmation =
        aiSettings['enable_ai_confirmation'] ?? _enableAiConfirmation;
    _enableLearning = aiSettings['enable_learning'] ?? _enableLearning;
    _autoOptimize = aiSettings['auto_optimize'] ?? _autoOptimize;

    _autoExecutePaper = paperTrading['auto_execute'] ?? _autoExecutePaper;
    _paperCapitalController.text =
        (paperTrading['initial_capital'] ?? _paperCapitalController.text)
            .toString();
    _leverageController.text =
        (paperTrading['leverage'] ?? _leverageController.text).toString();
    _broker = paperTrading['broker'] ?? _broker;

    _backtestCapitalController.text =
        (backtesting['initial_capital'] ?? _backtestCapitalController.text)
            .toString();
    _commissionController.text =
        (backtesting['commission'] ?? _commissionController.text).toString();
    _slippageController.text =
        (backtesting['slippage'] ?? _slippageController.text).toString();

    final dateRange = backtesting['date_range'];
    if (dateRange is Map) {
      final start = DateTime.tryParse(dateRange['start'] ?? '');
      final end = DateTime.tryParse(dateRange['end'] ?? '');
      if (start != null && end != null) {
        _backtestRange = DateTimeRange(start: start, end: end);
      }
    }

    setState(() {});
  }

  Map<String, dynamic> get _strategyPayload {
    return {
      "strategy_name": _nameController.text.trim(),
      "description": _descriptionController.text.trim(),
      "symbol": _symbol,
      "exchange": _exchange,
      "timeframe": _timeframe,
      "strategy_type": _strategyType,
      "paper_mode": _tradingMode != 'Live',
      "live_mode": _tradingMode != 'Paper',
      "enabled": _enabled,
      "risk_percent": double.tryParse(_riskPerTradeController.text) ?? 1.0,
      "tp": _takeProfitType == 'Fixed Price'
          ? 0
          : double.tryParse(_riskRewardController.text) ?? 2.5,
      "sl": double.tryParse(_riskPerTradeController.text) ?? 1.0,
      "indicator_parameters": {
        "entry_conditions": _conditions,
        "condition_logic": _conditionLogic,
        "exit_conditions": {
          "stop_loss": _stopLossType,
          "take_profit": _takeProfitType,
          "trailing_stop": _trailingStop,
          "break_even": _breakEven,
          "time_based_exit": _timeExit,
          "exit_delay_minutes": int.tryParse(_timeExitController.text) ?? 0,
        },
        "risk_management": {
          "risk_per_trade":
              double.tryParse(_riskPerTradeController.text) ?? 1.0,
          "risk_reward_ratio":
              double.tryParse(_riskRewardController.text) ?? 2.5,
          "max_open_trades": int.tryParse(_maxOpenTradesController.text) ?? 3,
          "position_size": _positionSize,
          "max_daily_loss":
              double.tryParse(_maxDailyLossController.text) ?? 5.0,
          "max_daily_trades":
              int.tryParse(_maxDailyTradesController.text) ?? 10,
        },
        "indicators": {
          "ema_fast": int.tryParse(_emaFastController.text) ?? 20,
          "ema_slow": int.tryParse(_emaSlowController.text) ?? 50,
          "ema_long": int.tryParse(_emaLongController.text) ?? 200,
          "supertrend_atr_length":
              int.tryParse(_supertrendAtrController.text) ?? 10,
          "supertrend_multiplier":
              int.tryParse(_supertrendMultController.text) ?? 3,
          "rsi_length": int.tryParse(_rsiLengthController.text) ?? 14,
          "rsi_buy": int.tryParse(_rsiBuyController.text) ?? 40,
          "rsi_sell": int.tryParse(_rsiSellController.text) ?? 65,
          "macd_fast": int.tryParse(_macdFastController.text) ?? 12,
          "macd_slow": int.tryParse(_macdSlowController.text) ?? 26,
          "macd_signal": int.tryParse(_macdSignalController.text) ?? 9,
          "adx_length": int.tryParse(_adxLengthController.text) ?? 14,
          "atr_length": int.tryParse(_atrLengthController.text) ?? 14,
          "bollinger_length": int.tryParse(_bollLengthController.text) ?? 20,
          "bollinger_deviation":
              double.tryParse(_bollDevController.text) ?? 2.0,
          "vwap_enabled": _vwapEnabled,
          "volume_sma_length": int.tryParse(_volumeSmaController.text) ?? 20,
          "pivot_enabled": _pivotEnabled,
        },
        "market_filters": {
          "session": _tradingSession,
          "min_volume": int.tryParse(_minVolumeController.text) ?? 100000,
          "min_adx": int.tryParse(_minAdxController.text) ?? 25,
          "avoid_news": _avoidNews,
          "trending_market": _trendingMarket,
          "allow_long": _allowLong,
          "allow_short": _allowShort,
        },
        "ai_settings": {
          "confidence_threshold":
              int.tryParse(_confidenceThresholdController.text) ?? 75,
          "minimum_indicator_agreement":
              int.tryParse(_indicatorAgreementController.text) ?? 3,
          "enable_ai_confirmation": _enableAiConfirmation,
          "enable_learning": _enableLearning,
          "auto_optimize": _autoOptimize,
        },
        "paper_trading": {
          "auto_execute": _autoExecutePaper,
          "initial_capital":
              double.tryParse(_paperCapitalController.text) ?? 10000,
          "leverage": int.tryParse(_leverageController.text) ?? 1,
          "broker": _broker,
        },
        "backtesting": {
          "date_range": _backtestRange == null
              ? null
              : {
                  "start": _backtestRange!.start.toIso8601String(),
                  "end": _backtestRange!.end.toIso8601String(),
                },
          "initial_capital":
              double.tryParse(_backtestCapitalController.text) ?? 10000,
          "commission": double.tryParse(_commissionController.text) ?? 0.1,
          "slippage": double.tryParse(_slippageController.text) ?? 0.1,
        },
      },
    };
  }

  Future<void> _saveStrategy({bool runBacktest = false}) async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _currentStep = 0);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = context.read<StrategiesProvider>();
    final payload = _strategyPayload;

    setState(() => _isSaving = true);
    final success = widget.strategy == null
        ? await provider.createStrategyFromPayload(payload)
        : await provider.updateStrategyFromPayload(
            widget.strategy!.id,
            payload,
          );
    if (!mounted) return;

    setState(() => _isSaving = false);
    if (!success) return;

    if (runBacktest) {
      if (_backtestRange == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Please select a backtest date range before running backtest.',
            ),
          ),
        );
      } else {
        final backtestProvider = context.read<BacktestProvider>();
        final backtestSuccess = await backtestProvider.runBacktest(
          strategyName: _nameController.text.trim(),
          symbol: _symbol,
          timeframe: _timeframe,
          startDate: _backtestRange!.start,
          endDate: _backtestRange!.end,
          initialCapital:
              double.tryParse(_backtestCapitalController.text) ?? 10000,
        );

        messenger.showSnackBar(
          SnackBar(
            content: Text(
              backtestSuccess
                  ? 'Strategy saved and backtest completed'
                  : 'Strategy saved but backtest failed: ${backtestProvider.errorMessage ?? 'unknown'}',
            ),
          ),
        );
      }
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            widget.strategy == null ? 'Strategy saved' : 'Strategy updated',
          ),
        ),
      );
    }

    navigator.pop();
  }

  Widget _buildSectionHeader(String title, IconData icon, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTooltipLabel(String label, String tooltip) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 6),
        Tooltip(
          message: tooltip,
          child: const Icon(Icons.info_outline, size: 16),
        ),
      ],
    );
  }

  Widget _buildStepHeader() {
    final theme = Theme.of(context);
    final titles = ['Basic', 'Conditions', 'Risk', 'Review'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: List.generate(titles.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Expanded(
              child: Container(
                height: 1,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.35),
              ),
            );
          }
          final stepIndex = index ~/ 2;
          final active = stepIndex == _currentStep;
          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: active
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${stepIndex + 1}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: active
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  titles[stepIndex],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: active
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInputTile({
    required String label,
    required Widget child,
    String? tooltip,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tooltip != null)
            _buildTooltipLabel(label, tooltip)
          else
            Text(label),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildConditionsSection() {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.rule, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Entry Conditions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    ToggleButtons(
                      isSelected: [
                        _conditionLogic == 'AND',
                        _conditionLogic == 'OR',
                      ],
                      onPressed: (index) => setState(
                        () => _conditionLogic = index == 0 ? 'AND' : 'OR',
                      ),
                      borderRadius: BorderRadius.circular(8),
                      children: const [
                        Text('AND'),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('OR'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ..._conditions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final condition = entry.value;
                  return _buildConditionTile(index, condition);
                }).toList(),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Condition'),
                    onPressed: _addCondition,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.directions_run, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Exit Conditions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputTile(
                        label: 'Stop Loss',
                        child: DropdownButtonFormField<String>(
                          value: _stopLossType,
                          items: ['Percentage', 'ATR', 'Fixed Price']
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _stopLossType = value);
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputTile(
                        label: 'Take Profit',
                        child: DropdownButtonFormField<String>(
                          value: _takeProfitType,
                          items: ['Percentage', 'ATR', 'Fixed Price']
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _takeProfitType = value);
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: _trailingStop,
                  onChanged: (value) => setState(() => _trailingStop = value),
                  title: const Text('Trailing Stop'),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  value: _breakEven,
                  onChanged: (value) => setState(() => _breakEven = value),
                  title: const Text('Break Even'),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  value: _timeExit,
                  onChanged: (value) => setState(() => _timeExit = value),
                  title: const Text('Time Based Exit'),
                  contentPadding: EdgeInsets.zero,
                ),
                if (_timeExit)
                  _buildInputTile(
                    label: 'Exit After (minutes)',
                    child: TextFormField(
                      controller: _timeExitController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConditionTile(int index, Map<String, dynamic> condition) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: condition['indicator'] as String,
                  items:
                      [
                            'EMA 20',
                            'EMA 50',
                            'EMA 200',
                            'RSI',
                            'MACD',
                            'Supertrend',
                            'ADX',
                            'Price',
                            'Volume',
                            'VWAP',
                            'ATR',
                          ]
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                  decoration: const InputDecoration(labelText: 'Indicator'),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _conditions[index]['indicator'] = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: condition['operator'] as String,
                  items: ['>', '<', '>=', '<=', '=', 'Crosses', 'Breaks']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  decoration: const InputDecoration(labelText: 'Operator'),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _conditions[index]['operator'] = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                TextFormField(
                  initialValue: condition['value'] as String,
                  decoration: const InputDecoration(labelText: 'Value'),
                  onChanged: (value) => _conditions[index]['value'] = value,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Enter a value' : null,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Remove condition',
                    onPressed: () => _removeCondition(index),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    late Widget content;
    switch (_currentStep) {
      case 0:
        content = _buildBasicSection();
        break;
      case 1:
        content = _buildConditionsSection();
        break;
      case 2:
        content = _buildRiskSection();
        break;
      case 3:
        content = _buildBacktestSection();
        break;
      default:
        content = _buildReviewSection();
        break;
    }

    return KeyedSubtree(
      key: ValueKey<int>(_currentStep),
      child: SizedBox(width: double.infinity, child: content),
    );
  }

  Widget _buildBasicSection() {
    return Column(
      children: [
        _buildSectionHeader(
          'Basic Information',
          Icons.layers,
          'Define the strategy core and market context',
        ),
        _buildInputTile(
          label: 'Strategy Name',
          tooltip: 'Give your trading strategy a memorable name',
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            validator: (value) => value?.trim().isEmpty == true
                ? 'Strategy Name is required'
                : null,
          ),
        ),
        _buildInputTile(
          label: 'Description (optional)',
          child: TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            maxLines: 3,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildInputTile(
                label: 'Symbol',
                tooltip: 'Search or type the symbol used for the strategy',
                child: TextFormField(
                  controller: _symbolController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() => _symbol = value.toUpperCase());
                  },
                  validator: (value) => value?.trim().isEmpty == true
                      ? 'Symbol is required'
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInputTile(
                label: 'Exchange',
                child: DropdownButtonFormField<String>(
                  value: _exchange,
                  items: ['Binance', 'Bybit', 'Kraken', 'Coinbase']
                      .map(
                        (exchange) => DropdownMenuItem(
                          value: exchange,
                          child: Text(exchange),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _exchange = value);
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildInputTile(
                label: 'Timeframe',
                child: DropdownButtonFormField<String>(
                  value: _timeframe,
                  items: ['1m', '5m', '15m', '1h', '4h', '1d']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _timeframe = value);
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInputTile(
                label: 'Strategy Type',
                child: DropdownButtonFormField<String>(
                  value: _strategyType,
                  items: ['Scalping', 'Intraday', 'Swing', 'Positional']
                      .map(
                        (value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _strategyType = value);
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildInputTile(
          label: 'Trading Mode',
          child: ToggleButtons(
            isSelected: [
              _tradingMode == 'Paper',
              _tradingMode == 'Live',
              _tradingMode == 'Both',
            ],
            onPressed: (index) {
              setState(() {
                _tradingMode = ['Paper', 'Live', 'Both'][index];
              });
            },
            borderRadius: BorderRadius.circular(8),
            selectedColor: Theme.of(context).colorScheme.onPrimary,
            fillColor: Theme.of(context).colorScheme.primary,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Paper'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Live'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Both'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildInputTile(
          label: 'Enable Strategy',
          child: SwitchListTile(
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
            title: const Text('Turn on to activate this strategy'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Presets',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildPresetButton('Scalping'),
                    _buildPresetButton('Intraday'),
                    _buildPresetButton('Swing'),
                    _buildPresetButton('Position'),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Use EMA Supertrend'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          'Risk Management',
          Icons.shield,
          'Protect capital and control trade sizing',
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInputTile(
                        label: 'Risk Per Trade %',
                        tooltip:
                            'How much of the account you risk on each trade',
                        child: TextFormField(
                          controller: _riskPerTradeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Required'
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputTile(
                        label: 'Risk Reward Ratio',
                        tooltip: 'Target reward relative to risk',
                        child: TextFormField(
                          controller: _riskRewardController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputTile(
                        label: 'Max Open Trades',
                        child: TextFormField(
                          controller: _maxOpenTradesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputTile(
                        label: 'Position Size',
                        child: DropdownButtonFormField<String>(
                          value: _positionSize,
                          items: ['% of Balance', 'Fixed Quantity']
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null)
                              setState(() => _positionSize = value);
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputTile(
                        label: 'Max Daily Loss %',
                        child: TextFormField(
                          controller: _maxDailyLossController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputTile(
                        label: 'Max Daily Trades',
                        child: TextFormField(
                          controller: _maxDailyTradesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bar_chart, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Indicators & Parameters',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputTile(
                        label: 'EMA Fast (20)',
                        child: TextFormField(
                          controller: _emaFastController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputTile(
                        label: 'EMA Slow (50)',
                        child: TextFormField(
                          controller: _emaSlowController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputTile(
                        label: 'EMA Long (200)',
                        child: TextFormField(
                          controller: _emaLongController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputTile(
                        label: 'Supertrend ATR',
                        child: TextFormField(
                          controller: _supertrendAtrController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputTile(
                        label: 'Supertrend Multiplier',
                        child: TextFormField(
                          controller: _supertrendMultController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputTile(
                        label: 'RSI Length',
                        child: TextFormField(
                          controller: _rsiLengthController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBacktestSection() {
    return Column(
      children: [
        _buildSectionHeader(
          'Backtesting',
          Icons.timeline,
          'Simulate performance using real market ranges',
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTooltipLabel(
                  'Date Range',
                  'Choose a historical range for backtesting',
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _pickBacktestRange,
                  child: Text(
                    _backtestRange == null
                        ? 'Choose date range'
                        : '${_backtestRange!.start.toLocal().toIso8601String().split('T').first} – ${_backtestRange!.end.toLocal().toIso8601String().split('T').first}',
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputTile(
                  label: 'Initial Capital (USDT)',
                  child: TextFormField(
                    controller: _backtestCapitalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputTile(
                        label: 'Commission %',
                        child: TextFormField(
                          controller: _commissionController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputTile(
                        label: 'Slippage %',
                        child: TextFormField(
                          controller: _slippageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          'Review Strategy',
          Icons.task_alt,
          'Verify the key details before publishing',
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Strategy Summary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildReviewChip('Name', _nameController.text),
                _buildReviewChip('Symbol', _symbol),
                _buildReviewChip('Exchange', _exchange),
                _buildReviewChip('Timeframe', _timeframe),
                _buildReviewChip('Mode', _tradingMode),
                const Divider(height: 24),
                Text(
                  'Entry Rules',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                ..._conditions.map(
                  (condition) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${condition['indicator']} ${condition['operator']} ${condition['value']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                const Divider(height: 24),
                Text(
                  'Risk Rules',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildReviewChip('Risk %', _riskPerTradeController.text),
                    _buildReviewChip('RRR', _riskRewardController.text),
                    _buildReviewChip(
                      'Max Trades',
                      _maxOpenTradesController.text,
                    ),
                    _buildReviewChip(
                      'Daily Loss',
                      _maxDailyLossController.text,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewChip(String label, String value) {
    return Chip(
      avatar: CircleAvatar(child: Text(label[0])),
      label: Text('$label: $value'),
    );
  }

  Widget _buildPresetButton(String label) {
    return OutlinedButton(
      onPressed: () {
        // TODO: wire presets to load template values
      },
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.strategy == null
              ? 'New Strategy Builder'
              : 'Edit Strategy Builder',
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      children: [
                        _buildStepHeader(),
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          layoutBuilder: (currentChild, previousChildren) {
                            return Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                ...previousChildren,
                                if (currentChild != null) currentChild,
                              ],
                            );
                          },
                          child: _buildStepContent(),
                        ),
                        const SizedBox(height: 96),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoadingDetails)
              Container(
                color: Colors.black.withOpacity(0.35),
                alignment: Alignment.center,
                child: const CircularProgressIndicator.adaptive(),
              ),
          ],
        ),
      ),
      bottomSheet: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          child: Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : _backStep,
                    child: const Text('Back'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              if (_currentStep == _stepCount - 1) ...[
                Expanded(
                  child: FilledButton(
                    onPressed: _isSaving
                        ? null
                        : () => _saveStrategy(runBacktest: false),
                    child: _isSaving
                        ? const CircularProgressIndicator.adaptive()
                        : const Text('Create Strategy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () => _saveStrategy(runBacktest: true),
                    child: _isSaving
                        ? const CircularProgressIndicator.adaptive()
                        : const Text('Save & Backtest'),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: FilledButton(
                    onPressed: _isSaving ? null : _nextStep,
                    child: _isSaving
                        ? const CircularProgressIndicator.adaptive()
                        : const Text('Next'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
