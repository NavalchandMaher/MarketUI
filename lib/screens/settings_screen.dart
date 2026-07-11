import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// ===============================================================
  /// General Settings
  /// ===============================================================

  bool _darkMode = false;

  bool _notifications = true;

  bool _autoRefresh = true;

  bool _paperTrading = true;

  bool _soundAlerts = true;

  bool _vibration = true;

  bool _aiAnalysis = true;

  bool _tradeConfirmation = true;

  /// ===============================================================
  /// Refresh Interval
  /// ===============================================================

  int _refreshInterval = 15;

  final List<int> _intervals = [5, 10, 15, 30, 60];

  /// ===============================================================
  /// Risk Settings
  /// ===============================================================

  double _riskPerTrade = 2.0;

  double _maxDrawdown = 10.0;

  /// ===============================================================
  /// API Information
  /// ===============================================================

  final String _apiVersion = "v1.0";

  final String _environment = "Production";

  final String _appVersion = "1.0.0";

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  /// ===============================================================
  /// Load Settings
  /// ===============================================================

  Future<void> _loadSettings() async {
    // TODO:
    // Replace with SharedPreferences or secure storage.

    setState(() {
      _darkMode = false;
      _notifications = true;
      _autoRefresh = true;
      _paperTrading = true;
      _soundAlerts = true;
      _vibration = true;
      _aiAnalysis = true;
      _tradeConfirmation = true;

      _refreshInterval = 15;

      _riskPerTrade = 2.0;
      _maxDrawdown = 10.0;
    });
  }

  /// ===============================================================
  /// Save Settings
  /// ===============================================================

  Future<void> _saveSettings() async {
    // TODO:
    // Save values using SharedPreferences.

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Settings saved successfully"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// ===============================================================
  /// Reset Settings
  /// ===============================================================

  Future<void> _resetSettings() async {
    setState(() {
      _darkMode = false;
      _notifications = true;
      _autoRefresh = true;
      _paperTrading = true;
      _soundAlerts = true;
      _vibration = true;
      _aiAnalysis = true;
      _tradeConfirmation = true;

      _refreshInterval = 15;

      _riskPerTrade = 2.0;
      _maxDrawdown = 10.0;
    });

    await _saveSettings();
  }

  /// ===============================================================
  /// Confirm Reset
  /// ===============================================================

  Future<void> _confirmReset() async {
    final reset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset Settings"),
          content: const Text(
            "Do you want to restore all settings to their default values?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Reset"),
            ),
          ],
        );
      },
    );

    if (reset == true) {
      await _resetSettings();
    }
  }

  /// ===============================================================
  /// General Settings
  /// ===============================================================

  Widget _buildGeneralSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.settings),
            title: Text(
              "General Settings",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text("Dark Mode"),
            subtitle: const Text("Enable dark application theme"),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            subtitle: const Text("Receive market notifications"),
            value: _notifications,
            onChanged: (value) {
              setState(() => _notifications = value);
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.refresh),
            title: const Text("Auto Refresh"),
            subtitle: const Text("Refresh market automatically"),
            value: _autoRefresh,
            onChanged: (value) {
              setState(() => _autoRefresh = value);
            },
          ),

          if (_autoRefresh)
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text("Refresh Interval"),
              subtitle: Text("$_refreshInterval seconds"),
              trailing: DropdownButton<int>(
                value: _refreshInterval,
                items: _intervals
                    .map(
                      (e) => DropdownMenuItem(value: e, child: Text("$e sec")),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _refreshInterval = value;
                  });
                },
              ),
            ),

          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text("Push Notifications"),
            subtitle: const Text("Receive signal alerts while using the app"),
            value: _soundAlerts,
            onChanged: (value) {
              setState(() => _soundAlerts = value);
            },
          ),

          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text("Refresh Interval"),
            subtitle: Text("$_refreshInterval seconds"),
            trailing: DropdownButton<int>(
              value: _refreshInterval,
              items: _intervals
                  .map((e) => DropdownMenuItem(value: e, child: Text("$e sec")))
                  .toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _refreshInterval = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Trading Settings
  /// ===============================================================

  Widget _buildTradingSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.candlestick_chart),
            title: Text(
              "Trading Settings",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.account_balance),
            title: const Text("Paper Trading"),
            value: _paperTrading,
            onChanged: (value) {
              setState(() => _paperTrading = value);
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.check_circle),
            title: const Text("Trade Confirmation"),
            value: _tradeConfirmation,
            onChanged: (value) {
              setState(() => _tradeConfirmation = value);
            },
          ),

          ListTile(
            leading: const Icon(Icons.security),
            title: const Text("Risk Per Trade"),
            subtitle: Text("${_riskPerTrade.toStringAsFixed(1)} %"),
          ),

          Slider(
            value: _riskPerTrade,
            min: 0.5,
            max: 10,
            divisions: 19,
            label: "${_riskPerTrade.toStringAsFixed(1)}%",
            onChanged: (value) {
              setState(() {
                _riskPerTrade = value;
              });
            },
          ),

          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text("Max Drawdown"),
            subtitle: Text("${_maxDrawdown.toStringAsFixed(1)} %"),
          ),

          Slider(
            value: _maxDrawdown,
            min: 5,
            max: 50,
            divisions: 45,
            label: "${_maxDrawdown.toStringAsFixed(1)}%",
            onChanged: (value) {
              setState(() {
                _maxDrawdown = value;
              });
            },
          ),
        ],
      ),
    );
  }

  /// ===============================================================
  /// AI Settings
  /// ===============================================================

  Widget _buildAISection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.psychology),
            title: Text(
              "AI Settings",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          SwitchListTile(
            secondary: const Icon(Icons.smart_toy),
            title: const Text("Enable AI Analysis"),
            value: _aiAnalysis,
            onChanged: (value) {
              setState(() => _aiAnalysis = value);
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.volume_up),
            title: const Text("Sound Alerts"),
            value: _soundAlerts,
            onChanged: (value) {
              setState(() => _soundAlerts = value);
            },
          ),

          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: const Text("Vibration Alerts"),
            value: _vibration,
            onChanged: (value) {
              setState(() => _vibration = value);
            },
          ),
        ],
      ),
    );
  }

  /// ===============================================================
  /// About Section
  /// ===============================================================

  Widget _buildAboutSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline),

                SizedBox(width: 10),

                Text(
                  "About Application",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _infoRow("Application", "AI Trading Dashboard"),

            _infoRow("Version", _appVersion),

            _infoRow("API Version", _apiVersion),

            _infoRow("Environment", _environment),

            const Divider(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save),
                label: const Text("Save Settings"),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _confirmReset,
                icon: const Icon(Icons.restore),
                label: const Text("Reset to Default"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Information Row
  /// ===============================================================

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          Text(value),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Settings Body
  /// ===============================================================

  Widget _buildSettingsBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGeneralSection(),

          _buildTradingSection(),

          _buildAISection(),

          _buildAboutSection(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  /// ===============================================================
  /// Build
  /// ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(child: _buildSettingsBody()),
    );
  }
}
