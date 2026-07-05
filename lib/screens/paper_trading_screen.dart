import 'package:flutter/material.dart';

import '../models/paper_trade_model.dart';
import '../services/api_service.dart';

import '../widgets/paper_trade_card.dart';

class PaperTradingScreen extends StatefulWidget {
  const PaperTradingScreen({super.key});

  @override
  State<PaperTradingScreen> createState() => _PaperTradingScreenState();
}

class _PaperTradingScreenState extends State<PaperTradingScreen> {
  /// ===============================================================
  /// API Service
  /// ===============================================================

  final ApiService _api = ApiService.instance;

  /// ===============================================================
  /// State
  /// ===============================================================

  bool _loading = true;

  bool _refreshing = false;

  String? _error;

  PaperTradeModel? _paperTrade;

  /// ===============================================================
  /// Init
  /// ===============================================================

  @override
  void initState() {
    super.initState();

    _loadPaperTrades();
  }

  /// ===============================================================
  /// Load Paper Trades
  /// ===============================================================

  Future<void> _loadPaperTrades() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _api.getPaperTrades();

      if (!mounted) return;

      setState(() {
        _paperTrade = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  /// ===============================================================
  /// Refresh Paper Trades
  /// ===============================================================

  Future<void> _refreshPaperTrades() async {
    setState(() {
      _refreshing = true;
    });

    try {
      final result = await _api.getPaperTrades();

      if (!mounted) return;

      setState(() {
        _paperTrade = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
        });
      }
    }
  }

  /// ===============================================================
  /// App Bar
  /// ===============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Paper Trading",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      elevation: 0,
      actions: [
        if (_refreshing)
          const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPaperTrades,
          ),
      ],
    );
  }

  /// ===============================================================
  /// Loading Widget
  /// ===============================================================

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  /// ===============================================================
  /// Error Widget
  /// ===============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 70),

            const SizedBox(height: 20),

            const Text(
              "Unable to load paper trading data",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              _error ?? "Unknown error occurred",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _loadPaperTrades,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Empty Widget
  /// ===============================================================

  Widget _buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 70,
              color: Colors.grey,
            ),

            SizedBox(height: 20),

            Text(
              "No Paper Trades Found",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text(
              "Start paper trading to view your virtual trading performance.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Paper Trading Dashboard
  /// ===============================================================

  Widget _buildPaperTradingDashboard() {
    if (_paperTrade == null) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: _refreshPaperTrades,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// ===================================================
            /// Paper Trading Card
            /// ===================================================
            PaperTradeCard(
              paperTrade: _paperTrade!,
              onRefresh: _refreshPaperTrades,
            ),

            const SizedBox(height: 20),

            /// ===================================================
            /// Trading Summary
            /// ===================================================
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Trading Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _summaryTile(
                            "Open",
                            _paperTrade!.openTrades.toString(),
                            Icons.trending_up,
                            Colors.blue,
                          ),
                        ),

                        Expanded(
                          child: _summaryTile(
                            "Closed",
                            _paperTrade!.closedTrades.toString(),
                            Icons.assignment_turned_in,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _summaryTile(
                            "Wins",
                            _paperTrade!.wins.toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ),

                        Expanded(
                          child: _summaryTile(
                            "Losses",
                            _paperTrade!.losses.toString(),
                            Icons.cancel,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Summary Tile
  /// ===============================================================

  Widget _summaryTile(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: color.withOpacity(.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: color),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(title),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Build
  /// ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _loading
            ? _buildLoading()
            : _error != null
            ? _buildError()
            : _buildPaperTradingDashboard(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshPaperTrades,
        tooltip: "Refresh",
        child: _refreshing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.refresh),
      ),
    );
  }
}
