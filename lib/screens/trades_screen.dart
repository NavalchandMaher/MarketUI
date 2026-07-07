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
    final paperTrade = state.paperTrade;

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
                  if (paperTrade == null)
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
                                value: paperTrade.openTrades.toString(),
                                icon: Icons.timelapse,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: MetricTile(
                                title: 'Closed Trades',
                                value: paperTrade.closedTrades.toString(),
                                icon: Icons.history,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: MetricTile(
                                title: 'Win Rate',
                                value:
                                    '${paperTrade.winRate.toStringAsFixed(2)}%',
                                icon: Icons.emoji_events,
                                valueColor: paperTrade.winRate >= 50
                                    ? AppColors.buy
                                    : AppColors.sell,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: MetricTile(
                                title: 'Total Profit',
                                value:
                                    '₹${paperTrade.totalProfit.toStringAsFixed(2)}',
                                icon: Icons.savings,
                                valueColor: paperTrade.isProfitable
                                    ? AppColors.buy
                                    : AppColors.sell,
                              ),
                            ),
                          ],
                        ),
                      ],
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
