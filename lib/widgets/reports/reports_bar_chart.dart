import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashilo/constant.dart';

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
      height: 240,
      child: barGroups.isNotEmpty
          ? BarChart(
              BarChartData(
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          value == 0 ? '' : value.toInt().toString(),
                          style: const TextStyle(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value < 0 || value >= sortedMonths.length) {
                          return const SizedBox.shrink();
                        }
                        final raw = sortedMonths[value.toInt()];
                        String label;
                        try {
                          if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) {
                            // yyyy-MM-dd
                            label =
                                DateFormat('d MMM').format(DateTime.parse(raw));
                          } else if (RegExp(r'^\d{4}-\d{2}$').hasMatch(raw)) {
                            // yyyy-MM
                            label = DateFormat('MMM')
                                .format(DateTime.parse('$raw-01'));
                          } else if (RegExp(r'^\d{2}$').hasMatch(raw)) {
                            // hour
                            label = '$raw:00';
                          } else if (RegExp(r'^[A-Za-z]{3}$').hasMatch(raw)) {
                            // weekday short
                            label = raw;
                          } else {
                            label = raw;
                          }
                        } catch (e) {
                          label = raw;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: AppColors.card,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: AppColors.card, width: 1),
                    bottom: BorderSide(color: AppColors.card, width: 1),
                  ),
                ),
                groupsSpace: 18,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY == 0 ? '' : rod.toY.toStringAsFixed(2),
                        TextStyle(
                          color: rod.color ?? AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ),
                maxY: _getMaxY(barGroups),
              ),
            )
          : const Center(
              child: Text(
                'No monthly data',
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
    );
  }

  double _getMaxY(List<BarChartGroupData> groups) {
    double maxY = 0;
    for (final group in groups) {
      for (final rod in group.barRods) {
        if (rod.toY > maxY) maxY = rod.toY;
      }
    }
    // Add a little headroom
    return maxY == 0 ? 10 : (maxY * 1.2).ceilToDouble();
  }
}
