import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../utils/constants.dart';
import '../utils/responsive.dart';
import '../utils/responsive_text.dart';
import '../utils/smooth_widgets.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/symbol_timeframe_selector.dart';

/// ===============================================================
/// Responsive Dashboard Screen
/// Mobile-First Design with smooth animations
/// ===============================================================

class ResponsiveDashboardScreen extends StatefulWidget {
  const ResponsiveDashboardScreen({super.key});

  @override
  State<ResponsiveDashboardScreen> createState() =>
      _ResponsiveDashboardScreenState();
}

class _ResponsiveDashboardScreenState extends State<ResponsiveDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          appBar: _buildAppBar(context, state),
          body: SafeArea(
            child: SlideTransition(
              position: _slideAnimation,
              child: state.isLoading
                  ? _buildLoadingState(context)
                  : state.errorMessage != null
                  ? _buildErrorState(context, state)
                  : _buildContent(context, state),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppState state) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    return AppBar(
      title: ResponsiveText(
        'Market Dashboard',
        styleBuilder: ResponsiveTextStyle.getTitle,
      ),
      elevation: 0,
      actions: [
        if (!isMobile) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                state.selectedSymbol,
                style: ResponsiveTextStyle.getSubtitle(context),
              ),
            ),
          ),
        ],
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
          onPressed: state.refreshHomeData,
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView(
      padding: ResponsiveSize.getPadding(context),
      children: [
        const SkeletonLoader(height: 100),
        const SizedBox(height: 16),
        const SkeletonLoader(height: 120),
        const SizedBox(height: 16),
        const SkeletonLoader(height: 100),
        const SizedBox(height: 16),
        const SkeletonLoader(height: 80),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, AppState state) {
    return SmoothErrorState(
      message: state.errorMessage ?? 'An error occurred',
      onRetry: state.refreshHomeData,
      retryLabel: 'Retry',
    );
  }

  Widget _buildContent(BuildContext context, AppState state) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);

    return RefreshIndicator(
      onRefresh: () async => state.refreshHomeData(),
      child: SingleChildScrollView(
        padding: ResponsiveSize.getPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Symbol & Timeframe Selector - Mobile optimized
            if (isMobile)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SymbolTimeframeSelector(
                  symbol: state.selectedSymbol,
                  timeframe: state.selectedTimeframe,
                  onSymbolChanged: state.setSymbol,
                  onTimeframeChanged: state.setTimeframe,
                ),
              ),

            // Market Signal Card - Hero Section
            FadeScaleAnimation(
              duration: const Duration(milliseconds: 600),
              child: _buildSignalCard(context, state),
            ),
            const SizedBox(height: 16),

            // Metrics Grid - Responsive layout
            if (isMobile)
              _buildMetricsGridMobile(context, state)
            else if (isTablet)
              _buildMetricsGridTablet(context, state)
            else
              _buildMetricsGridDesktop(context, state),
            const SizedBox(height: 16),

            // Account Summary
            FadeScaleAnimation(
              child: _buildAccountCard(context, state),
              duration: const Duration(milliseconds: 700),
            ),
            const SizedBox(height: 16),

            // Quick Actions
            FadeScaleAnimation(
              child: _buildQuickActionsCard(context, state),
              duration: const Duration(milliseconds: 800),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalCard(BuildContext context, AppState state) {
    final signal = state.signal;
    final confidence = state.confidence;
    final isPositive = signal == AppConstants.buy;
    final isNegative = signal == AppConstants.sell;

    return SmoothCard(
      borderRadius: ResponsiveSize.getCardRadius(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Market Signal',
            styleBuilder: ResponsiveTextStyle.getTitle,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppColors.buy.withOpacity(0.1)
                      : isNegative
                      ? AppColors.sell.withOpacity(0.1)
                      : AppColors.wait.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPositive
                      ? Icons.trending_up
                      : isNegative
                      ? Icons.trending_down
                      : Icons.pause_circle,
                  color: isPositive
                      ? AppColors.buy
                      : isNegative
                      ? AppColors.sell
                      : AppColors.wait,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      signal,
                      styleBuilder: ResponsiveTextStyle.getValue,
                      style: TextStyle(
                        color: isPositive
                            ? AppColors.buy
                            : isNegative
                            ? AppColors.sell
                            : AppColors.wait,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ResponsiveText(
                      'Confidence: $confidence%',
                      styleBuilder: ResponsiveTextStyle.getSubtitle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 6,
              backgroundColor: confidence >= 70
                  ? AppColors.buy.withOpacity(0.2)
                  : confidence >= 40
                  ? AppColors.wait.withOpacity(0.2)
                  : AppColors.sell.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(
                confidence >= 70
                    ? AppColors.buy
                    : confidence >= 40
                    ? AppColors.wait
                    : AppColors.sell,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGridMobile(BuildContext context, AppState state) {
    return Column(
      children: [
        _buildMetricCard(
          context,
          'Current Price',
          '₹${state.currentPrice.toStringAsFixed(2)}',
          Icons.attach_money,
          AppColors.primary,
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          context,
          'Balance',
          '₹${state.currentBalance.toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          AppColors.primary,
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          context,
          'Open Trades',
          state.openTrades.toString(),
          Icons.swap_horiz,
          AppColors.primary,
        ),
        const SizedBox(height: 12),
        _buildMetricCard(
          context,
          "Today's P/L",
          '₹${state.todayProfitLoss.toStringAsFixed(2)}',
          Icons.trending_flat,
          state.todayProfitLoss >= 0 ? AppColors.buy : AppColors.sell,
        ),
      ],
    );
  }

  Widget _buildMetricsGridTablet(BuildContext context, AppState state) {
    return ResponsiveGrid(
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 2,
      spacing: 12,
      children: [
        _buildMetricCard(
          context,
          'Current Price',
          '₹${state.currentPrice.toStringAsFixed(2)}',
          Icons.attach_money,
          AppColors.primary,
        ),
        _buildMetricCard(
          context,
          'Balance',
          '₹${state.currentBalance.toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          AppColors.primary,
        ),
        _buildMetricCard(
          context,
          'Open Trades',
          state.openTrades.toString(),
          Icons.swap_horiz,
          AppColors.primary,
        ),
        _buildMetricCard(
          context,
          "Today's P/L",
          '₹${state.todayProfitLoss.toStringAsFixed(2)}',
          Icons.trending_flat,
          state.todayProfitLoss >= 0 ? AppColors.buy : AppColors.sell,
        ),
      ],
    );
  }

  Widget _buildMetricsGridDesktop(BuildContext context, AppState state) {
    return ResponsiveGrid(
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 4,
      spacing: 16,
      children: [
        _buildMetricCard(
          context,
          'Current Price',
          '₹${state.currentPrice.toStringAsFixed(2)}',
          Icons.attach_money,
          AppColors.primary,
        ),
        _buildMetricCard(
          context,
          'Balance',
          '₹${state.currentBalance.toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          AppColors.primary,
        ),
        _buildMetricCard(
          context,
          'Open Trades',
          state.openTrades.toString(),
          Icons.swap_horiz,
          AppColors.primary,
        ),
        _buildMetricCard(
          context,
          "Today's P/L",
          '₹${state.todayProfitLoss.toStringAsFixed(2)}',
          Icons.trending_flat,
          state.todayProfitLoss >= 0 ? AppColors.buy : AppColors.sell,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return SmoothCard(
      borderRadius: ResponsiveSize.getCardRadius(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: ResponsiveSize.getIconSize(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ResponsiveText(
                  title,
                  styleBuilder: ResponsiveTextStyle.getSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ResponsiveText(
            value,
            styleBuilder: ResponsiveTextStyle.getValue,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, AppState state) {
    return SmoothCard(
      borderRadius: ResponsiveSize.getCardRadius(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Account Summary',
            styleBuilder: ResponsiveTextStyle.getTitle,
          ),
          const SizedBox(height: 16),
          _buildAccountRow(
            context,
            'Total Balance',
            '₹${state.currentBalance.toStringAsFixed(2)}',
            Icons.account_balance,
          ),
          const SizedBox(height: 12),
          _buildAccountRow(
            context,
            'Strategy',
            state.currentStrategy,
            Icons.trending_up,
          ),
          const SizedBox(height: 12),
          _buildAccountRow(
            context,
            'Paper Trades',
            state.paperTrades.length.toString(),
            Icons.history,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: ResponsiveSize.getIconSize(context)),
        const SizedBox(width: 12),
        Expanded(
          child: ResponsiveText(
            label,
            styleBuilder: ResponsiveTextStyle.getBody,
          ),
        ),
        ResponsiveText(
          value,
          styleBuilder: ResponsiveTextStyle.getValue,
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildQuickActionsCard(BuildContext context, AppState state) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final buttonHeight = isMobile ? 44.0 : 48.0;

    return SmoothCard(
      borderRadius: ResponsiveSize.getCardRadius(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResponsiveText(
            'Quick Actions',
            styleBuilder: ResponsiveTextStyle.getTitle,
          ),
          const SizedBox(height: 16),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: buttonHeight,
                  child: AdaptiveButton(
                    onPressed: () => state.refreshHomeData(),
                    label: 'Start Paper Trading',
                    icon: Icons.play_arrow,
                    isFullWidth: true,
                    variant: ButtonVariant.primary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: buttonHeight,
                  child: AdaptiveButton(
                    onPressed: () => state.refreshHomeData(),
                    label: 'Refresh Data',
                    icon: Icons.refresh,
                    isFullWidth: true,
                    variant: ButtonVariant.secondary,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: buttonHeight,
                    child: AdaptiveButton(
                      onPressed: () => state.refreshHomeData(),
                      label: 'Start',
                      icon: Icons.play_arrow,
                      isFullWidth: true,
                      variant: ButtonVariant.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: buttonHeight,
                    child: AdaptiveButton(
                      onPressed: () => state.refreshHomeData(),
                      label: 'Refresh',
                      icon: Icons.refresh,
                      isFullWidth: true,
                      variant: ButtonVariant.secondary,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
