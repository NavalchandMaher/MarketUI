
import 'package:flutter/material.dart';

class IndicatorCard extends StatelessWidget{

  final Map data;

  const IndicatorCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return indicatorCard();
  }



    Widget indicatorCard() {

    bool emaBull = (data["ema20"] ?? 0) > (data["ema50"] ?? 0);
    bool rsiBull = (data["rsi"] ?? 50) < 40;
    bool rsiBear = (data["rsi"] ?? 50) > 60;
    bool macdBull = (data["macd"] ?? 0) > 0;
    bool adxStrong = (data["adx"] ?? 0) > 25;
    bool pcrBull = (data["pcr"] ?? 1) > 1.2;
    bool pcrBear = (data["pcr"] ?? 1) < 0.8;

    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            children: [

            const Text("Core Indicators",
                style: TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),

            const SizedBox(height: 15),

            indicatorRow(
                "EMA Trend",
                "${data["ema20"]} / ${data["ema50"]}",
                emaBull ? "BULLISH" : "BEARISH",
                emaBull),

            indicatorRow(
                "RSI",
                data["rsi"],
                rsiBull
                    ? "OVERSOLD ↑"
                    : rsiBear
                        ? "OVERBOUGHT ↓"
                        : "NEUTRAL",
                rsiBull),

            indicatorRow(
                "MACD",
                data["macd"],
                macdBull ? "BULLISH ↑" : "BEARISH ↓",
                macdBull),

            indicatorRow(
                "ADX",
                data["adx"],
                adxStrong ? "STRONG TREND" : "WEAK TREND",
                adxStrong),

            indicatorRow(
                "PCR",
                data["pcr"],
                pcrBull
                    ? "PUT DOMINANT ↑"
                    : pcrBear
                        ? "CALL DOMINANT ↓"
                        : "BALANCED",
                pcrBull),

            indicatorRow(
                "Volume Ratio",
                data["volume_ratio"],
                (data["volume_ratio"] ?? 1) > 1.3
                    ? "HIGH VOLUME ↑"
                    : "LOW VOLUME",
                (data["volume_ratio"] ?? 1) > 1.3),

            ],
        ),
        ),
    );
    }

    Widget indicatorRow(
        String name, dynamic value, String state, bool bullish) {

    Color stateColor = bullish ? Colors.green : Colors.red;

    if (state.contains("NEUTRAL") ||
        state.contains("BALANCED") ||
        state.contains("WEAK")) {
        stateColor = Colors.orange;
    }

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(name,
                    style: const TextStyle(color: Colors.white70)),
                Text(value.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold))
            ],
            ),

            Row(
            children: [
                Icon(
                bullish
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: stateColor,
                size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                state,
                style: TextStyle(
                    color: stateColor,
                    fontWeight: FontWeight.bold),
                ),
            ],
            ),
        ],
        ),
    );
    }
}