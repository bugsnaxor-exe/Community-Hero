import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class IssueCategoriesChart extends StatelessWidget {
  final List<dynamic> categories;

  const IssueCategoriesChart({super.key, required this.categories});

  Color _getColorForIndex(int index) {
    const colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(child: Text('No category data available'));
    }

    return Column(
      children: [
        const Text('Issues by Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: categories.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return PieChartSectionData(
                  color: _getColorForIndex(index),
                  value: (data['count'] as int).toDouble(),
                  title: '${data['count']}',
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: categories.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 12, height: 12, color: _getColorForIndex(index)),
                const SizedBox(width: 4),
                Text(data['category'], style: const TextStyle(fontSize: 12)),
              ],
            );
          }).toList(),
        )
      ],
    );
  }
}
