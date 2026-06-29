import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ResolutionRateChart extends StatelessWidget {
  final Map<String, dynamic> stats;

  const ResolutionRateChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final int resolved = stats['resolved_issues'] ?? 0;
    final int pending = stats['pending_issues'] ?? 0;
    final int verified = stats['verified_issues'] ?? 0;

    return Column(
      children: [
        const Text('Overall Resolution Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: BarChart(
            swapAnimationDuration: const Duration(milliseconds: 600),
            swapAnimationCurve: Curves.easeOutCubic,
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (resolved + pending + verified).toDouble() + 5,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text('Pending');
                        case 1:
                          return const Text('Verified');
                        case 2:
                          return const Text('Resolved');
                        default:
                          return const Text('');
                      }
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [BarChartRodData(toY: pending.toDouble(), color: Colors.orange, width: 20, borderRadius: BorderRadius.circular(4))],
                  showingTooltipIndicators: [0],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [BarChartRodData(toY: verified.toDouble(), color: Colors.blue, width: 20, borderRadius: BorderRadius.circular(4))],
                  showingTooltipIndicators: [0],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [BarChartRodData(toY: resolved.toDouble(), color: Colors.green, width: 20, borderRadius: BorderRadius.circular(4))],
                  showingTooltipIndicators: [0],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
