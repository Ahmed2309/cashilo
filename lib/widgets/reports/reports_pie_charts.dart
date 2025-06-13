import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportsPieChart extends StatelessWidget {
  final List<PieChartSectionData> sections;
  const ReportsPieChart({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 32,
          sectionsSpace: 2,
        ),
      ),
    );
  }
}
