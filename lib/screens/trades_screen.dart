import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/common_widgets.dart';
import '../utils/constants.dart';

class TradesScreen extends StatelessWidget {
  const TradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Trades'), elevation: 0),
      body: RefreshIndicator(
        onRefresh: state.refreshHomeData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Paper Trading Summary',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 16),
                  if (state.isLoading)
                    const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: MetricTile(
                                title: 'Open Trades',
                                value: state.openTrades.toString(),
                                icon: Icons.timelapse,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: MetricTile(
                                title: "Today's P&L",
                                value:
                                    '₹${state.todayProfitLoss.toStringAsFixed(2)}',
                                icon: Icons.trending_up,
                                valueColor: state.todayProfitLoss >= 0
                                    ? AppColors.buy
                                    : AppColors.sell,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: MetricTile(
                                title: 'Total Trades',
                                value: state.paperTrades.length.toString(),
                                icon: Icons.history,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: MetricTile(
                                title: 'Balance',
                                value:
                                    '₹${state.currentBalance.toStringAsFixed(2)}',
                                icon: Icons.savings,
                                valueColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Open Trades', style: AppTextStyles.title),
                  const SizedBox(height: 16),
                  if (state.paperTrades.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No open trades',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: List.generate(state.paperTrades.length, (
                        index,
                      ) {
                        final trade = state.paperTrades[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.withAlpha(30),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        trade['symbol'] ?? 'N/A',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Entry: ${trade['entry_price'] ?? 0}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Vol: ${trade['volume'] ?? 0}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      trade['status'] ?? 'OPEN',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: trade['status'] == 'OPEN'
                                            ? AppColors.buy
                                            : AppColors.sell,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
