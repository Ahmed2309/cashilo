import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportsBarChart extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final List<String> sortedMonths;
  const ReportsBarChart({
    super.key,
    required this.barGroups,
    required this.sortedMonths,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: barGroups.isNotEmpty
          ? BarChart(
              BarChartData(
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value < 0 || value >= sortedMonths.length) {
                          return const SizedBox.shrink();
                        }
                        final month = sortedMonths[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MMM')
                                .format(DateTime.parse('$month-01')),
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                groupsSpace: 16,
                barTouchData: BarTouchData(enabled: false),
              ),
            )
          : const Center(child: Text('No monthly data')),
    );
  }
}
