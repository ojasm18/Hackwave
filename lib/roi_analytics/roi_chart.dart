import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ROISummaryChart extends StatelessWidget {
  final num revenueGenerated;
  final num budgetCommitted;
  final num boothVisits;
  final num clicks;
  final num impressions;
  final num leads;

  const ROISummaryChart({
    super.key,
    required this.revenueGenerated,
    required this.budgetCommitted,
    required this.boothVisits,
    required this.clicks,
    required this.impressions,
    required this.leads,
  });

  double get roiPercentage {
    final budget = budgetCommitted == 0 ? 1 : budgetCommitted;
    return ((revenueGenerated - budgetCommitted) / budget) * 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Booth', boothVisits.toDouble()),
      ('Clicks', clicks.toDouble()),
      ('Imp', impressions.toDouble()),
      ('Leads', leads.toDouble()),
      ('ROI%', roiPercentage),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ROI Dashboard', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(items.length, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(toY: items[i].$2, color: Colors.blueAccent),
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= items.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(items[idx].$1, style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Revenue: $revenueGenerated  |  Budget: $budgetCommitted  |  ROI: ${roiPercentage.toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }
}
