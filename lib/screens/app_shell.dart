import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../state/auth_state.dart';
import 'analysis_screen.dart';
import 'dashboard_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'trades_screen.dart';
import 'settings/account_settings_screen.dart';
import 'settings/app_settings_screen.dart';
import 'trading/strategy_management_screen.dart';
import 'trading/enhanced_paper_trading_screen.dart';
import 'reports/enhanced_reports_screen.dart';
import 'learning/learning_logs_screen.dart';
import 'testing/backtest_testing_screen.dart';
import 'scheduler_dashboard_screen.dart';
import 'admin/admin_panel_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    DashboardScreen(),
    AnalysisScreen(),
    TradesScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
      label: 'Analysis',
    ),
    NavigationDestination(
      icon: Icon(Icons.show_chart_outlined),
      selectedIcon: Icon(Icons.show_chart),
      label: 'Trades',
    ),
    NavigationDestination(
      icon: Icon(Icons.insights_outlined),
      selectedIcon: Icon(Icons.insights),
      label: 'Reports',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final authState = context.watch<AuthState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Text(
                        (authState.userName.isNotEmpty
                                ? authState.userName[0]
                                : 'U')
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    authState.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    authState.userEmail,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Analysis'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.show_chart_outlined),
              title: const Text('Trades'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 2;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.insights_outlined),
              title: const Text('Reports'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 3;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 4;
                });
              },
            ),
            const Divider(),
            // Trading Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Trading',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_customize),
              title: const Text('Strategy Management'),
              onTap: () {
                Navigator.pop(context);
                _navigateToScreen(context, const StrategyManagementScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Paper Trading'),
              onTap: () {
                Navigator.pop(context);
                _navigateToScreen(context, const EnhancedPaperTradingScreen());
              },
            ),
            const Divider(),
            // Reports Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Analysis',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            if (authState.userRole.toLowerCase() == 'admin')
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Admin Panel'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToScreen(context, const AdminPanelScreen());
                },
              ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Enhanced Reports'),
              onTap: () {
                Navigator.pop(context);
                _navigateToScreen(context, const EnhancedReportsScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Learning Logs'),
              onTap: () {
                Navigator.pop(context);
                _navigateToScreen(context, const LearningLogsScreen());
              },
            ),
            const Divider(),
            // Testing & Scheduler Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Testing & Automation',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.science),
              title: const Text('Backtest'),
              onTap: () {
                Navigator.pop(context);
                _navigateToScreen(context, const BacktestTestingScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Scheduler'),
              onTap: () {
                Navigator.pop(context);
                _navigateToScreen(context, const SchedulerDashboardScreen());
              },
            ),
            const Divider(),
            // Account Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Account',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Account Settings'),
              onTap: () {
                Navigator.pop(context);
                _navigateToScreen(context, const AccountSettingsScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('App Settings'),
              onTap: () {
                Navigator.pop(context);
                _navigateToScreen(context, const AppSettingsScreen());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _logout(context, authState);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: appState.isReady
            ? _pages[_currentIndex]
            : const Center(child: CircularProgressIndicator()),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: _destinations,
      ),
    );
  }

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Analysis';
      case 2:
        return 'Trades';
      case 3:
        return 'Reports';
      case 4:
        return 'Settings';
      default:
        return 'Market AI';
    }
  }

  void _logout(BuildContext context, AuthState authState) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await authState.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
