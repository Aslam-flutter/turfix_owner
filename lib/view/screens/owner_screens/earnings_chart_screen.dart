import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:turfix_owner/model/earning_model.dart';

class EarningsChart extends StatelessWidget {
  final List<EarningsModel> earnings;

  const EarningsChart({super.key, required this.earnings});

  @override
  Widget build(BuildContext context) {
    if (earnings.isEmpty) {
      return const Center(
        child: Text("No earnings recorded for this period"),
      );
    }

    double maxVal = earnings.map((e) => e.amount).reduce(max);
    if (maxVal <= 0) maxVal = 1000;
    // Round up to nearest thousand for chart ceiling
    final double maxY = ((maxVal / 1000).ceil() * 1000).toDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (earnings.length > 1 ? earnings.length - 1 : 1).toDouble(),
        minY: 0,
        maxY: maxY > 0 ? maxY : 5000,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY / 4) > 0 ? (maxY / 4) : 1000,
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
              interval: (maxY / 4) > 0 ? (maxY / 4) : 1000,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  "₹${(value / 1000).toStringAsFixed(1)}k",
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final int idx = value.toInt();
                if (idx < 0 || idx >= earnings.length) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    earnings[idx].day,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              earnings.length,
              (index) => FlSpot(index.toDouble(), earnings[index].amount),
            ),
            isCurved: true,
            color: const Color(0xff16A34A),
            barWidth: 3,
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
