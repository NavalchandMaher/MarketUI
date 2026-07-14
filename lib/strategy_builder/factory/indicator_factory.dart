import 'package:flutter/material.dart';

import '../models/indicator_definition.dart';

class IndicatorFactory {
  IndicatorFactory._();

  static IndicatorDefinition? findById(String id) {
    try {
      return indicators.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  static final List<IndicatorDefinition> indicators = [
    // ==========================================================
    // EMA
    // ==========================================================
    IndicatorDefinition(
      id: "ema",
      name: "EMA",
      category: "Trend",
      icon: Icons.show_chart,
      fields: [
        IndicatorField(
          key: "fast",
          label: "Fast EMA",
          type: IndicatorFieldType.number,
          defaultValue: 20,
        ),

        IndicatorField(
          key: "slow",
          label: "Slow EMA",
          type: IndicatorFieldType.number,
          defaultValue: 50,
        ),

        IndicatorField(
          key: "source",
          label: "Price Source",
          type: IndicatorFieldType.dropdown,
          defaultValue: "Close",
          options: const [
            "Open",
            "High",
            "Low",
            "Close",
            "HL2",
            "HLC3",
            "OHLC4",
          ],
        ),

        IndicatorField(
          key: "condition",
          label: "Condition",
          type: IndicatorFieldType.dropdown,
          defaultValue: "Bullish Cross",
          options: const [
            "Bullish Cross",
            "Bearish Cross",
            "Above",
            "Below",
            "Cross Above",
            "Cross Below",
          ],
        ),
      ],
    ),

    // ==========================================================
    // RSI
    // ==========================================================
    IndicatorDefinition(
      id: "rsi",
      name: "RSI",
      category: "Momentum",
      icon: Icons.speed,
      fields: [
        IndicatorField(
          key: "length",
          label: "RSI Length",
          type: IndicatorFieldType.number,
          defaultValue: 14,
        ),

        IndicatorField(
          key: "overbought",
          label: "Overbought",
          type: IndicatorFieldType.number,
          defaultValue: 70,
        ),

        IndicatorField(
          key: "oversold",
          label: "Oversold",
          type: IndicatorFieldType.number,
          defaultValue: 30,
        ),

        IndicatorField(
          key: "condition",
          label: "Condition",
          type: IndicatorFieldType.dropdown,
          defaultValue: "Greater Than",
          options: const [
            "Greater Than",
            "Less Than",
            "Cross Above",
            "Cross Below",
            "Overbought",
            "Oversold",
          ],
        ),

        IndicatorField(
          key: "value",
          label: "Compare Value",
          type: IndicatorFieldType.number,
          defaultValue: 50,
        ),
      ],
    ),

    // ==========================================================
    // MACD
    // ==========================================================
    IndicatorDefinition(
      id: "macd",
      name: "MACD",
      category: "Momentum",
      icon: Icons.stacked_line_chart,
      fields: [
        IndicatorField(
          key: "fast",
          label: "Fast EMA",
          type: IndicatorFieldType.number,
          defaultValue: 12,
        ),

        IndicatorField(
          key: "slow",
          label: "Slow EMA",
          type: IndicatorFieldType.number,
          defaultValue: 26,
        ),

        IndicatorField(
          key: "signal",
          label: "Signal",
          type: IndicatorFieldType.number,
          defaultValue: 9,
        ),

        IndicatorField(
          key: "condition",
          label: "Condition",
          type: IndicatorFieldType.dropdown,
          defaultValue: "Bullish Cross",
          options: const [
            "Bullish Cross",
            "Bearish Cross",
            "Histogram > 0",
            "Histogram < 0",
            "MACD Above Signal",
            "MACD Below Signal",
          ],
        ),
      ],
    ),

    // ==========================================================
    // SUPERTREND
    // ==========================================================
    IndicatorDefinition(
      id: "supertrend",
      name: "Supertrend",
      category: "Trend",
      icon: Icons.trending_up,
      fields: [
        IndicatorField(
          key: "atrLength",
          label: "ATR Length",
          type: IndicatorFieldType.number,
          defaultValue: 10,
        ),

        IndicatorField(
          key: "multiplier",
          label: "Multiplier",
          type: IndicatorFieldType.decimal,
          defaultValue: 3.0,
        ),

        IndicatorField(
          key: "condition",
          label: "Condition",
          type: IndicatorFieldType.dropdown,
          defaultValue: "Trend Up",
          options: const [
            "Trend Up",
            "Trend Down",
            "Trend Change",
            "Price Above Supertrend",
            "Price Below Supertrend",
          ],
        ),
      ],
    ),

    // ==========================================================
    // VWAP
    // ==========================================================
    IndicatorDefinition(
      id: "vwap",
      name: "VWAP",
      category: "Volume",
      icon: Icons.bar_chart,
      fields: [
        IndicatorField(
          key: "source",
          label: "Price Source",
          type: IndicatorFieldType.dropdown,
          defaultValue: "Close",
          options: const [
            "Open",
            "High",
            "Low",
            "Close",
            "HL2",
            "HLC3",
            "OHLC4",
          ],
        ),

        IndicatorField(
          key: "condition",
          label: "Condition",
          type: IndicatorFieldType.dropdown,
          defaultValue: "Above VWAP",
          options: const [
            "Above VWAP",
            "Below VWAP",
            "Cross Above",
            "Cross Below",
            "Touch VWAP",
          ],
        ),
      ],
    ),

    // ==========================================================
    // ATR
    // ==========================================================
    IndicatorDefinition(
      id: "atr",
      name: "ATR",
      category: "Volatility",
      icon: Icons.multiline_chart,
      fields: [
        IndicatorField(
          key: "length",
          label: "ATR Length",
          type: IndicatorFieldType.number,
          defaultValue: 14,
        ),

        IndicatorField(
          key: "condition",
          label: "Condition",
          type: IndicatorFieldType.dropdown,
          defaultValue: "ATR >",
          options: const [
            "ATR >",
            "ATR <",
            "ATR Increasing",
            "ATR Decreasing",
            "ATR Rising",
            "ATR Falling",
          ],
        ),

        IndicatorField(
          key: "value",
          label: "ATR Value",
          type: IndicatorFieldType.decimal,
          defaultValue: 2.0,
        ),
      ],
    ),

    // ==========================================================
    // BOLLINGER BANDS
    // ==========================================================
    IndicatorDefinition(
      id: "bollinger",
      name: "Bollinger Bands",
      category: "Volatility",
      icon: Icons.blur_on,
      fields: [
        IndicatorField(
          key: "length",
          label: "Length",
          type: IndicatorFieldType.number,
          defaultValue: 20,
        ),

        IndicatorField(
          key: "deviation",
          label: "Deviation",
          type: IndicatorFieldType.decimal,
          defaultValue: 2.0,
        ),

        IndicatorField(
          key: "source",
          label: "Price Source",
          type: IndicatorFieldType.dropdown,
          defaultValue: "Close",
          options: const [
            "Open",
            "High",
            "Low",
            "Close",
            "HL2",
            "HLC3",
            "OHLC4",
          ],
        ),

        IndicatorField(
          key: "condition",
          label: "Condition",
          type: IndicatorFieldType.dropdown,
          defaultValue: "Upper Breakout",
          options: const [
            "Upper Breakout",
            "Lower Breakout",
            "Touch Upper Band",
            "Touch Lower Band",
            "Band Squeeze",
            "Band Expansion",
            "Price Above Upper",
            "Price Below Lower",
          ],
        ),
      ],
    ),

    // ==========================================================
    // ADX
    // ==========================================================
    IndicatorDefinition(
      id: "adx",
      name: "ADX",
      category: "Trend",
      icon: Icons.analytics_outlined,
      fields: [
        IndicatorField(
          key: "length",
          label: "ADX Length",
          type: IndicatorFieldType.number,
          defaultValue: 14,
        ),

        IndicatorField(
          key: "condition",
          label: "Condition",
          type: IndicatorFieldType.dropdown,
          defaultValue: "ADX >",
          options: const [
            "ADX >",
            "ADX <",
            "Strong Trend",
            "Weak Trend",
            "+DI Cross",
            "-DI Cross",
          ],
        ),

        IndicatorField(
          key: "value",
          label: "ADX Value",
          type: IndicatorFieldType.number,
          defaultValue: 25,
        ),
      ],
    ),

    // ==========================================================
    // STOCHASTIC
    // ==========================================================
    IndicatorDefinition(
      id: "stochastic",
      name: "Stochastic",
      category: "Momentum",
      icon: Icons.timeline,
      fields: [
        IndicatorField(
          key: "kPeriod",
          label: "%K Period",
          type: IndicatorFieldType.number,
          defaultValue: 14,
        ),

        IndicatorField(
          key: "dPeriod",
          label: "%D Period",
          type: IndicatorFieldType.number,
          defaultValue: 3,
        ),

        IndicatorField(
          key: "condition",
          label: "Condition",
          type: IndicatorFieldType.dropdown,
          defaultValue: "Bullish Cross",
          options: const [
            "Bullish Cross",
            "Bearish Cross",
            "Overbought",
            "Oversold",
          ],
        ),
      ],
    ),

    // ==========================================================
    // CCI
    // ==========================================================
    IndicatorDefinition(
      id: "cci",
      name: "CCI",
      category: "Momentum",
      icon: Icons.equalizer,
      fields: [
        IndicatorField(
          key: "length",
          label: "CCI Length",
          type: IndicatorFieldType.number,
          defaultValue: 20,
        ),

        IndicatorField(
          key: "condition",
          label: "Condition",
          type: IndicatorFieldType.dropdown,
          defaultValue: "Above 100",
          options: const [
            "Above 100",
            "Below -100",
            "Cross Above",
            "Cross Below",
          ],
        ),
      ],
    ),

    // ==========================================================
    // OBV
    // ==========================================================
    IndicatorDefinition(
      id: "obv",
      name: "On Balance Volume",
      category: "Volume",
      icon: Icons.waterfall_chart,
      fields: [
        IndicatorField(
          key: "condition",
          label: "Condition",
          type: IndicatorFieldType.dropdown,
          defaultValue: "OBV Rising",
          options: const [
            "OBV Rising",
            "OBV Falling",
            "Bullish Divergence",
            "Bearish Divergence",
          ],
        ),
      ],
    ),

    // ==========================================================
    // PIVOT POINTS
    // ==========================================================
    IndicatorDefinition(
      id: "pivot",
      name: "Pivot Points",
      category: "Price Action",
      icon: Icons.grid_on,
      fields: [
        IndicatorField(
          key: "type",
          label: "Pivot Type",
          type: IndicatorFieldType.dropdown,
          defaultValue: "Classic",
          options: const ["Classic", "Fibonacci", "Woodie", "Camarilla"],
        ),

        IndicatorField(
          key: "condition",
          label: "Condition",
          type: IndicatorFieldType.dropdown,
          defaultValue: "Price Above Pivot",
          options: const [
            "Price Above Pivot",
            "Price Below Pivot",
            "Break R1",
            "Break S1",
            "Touch Pivot",
          ],
        ),
      ],
    ),
  ];

  static IndicatorDefinition? get(String id) {
    try {
      return indicators.firstWhere((indicator) => indicator.id == id);
    } catch (_) {
      return null;
    }
  }
}
