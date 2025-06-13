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
                        final month = sortedMonths[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MMM')
                                .format(DateTime.parse('$month-01')),
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
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.card,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
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
