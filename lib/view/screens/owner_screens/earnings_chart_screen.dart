import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:turfix_owner/model/earning_model.dart';

class EarningsChart extends StatelessWidget {
  const EarningsChart({super.key});

  @override
  Widget build(BuildContext context) {
    final weeklyEarnings = [
      EarningsModel(day: "Mon", amount: 3700),
      EarningsModel(day: "Tue", amount: 1800),
      EarningsModel(day: "Wed", amount: 2900),
      EarningsModel(day: "Thu", amount: 7600),
      EarningsModel(day: "Fri", amount: 3100),
      EarningsModel(day: "Sat", amount: 5200),
      EarningsModel(day: "Sun", amount: 6400),
    ];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 8000,

        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2000,
        ),

        borderData: FlBorderData(show: false),

        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2000,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                return Text(
                  "₹${(value / 1000).toInt()}k",
                  style: const TextStyle(fontSize: 11),
                );
              },
            ),
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    days[value.toInt()],
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              weeklyEarnings.length,
              (index) => FlSpot(index.toDouble(), weeklyEarnings[index].amount),
            ),

            isCurved: true,

            color: const Color(0xff16A34A),

            barWidth: 4,

            isStrokeCapRound: true,

            dotData: const FlDotData(show: true),

            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xff16A34A).withValues(alpha: .15),
            ),
          ),
        ],
      ),
    );
  }
}
