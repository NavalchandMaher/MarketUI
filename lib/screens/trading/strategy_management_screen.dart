import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/strategy_model.dart';
import '../../state/auth_state.dart';
import '../../strategy_builder/screens/strategy_builder_screen.dart';
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
                      strategy.isDefault
                          ? 'Default · v${strategy.version} - EMA ${strategy.emaFast}/${strategy.emaSlow}'
                          : strategy.strategyType.toLowerCase() == 'system'
                          ? 'System · v${strategy.version} - EMA ${strategy.emaFast}/${strategy.emaSlow}'
                          : 'v${strategy.version} - EMA ${strategy.emaFast}/${strategy.emaSlow}',
                    ),
                    trailing: Builder(
                      builder: (context) {
                        final authState = context.watch<AuthState>();
                        final isAdmin =
                            authState.userRole.toLowerCase() == 'admin';
                        final isSystem =
                            strategy.strategyType.toLowerCase() == 'system';
                        final items = <PopupMenuEntry<String>>[];

                        if (isSystem) {
                          if (isAdmin) {
                            items.add(
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                            );
                            items.add(
                              PopupMenuItem(
                                value: strategy.published
                                    ? 'unpublish'
                                    : 'publish',
                                child: Text(
                                  strategy.published ? 'Unpublish' : 'Publish',
                                ),
                              ),
                            );
                            if (!strategy.isDefault) {
                              items.add(
                                const PopupMenuItem(
                                  value: 'set_default',
                                  child: Text('Set as default'),
                                ),
                              );
                            }
                            items.add(
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            );
                          } else if (!strategy.isDefault) {
                            items.add(
                              const PopupMenuItem(
                                value: 'set_default',
                                child: Text('Set as default'),
                              ),
                            );
                          }
                        } else {
                          items.add(
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                          );
                          if (!strategy.isDefault) {
                            items.add(
                              const PopupMenuItem(
                                value: 'set_default',
                                child: Text('Set as default'),
                              ),
                            );
                          }
                          items.add(
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          );
                        }

                        if (items.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return PopupMenuButton(
                          itemBuilder: (_) => items,
                          onSelected: (value) async {
                            final provider = context.read<StrategiesProvider>();
                            final messenger = ScaffoldMessenger.of(context);
                            if (value == 'edit') {
                              _showStrategyForm(context, strategy: strategy);
                              return;
                            }

                            if (value == 'delete') {
                              _showDeleteConfirm(
                                context,
                                strategy.name,
                                strategy.id,
                              );
                              return;
                            }

                            if (value == 'publish' || value == 'unpublish') {
                              final publish = value == 'publish';
                              final success = await provider.publishStrategy(
                                strategy.id,
                                publish,
                              );
                              if (!mounted) return;
                              if (!success) {
                                final error = provider.errorMessage;
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      error ??
                                          'Unable to update publish state.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              return;
                            }

                            if (value == 'set_default') {
                              final success = await provider.setDefaultStrategy(
                                strategy.id,
                              );
                              if (!mounted) return;
                              if (!success) {
                                final error = provider.errorMessage;
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      error ??
                                          'Unable to set default strategy.',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        );
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

  void _showStrategyForm(BuildContext context, {StrategyModel? strategy}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StrategyBuilderScreen(strategy: strategy),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, String name, String id) {
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
              context.read<StrategiesProvider>().deleteStrategy(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
