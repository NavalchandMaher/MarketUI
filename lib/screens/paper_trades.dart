import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

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