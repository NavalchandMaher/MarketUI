import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../state/auth_state.dart';
import '../utils/responsive.dart';
import '../utils/responsive_text.dart';
import 'dashboard_screen.dart';
import 'responsive_dashboard_screen.dart';
import 'analysis_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'trades_screen.dart';
import 'history_screen.dart';
import 'trading/strategy_management_screen.dart';
import 'testing/backtest_testing_screen.dart';

/// ===============================================================
/// Responsive App Shell
/// Adaptive Navigation: Bottom tabs for mobile, Rail/Drawer for desktop
/// ===============================================================

class ResponsiveAppShell extends StatefulWidget {
  const ResponsiveAppShell({super.key});

  @override
  State<ResponsiveAppShell> createState() => _ResponsiveAppShellState();
}

class _ResponsiveAppShellState extends State<ResponsiveAppShell> {
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    ResponsiveDashboardScreen(),
    AnalysisScreen(),
    TradesScreen(),
    ReportsScreen(),
    StrategyManagementScreen(),
    BacktestTestingScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      tooltip: 'Dashboard',
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: 'Analysis',
      tooltip: 'Market Analysis',
    ),
    NavigationItem(
      icon: Icons.show_chart_outlined,
      selectedIcon: Icons.show_chart,
      label: 'Trades',
      tooltip: 'Trading',
    ),
    NavigationItem(
      icon: Icons.insights_outlined,
      selectedIcon: Icons.insights,
      label: 'Reports',
      tooltip: 'Reports',
    ),
    NavigationItem(
      icon: Icons.dashboard_customize,
      selectedIcon: Icons.dashboard_customize,
      label: 'Strategies',
      tooltip: 'Strategy Management',
    ),
    NavigationItem(
      icon: Icons.science_outlined,
      selectedIcon: Icons.science,
      label: 'Backtest',
      tooltip: 'Backtest Testing',
    ),
    NavigationItem(
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
      label: 'History',
      tooltip: 'Backtest History',
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
      tooltip: 'Settings',
    ),
  ];

  void _onNavigationChanged(int index) {
    setState(() => _currentIndex = index);
  }

  String _getPageTitle() {
    return _navigationItems[_currentIndex].label;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, AuthState>(
      builder: (context, appState, authState, _) {
        final isMobile = ResponsiveBreakpoints.isMobile(context);
        final isTablet = ResponsiveBreakpoints.isTablet(context);

        if (isMobile) {
          return _buildMobileLayout();
        } else if (isTablet) {
          return _buildTabletLayout();
        } else {
          return _buildDesktopLayout();
        }
      },
    );
  }

  // ============================================================
  // Mobile Layout - Bottom Navigation
  // ============================================================

  Widget _buildMobileLayout() {
    // Clamp currentIndex to valid BottomNavigationBar range (0-4)
    // Items 5-7 (Backtest, History, Settings) are accessed via menu only
    final bottomNavIndex = _currentIndex < 5 ? _currentIndex : 0;

    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          _getPageTitle(),
          styleBuilder: ResponsiveTextStyle.getTitle,
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _showMobileMenu(),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: bottomNavIndex,
          onTap: _onNavigationChanged,
          type: BottomNavigationBarType.fixed,
          items: _navigationItems.take(5).map((item) {
            return BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.selectedIcon),
              label: item.label,
              tooltip: item.tooltip,
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // Tablet Layout - Side Navigation Rail
  // ============================================================

  Widget _buildTabletLayout() {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          _getPageTitle(),
          styleBuilder: ResponsiveTextStyle.getTitle,
        ),
        elevation: 0,
      ),
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onNavigationChanged,
            labelType: NavigationRailLabelType.selected,
            destinations: _navigationItems.map((item) {
              return NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: Text(item.label),
              );
            }).toList(),
          ),
          // Content
          Expanded(child: _pages[_currentIndex]),
        ],
      ),
    );
  }

  // ============================================================
  // Desktop Layout - Sidebar + Main Content
  // ============================================================

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 250,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Logo/Branding
                Container(
                  padding: const EdgeInsets.all(20),
                  child: ResponsiveText(
                    'Market AI',
                    styleBuilder: ResponsiveTextStyle.getHeading,
                  ),
                ),
                Divider(color: Colors.grey.withOpacity(0.1)),
                // Navigation Items
                Expanded(
                  child: ListView.builder(
                    itemCount: _navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = _navigationItems[index];
                      final isSelected = _currentIndex == index;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onNavigationChanged(index),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: isSelected
                                  ? BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border(
                                        left: BorderSide(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          width: 4,
                                        ),
                                      ),
                                    )
                                  : null,
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? item.selectedIcon : item.icon,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ResponsiveText(
                                      item.label,
                                      styleBuilder: ResponsiveTextStyle.getBody,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Colors.grey,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ResponsiveText(
                        _getPageTitle(),
                        styleBuilder: ResponsiveTextStyle.getHeading,
                      ),
                      Consumer<AuthState>(
                        builder: (context, authState, _) {
                          return Row(
                            children: [
                              ResponsiveText(
                                authState.userName,
                                styleBuilder: ResponsiveTextStyle.getBody,
                              ),
                              const SizedBox(width: 16),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.2),
                                ),
                                child: Center(
                                  child: Text(
                                    authState.userName.isNotEmpty
                                        ? authState.userName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Page Content
                Expanded(child: _pages[_currentIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Mobile Menu
  // ============================================================

  void _showMobileMenu() {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final maxMenuHeight = screenHeight * 0.85; // Max 85% of screen
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

        return SafeArea(
          bottom: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxMenuHeight),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Fixed Drag Handle
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Scrollable Menu Items
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Navigation Items
                            ..._navigationItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final isSelected = _currentIndex == index;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: SmoothListTile(
                                  title: item.label,
                                  leading: item.icon,
                                  isSelected: isSelected,
                                  onTap: () {
                                    _onNavigationChanged(index);
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            }),
                            // Divider with padding
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                height: 1,
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            // Settings Option
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: SmoothListTile(
                                title: 'Theme',
                                leading: Icons.brightness_4,
                                onTap: () {
                                  final appState = context.read<AppState>();
                                  final currentMode = appState.themeMode;
                                  final nextMode =
                                      currentMode == ThemeMode.light
                                      ? ThemeMode.dark
                                      : ThemeMode.light;
                                  appState.setThemeMode(nextMode);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            // Logout Option
                            SmoothListTile(
                              title: 'Logout',
                              leading: Icons.logout,
                              onTap: () {
                                final authState = context.read<AuthState>();
                                authState.logout();
                                Navigator.pop(context);
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/login',
                                  (route) => false,
                                );
                              },
                            ),
                            // Bottom padding for safety
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String tooltip;

  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.tooltip,
  });
}

/// Smooth List Tile widget (import from smooth_widgets if available)
class SmoothListTile extends StatefulWidget {
  final String title;
  final IconData? leading;
  final VoidCallback onTap;
  final bool isSelected;

  const SmoothListTile({
    required this.title,
    this.leading,
    required this.onTap,
    this.isSelected = false,
    super.key,
  });

  @override
  State<SmoothListTile> createState() => _SmoothListTileState();
}

class _SmoothListTileState extends State<SmoothListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: widget.isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            children: [
              if (widget.leading != null)
                Icon(
                  widget.leading,
                  color: widget.isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              if (widget.leading != null) const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontWeight: widget.isSelected ? FontWeight.w600 : null,
                    color: widget.isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
