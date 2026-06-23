
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';


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