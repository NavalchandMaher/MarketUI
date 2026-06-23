import 'package:flutter/material.dart';

class SignalCard extends StatelessWidget {

  final Map data;

  const SignalCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {

    double confidence =
        (data["confidence"] ?? 0)
            .toDouble();

    Color signalColor() {

      if (data["signal"] == "BUY") {
        return Colors.green;
      }

      if (data["signal"] == "SELL") {
        return Colors.red;
      }

      return Colors.orange;
    }

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
}