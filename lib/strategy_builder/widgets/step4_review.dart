import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/strategy_models.dart';
import '../state/strategy_builder_provider.dart';

class Step4Review extends StatelessWidget {
  final VoidCallback? onBack;

  const Step4Review({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StrategyBuilderProvider>();
    final strategy = provider.model;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: const Color(0xFF111827),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Strategy Summary",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Review your strategy before saving or running a backtest.",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 24),

                  _sectionTitle("Basic Information"),

                  _infoTile("Strategy Name", strategy.name),

                  _infoTile("Exchange", strategy.exchange),

                  _infoTile("Market", strategy.market),

                  _infoTile("Timeframe", strategy.timeframe),

                  _infoTile("Strategy Type", strategy.strategyType),

                  _infoTile(
                    "Paper Trading",
                    strategy.paperMode ? "Enabled" : "Disabled",
                  ),

                  _infoTile(
                    "Live Trading",
                    strategy.liveMode ? "Enabled" : "Disabled",
                  ),

                  const SizedBox(height: 28),

                  _sectionTitle("Buy Conditions"),

                  const SizedBox(height: 12),

                  if (strategy.buyConditions.isEmpty)
                    const Text(
                      "No Buy Conditions",
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ...strategy.buyConditions.map(
                      (condition) => _conditionCard(condition, Colors.green),
                    ),

                  const SizedBox(height: 28),

                  _sectionTitle("Sell Conditions"),

                  const SizedBox(height: 12),

                  if (strategy.sellConditions.isEmpty)
                    const Text(
                      "No Sell Conditions",
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ...strategy.sellConditions.map(
                      (condition) => _conditionCard(condition, Colors.red),
                    ),

                  const SizedBox(height: 28),

                  _sectionTitle("Risk Management"),

                  const SizedBox(height: 12),

                  _infoTile("Risk %", "${strategy.riskSettings.riskPerTrade}"),

                  _infoTile("Risk Reward", "${strategy.riskSettings.rr}"),

                  _infoTile(
                    "Max Daily Trades",
                    "${strategy.riskSettings.maxDailyTrades}",
                  ),

                  _infoTile(
                    "Max Open Trades",
                    "${strategy.riskSettings.maxOpenTrades}",
                  ),
                  const SizedBox(height: 30),

                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: OutlinedButton.icon(
                  //         onPressed: onBack,
                  //         icon: const Icon(Icons.arrow_back),
                  //         label: const Text("Back"),
                  //         style: OutlinedButton.styleFrom(
                  //           foregroundColor: Colors.white,
                  //           minimumSize: const Size.fromHeight(54),
                  //           side: const BorderSide(color: Color(0xFF3B82F6)),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(14),
                  //           ),
                  //         ),
                  //       ),
                  //     ),

                  //     const SizedBox(width: 16),

                  //     Expanded(
                  //       child: ElevatedButton.icon(
                  //         onPressed: () {
                  //           ScaffoldMessenger.of(context).showSnackBar(
                  //             const SnackBar(
                  //               content: Text("Strategy saved successfully."),
                  //             ),
                  //           );
                  //         },
                  //         icon: const Icon(Icons.save),
                  //         label: const Text("Save Strategy"),
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: const Color(0xFF3B82F6),
                  //           foregroundColor: Colors.white,
                  //           minimumSize: const Size.fromHeight(54),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(14),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Backtest feature coming soon."),
                          ),
                        );
                      },
                      icon: const Icon(Icons.analytics),
                      label: const Text("Run Backtest"),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.grey)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _conditionCard(Condition condition, Color color) {
    return Card(
      color: const Color(0xFF0B1220),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(.15),
                  child: Text(
                    condition.indicator.name.substring(0, 1),
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    condition.indicator.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: condition.indicator.parameter.params.entries
                  .map(
                    (e) => Chip(
                      backgroundColor: const Color(0xFF1F2937),
                      label: Text("${e.key}: ${e.value}"),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
