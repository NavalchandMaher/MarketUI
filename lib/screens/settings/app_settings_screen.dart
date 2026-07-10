import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/settings_provider.dart';

/// ===============================================================
/// App Settings Screen
/// ===============================================================
class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App Settings'), elevation: 0),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.settings == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = provider.settings;
          if (settings == null) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () => provider.loadSettings(forceRefresh: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Notifications Settings
                ExpansionTile(
                  title: const Text('Notifications'),
                  leading: const Icon(Icons.notifications),
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Notifications'),
                      subtitle: const Text(
                        'Receive alerts about trades and updates',
                      ),
                      value: settings.notificationsEnabled,
                      onChanged: (value) async {
                        await provider.updateNotifications(enabled: value);
                      },
                    ),
                    if (settings.notificationsEnabled) ...[
                      SwitchListTile(
                        title: const Text('Email Notifications'),
                        value: settings.emailNotifications,
                        onChanged: (value) async {
                          await provider.updateNotifications(
                            enabled: true,
                            emailEnabled: value,
                          );
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Push Notifications'),
                        value: settings.pushNotifications,
                        onChanged: (value) async {
                          await provider.updateNotifications(
                            enabled: true,
                            pushEnabled: value,
                          );
                        },
                      ),
                    ],
                  ],
                ),
                const Divider(),

                // Display Settings
                ExpansionTile(
                  title: const Text('Display'),
                  leading: const Icon(Icons.palette),
                  children: [
                    ListTile(
                      title: const Text('Theme'),
                      subtitle: Text(settings.theme),
                      trailing: DropdownButton<String>(
                        value: settings.theme,
                        items: const [
                          DropdownMenuItem(
                            value: 'light',
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(value: 'dark', child: Text('Dark')),
                          DropdownMenuItem(
                            value: 'system',
                            child: Text('System'),
                          ),
                        ],
                        onChanged: (value) async {
                          if (value != null) {
                            await provider.updateTheme(value);
                          }
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Language'),
                      subtitle: Text(settings.language.toUpperCase()),
                      trailing: const Icon(Icons.language),
                    ),
                  ],
                ),
                const Divider(),

                // Risk Management
                ExpansionTile(
                  title: const Text('Risk Management'),
                  leading: const Icon(Icons.warning),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Risk Level: ${settings.riskLevel}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Slider(
                            value: settings.riskLevel.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: 'Level ${settings.riskLevel}',
                            onChanged: (value) async {
                              await provider.updateRiskLevel(value.toInt());
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Max Position Size: ${(settings.maxPositionSize * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Slider(
                            value: settings.maxPositionSize,
                            min: 0.01,
                            max: 0.5,
                            divisions: 49,
                            onChanged: (value) async {
                              await provider.updateSettings(
                                maxPositionSize: value,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Max Daily Loss: ${(settings.maxDailyLoss * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Slider(
                            value: settings.maxDailyLoss,
                            min: 0.01,
                            max: 0.1,
                            divisions: 9,
                            onChanged: (value) async {
                              await provider.updateSettings(
                                maxDailyLoss: value,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),

                // Auto Trading
                ExpansionTile(
                  title: const Text('Auto Trading'),
                  leading: const Icon(Icons.auto_awesome),
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Auto Trading'),
                      subtitle: const Text(
                        'Allow automated trading when conditions are met',
                      ),
                      value: settings.autoTradingEnabled,
                      onChanged: (value) async {
                        await provider.toggleAutoTrading(enabled: value);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
