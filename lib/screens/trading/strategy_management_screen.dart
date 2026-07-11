import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/strategies_provider.dart';

/// ===============================================================
/// Strategy Management Screen
/// ===============================================================
class StrategyManagementScreen extends StatefulWidget {
  const StrategyManagementScreen({super.key});

  @override
  State<StrategyManagementScreen> createState() =>
      _StrategyManagementScreenState();
}

class _StrategyManagementScreenState extends State<StrategyManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StrategiesProvider>().loadStrategies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Strategy Management'), elevation: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStrategyForm(context),
        tooltip: 'New Strategy',
        child: const Icon(Icons.add),
      ),
      body: Consumer<StrategiesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.strategies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.strategies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.dashboard_customize,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('No strategies yet'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showStrategyForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Strategy'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadStrategies(forceRefresh: true),
            child: ListView.builder(
              itemCount: provider.strategies.length,
              itemBuilder: (context, index) {
                final strategy = provider.strategies[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.show_chart),
                    title: Text(strategy.name),
                    subtitle: Text(
                      'v${strategy.version} - EMA ${strategy.emaFast}/${strategy.emaSlow}',
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'edit') {
                          _showStrategyForm(context, strategy: strategy);
                        } else if (value == 'delete') {
                          _showDeleteConfirm(context, strategy.name);
                        }
                      },
                    ),
                    onTap: () => provider.selectStrategy(strategy),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showStrategyForm(BuildContext context, {dynamic strategy}) {
    showDialog(
      context: context,
      builder: (context) => _StrategyFormDialog(strategy: strategy),
    );
  }

  void _showDeleteConfirm(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Strategy'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<StrategiesProvider>().deleteStrategy(name);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StrategyFormDialog extends StatefulWidget {
  final dynamic strategy;

  const _StrategyFormDialog({this.strategy});

  @override
  State<_StrategyFormDialog> createState() => _StrategyFormDialogState();
}

class _StrategyFormDialogState extends State<_StrategyFormDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController buyThresholdCtrl;
  late TextEditingController sellThresholdCtrl;
  late TextEditingController tpCtrl;
  late TextEditingController slCtrl;
  late TextEditingController emaFastCtrl;
  late TextEditingController emaSlowCtrl;
  late TextEditingController rsiBuyCtrl;
  late TextEditingController rsiSellCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.strategy?.name ?? '');
    buyThresholdCtrl = TextEditingController(
      text: widget.strategy?.buyThreshold.toString() ?? '3',
    );
    sellThresholdCtrl = TextEditingController(
      text: widget.strategy?.sellThreshold.toString() ?? '-3',
    );
    tpCtrl = TextEditingController(
      text: widget.strategy?.tpPercent.toString() ?? '2',
    );
    slCtrl = TextEditingController(
      text: widget.strategy?.slPercent.toString() ?? '1',
    );
    emaFastCtrl = TextEditingController(
      text: widget.strategy?.emaFast.toString() ?? '20',
    );
    emaSlowCtrl = TextEditingController(
      text: widget.strategy?.emaSlow.toString() ?? '50',
    );
    rsiBuyCtrl = TextEditingController(
      text: widget.strategy?.rsiBuy.toString() ?? '40',
    );
    rsiSellCtrl = TextEditingController(
      text: widget.strategy?.rsiSell.toString() ?? '65',
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    buyThresholdCtrl.dispose();
    sellThresholdCtrl.dispose();
    tpCtrl.dispose();
    slCtrl.dispose();
    emaFastCtrl.dispose();
    emaSlowCtrl.dispose();
    rsiBuyCtrl.dispose();
    rsiSellCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.strategy != null ? 'Edit Strategy' : 'New Strategy'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Strategy Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: buyThresholdCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Buy Threshold'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: sellThresholdCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Sell Threshold'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tpCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'TP Percent'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: slCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'SL Percent'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emaFastCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'EMA Fast'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emaSlowCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'EMA Slow'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rsiBuyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'RSI Buy'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rsiSellCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'RSI Sell'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (widget.strategy != null) {
              await context.read<StrategiesProvider>().updateStrategy(
                id: widget.strategy.name,
                name: nameCtrl.text,
                buyThreshold: int.parse(buyThresholdCtrl.text),
                sellThreshold: int.parse(sellThresholdCtrl.text),
                tpPercent: double.parse(tpCtrl.text),
                slPercent: double.parse(slCtrl.text),
                emaFast: int.parse(emaFastCtrl.text),
                emaSlow: int.parse(emaSlowCtrl.text),
                rsiBuy: int.parse(rsiBuyCtrl.text),
                rsiSell: int.parse(rsiSellCtrl.text),
              );
            } else {
              await context.read<StrategiesProvider>().createStrategy(
                name: nameCtrl.text,
                buyThreshold: int.parse(buyThresholdCtrl.text),
                sellThreshold: int.parse(sellThresholdCtrl.text),
                tpPercent: double.parse(tpCtrl.text),
                slPercent: double.parse(slCtrl.text),
                emaFast: int.parse(emaFastCtrl.text),
                emaSlow: int.parse(emaSlowCtrl.text),
                rsiBuy: int.parse(rsiBuyCtrl.text),
                rsiSell: int.parse(rsiSellCtrl.text),
              );
            }
            if (mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
