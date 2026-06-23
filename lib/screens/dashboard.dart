
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

import '../config.dart';
import '../widgets/signal_card.dart';
import '../widgets/indicator_card.dart';
import '../widgets/price_chart.dart';


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

  Color signalColor() {
    if (data["signal"] == "BUY") return Colors.green;
    if (data["signal"] == "SELL") return Colors.red;
    return Colors.orange;
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
                  SignalCard(data: data),
                  const SizedBox(height: 20),
                  PriceChart(chart: chart),
                  const SizedBox(height: 20),
                  IndicatorCard(data: data),
                ],
              ),
            ),
    );
  }
}