import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

import 'dart:convert';
import 'config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F1C),
        cardColor: const Color(0xFF111827),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int selectedIndex = 0;

  final pages = [
    Dashboard(),
    PaperTradesPage(),
    LearningPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("AI Trading Platform"),
      ),

      drawer: Drawer(
        child: ListView(
          children: [

            const DrawerHeader(
              child: Text(
                "Market AI",
                style: TextStyle(fontSize: 24),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text("Paper Trades"),
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.psychology),
              title: const Text("Learning"),
              onTap: () {
                setState(() {
                  selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                setState(() {
                  selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      body: pages[selectedIndex],
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String symbol = "BTCUSDT";
  String timeframe = "5m";

  Timer? _timer;

  Map data = {};
  List chart = [];

 // ================= AUTO REFRESH =================
  int refreshInterval() {
    if (timeframe == "1m") return 30000;        // 30 sec
    if (timeframe == "5m") return 150000;       // 2.5 min
    if (timeframe == "15m") return 450000;      // 7.5 min
    if (timeframe == "1h") return 1800000;      // 30 min
    if (timeframe == "4h") return 7200000;      // 2 hours
    if (timeframe == "1d") return 43200000;     // 12 hours
    return 60000;
  }

  void startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(milliseconds: refreshInterval()),
      (timer) => load(),
    );
  }

  @override
  void initState() {
    super.initState();
    load();
    startAutoRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  //Server API :-  "https://began-ranges-medicine-namely.trycloudflare.com/analysis?symbol=$symbol&timeframe=$timeframe"),
  // ================= LOAD =================
  Future load() async {
    final res = await http.get(
      Uri.parse("$baseUrl/analysis?symbol=$symbol&timeframe=$timeframe"),
    );

    final j = json.decode(res.body);

    setState(() {
      data = j;
      chart = j["chart"] ?? [];
    });
  }

  // ================= CHART SPOTS =================
  List<FlSpot> spots(int index) {
    if (chart.isEmpty) return [];
    return List.generate(chart.length, (i) {
      return FlSpot(i.toDouble(), chart[i][index].toDouble());
    });
  }

  Color signalColor() {
    if (data["signal"] == "BUY") return Colors.green;
    if (data["signal"] == "SELL") return Colors.red;
    return Colors.orange;
  }

  // ================= SIGNAL CARD =================
  Widget signalCard() {
    double confidence = (data["confidence"] ?? 0).toDouble();

    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              data["trading_style"] ?? "",
              style: const TextStyle(
                  color: Colors.cyan,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              data["signal"] ?? "WAIT",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: signalColor()),
            ),
            const SizedBox(height: 10),
            Text(
              data["reason"] ?? "",
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 15),
            Text("Confidence ${confidence.toInt()}%"),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: confidence / 100,
              minHeight: 8,
              backgroundColor: Colors.white10,
              color: signalColor(),
            ),
          ],
        ),
      ),
    );
  }

  // ================= PRICE CHART =================
  Widget priceChart() {
    return SizedBox(
      height: 260,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots(1),
              isCurved: true,
              color: Colors.cyanAccent,
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: spots(2),
              color: Colors.orange,
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: spots(3),
              color: Colors.purple,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

Widget indicatorCard() {

  bool emaBull = (data["ema20"] ?? 0) > (data["ema50"] ?? 0);
  bool rsiBull = (data["rsi"] ?? 50) < 40;
  bool rsiBear = (data["rsi"] ?? 50) > 60;
  bool macdBull = (data["macd"] ?? 0) > 0;
  bool adxStrong = (data["adx"] ?? 0) > 25;
  bool pcrBull = (data["pcr"] ?? 1) > 1.2;
  bool pcrBear = (data["pcr"] ?? 1) < 0.8;

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          const Text("Core Indicators",
              style: TextStyle(
                  color: Colors.cyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),

          const SizedBox(height: 15),

          indicatorRow(
              "EMA Trend",
              "${data["ema20"]} / ${data["ema50"]}",
              emaBull ? "BULLISH" : "BEARISH",
              emaBull),

          indicatorRow(
              "RSI",
              data["rsi"],
              rsiBull
                  ? "OVERSOLD ↑"
                  : rsiBear
                      ? "OVERBOUGHT ↓"
                      : "NEUTRAL",
              rsiBull),

          indicatorRow(
              "MACD",
              data["macd"],
              macdBull ? "BULLISH ↑" : "BEARISH ↓",
              macdBull),

          indicatorRow(
              "ADX",
              data["adx"],
              adxStrong ? "STRONG TREND" : "WEAK TREND",
              adxStrong),

          indicatorRow(
              "PCR",
              data["pcr"],
              pcrBull
                  ? "PUT DOMINANT ↑"
                  : pcrBear
                      ? "CALL DOMINANT ↓"
                      : "BALANCED",
              pcrBull),

          indicatorRow(
              "Volume Ratio",
              data["volume_ratio"],
              (data["volume_ratio"] ?? 1) > 1.3
                  ? "HIGH VOLUME ↑"
                  : "LOW VOLUME",
              (data["volume_ratio"] ?? 1) > 1.3),

        ],
      ),
    ),
  );
}

Widget indicatorRow(
    String name, dynamic value, String state, bool bullish) {

  Color stateColor = bullish ? Colors.green : Colors.red;

  if (state.contains("NEUTRAL") ||
      state.contains("BALANCED") ||
      state.contains("WEAK")) {
    stateColor = Colors.orange;
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: const TextStyle(color: Colors.white70)),
            Text(value.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold))
          ],
        ),

        Row(
          children: [
            Icon(
              bullish
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: stateColor,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              state,
              style: TextStyle(
                  color: stateColor,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    ),
  );
}
  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        title: const Text("Pro Market Dashboard"),
      ),
      body: data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: symbol,
                          isExpanded: true,
                          dropdownColor:
                              const Color(0xFF111827),
                          style: const TextStyle(
                              color: Colors.white),
                          items: ["BTCUSDT", "ETHUSDT"]
                              .map((e) =>
                                  DropdownMenuItem<String>(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              symbol = v;
                            });
                            load();
                            startAutoRefresh();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: timeframe,
                          isExpanded: true,
                          dropdownColor:
                              const Color(0xFF111827),
                          style: const TextStyle(
                              color: Colors.white),
                          items: ["1m", "5m", "15m", "1h"]
                              .map((e) =>
                                  DropdownMenuItem<String>(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              timeframe = v;
                            });
                            load();
                            startAutoRefresh();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  signalCard(),
                  const SizedBox(height: 20),
                  priceChart(),
                  const SizedBox(height: 20),
                  indicatorCard(),
                ],
              ),
            ),
    );
  }
}


// ================= PAPER TRADES PAGE =================
class PaperTradesPage extends StatefulWidget {
  const PaperTradesPage({super.key});

  @override
  State<PaperTradesPage> createState() =>
      _PaperTradesPageState();
}

class _PaperTradesPageState
    extends State<PaperTradesPage> {

  Map stats = {};
  List trades = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {

    final statsRes = await http.get(
      Uri.parse(
        "$baseUrl/paper-trades",
      ),
    );

    final historyRes = await http.get(
      Uri.parse(
        "$baseUrl/paper-trades/history",
      ),
    );

    setState(() {
      stats = jsonDecode(statsRes.body);
      trades = jsonDecode(historyRes.body);
    });
  }

  @override
  Widget build(BuildContext context) {

    return ListView(
      padding: const EdgeInsets.all(16),

      children: [

        Card(
          child: ListTile(
            title: Text(
              "Win Rate ${stats["win_rate"] ?? 0}%",
            ),
            subtitle: Text(
              "Profit ${stats["total_profit"] ?? 0}",
            ),
          ),
        ),

        const SizedBox(height: 10),

        ...trades.map(
          (trade) => Card(
            child: ListTile(
              title: Text(
                trade["symbol"],
              ),
              subtitle: Text(
                trade["signal"],
              ),
              trailing: Text(
                trade["pnl"].toString(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
// ================= LEARNING PAGE =================
class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() =>
      _LearningPageState();
}

class _LearningPageState
    extends State<LearningPage> {

  List logs = [];
  Map strategy = {};

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {

    final logsRes = await http.get(
      Uri.parse(
        "$baseUrl/learning-logs",
      ),
    );

    final strategyRes = await http.get(
      Uri.parse(
        "$baseUrl/strategy",
      ),
    );

    setState(() {

      logs = jsonDecode(
        logsRes.body,
      );

      strategy = jsonDecode(
        strategyRes.body,
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return ListView(
      padding: const EdgeInsets.all(16),

      children: [

        Card(
          child: ListTile(
            title: Text(
              strategy["name"] ?? "",
            ),
            subtitle: Text(
              "Version ${strategy["version"]}",
            ),
          ),
        ),

        const SizedBox(height: 10),

        ...logs.map(
          (log) => Card(
            child: ListTile(
              title: Text(
                log["date"],
              ),
              subtitle: Text(
                "Threshold ${log["old_threshold"]} → ${log["new_threshold"]}",
              ),
              trailing: Text(
                "${log["win_rate"]}%",
              ),
            ),
          ),
        )
      ],
    );
  }
}
// ================= SETTINGS PAGE =================
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {

    return ListView(
      children: [

        ListTile(
          title: const Text(
            "Auto Learning",
          ),
          trailing: Switch(
            value: true,
            onChanged: (_) {},
          ),
        ),

        ListTile(
          title: const Text(
            "Paper Trading",
          ),
          trailing: Switch(
            value: true,
            onChanged: (_) {},
          ),
        ),

        ListTile(
          title: const Text(
            "Telegram Alerts",
          ),
          trailing: Switch(
            value: false,
            onChanged: (_) {},
          ),
        ),
      ],
    );
  }
}
