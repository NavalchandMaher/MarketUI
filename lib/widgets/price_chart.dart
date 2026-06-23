import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PriceChart extends StatelessWidget {

  final List chart;

  const PriceChart({
    super.key,
    required this.chart,
  });

  List<FlSpot> spots(int index) {

    if (chart.isEmpty) {
      return [];
    }

    return List.generate(
      chart.length,
      (i) => FlSpot(
        i.toDouble(),
        (chart[i][index] ?? 0).toDouble(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

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
}