import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cashilo/constant.dart';

class ReportsPieChart extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final String? title;
  final double? height;
  const ReportsPieChart({
    super.key,
    required this.sections,
    this.title,
    this.height,
  });

  double get totalValue =>
      sections.fold(0, (sum, s) => sum + (s.value > 0 ? s.value : 0));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              title!,
              style: const TextStyle(
                color: AppColors.headline,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        SizedBox(
          height: height ?? 180,
          child: PieChart(
            PieChartData(
              sections: sections
                  .map(
                    (s) => s.copyWith(
                      title: '', // No text in the chart
                    ),
                  )
                  .toList(),
              centerSpaceRadius: 32,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                enabled: true,
                touchCallback: (event, response) {},
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: sections.where((s) => s.value > 0).map((s) {
            final percent = totalValue > 0
                ? ' (${((s.value / totalValue) * 100).toStringAsFixed(1)}%)'
                : '';
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: s.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${s.title.split('\n').first}$percent',
                  style: const TextStyle(
                    color: AppColors.primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Helper to generate pie chart sections for different breakdowns
List<PieChartSectionData> buildMainPieSections({
  required double totalIncome,
  required double totalExpense,
  required double totalSaving,
}) {
  return [
    PieChartSectionData(
      value: totalIncome,
      color: AppColors.secondary,
      title: 'Income',
      radius: 40,
      titleStyle: const TextStyle(
          fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
    ),
    PieChartSectionData(
      value: totalExpense,
      color: AppColors.error,
      title: 'Expense',
      radius: 40,
      titleStyle: const TextStyle(
          fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
    ),
    PieChartSectionData(
      value: totalSaving,
      color: AppColors.primary,
      title: 'Saving',
      radius: 40,
      titleStyle: const TextStyle(
          fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
    ),
  ];
}

List<PieChartSectionData> buildIncomePieSections(
    Map<String, double> incomeMap) {
  final colors = [
    AppColors.secondary,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.teal,
    Colors.purple,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
    Colors.brown,
    Colors.pink,
    Colors.lime,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.redAccent,
    Colors.yellow,
    Colors.grey,
  ];
  int i = 0;
  return incomeMap.entries.map((e) {
    final color = colors[i % colors.length];
    i++;
    return PieChartSectionData(
      value: e.value,
      color: color,
      title: e.key,
      radius: 38,
      titleStyle: const TextStyle(
          fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }).toList();
}

List<PieChartSectionData> buildExpensePieSections(
    Map<String, double> expenseMap) {
  final colors = [
    AppColors.error,
    Colors.redAccent,
    Colors.orange,
    Colors.purple,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
    Colors.brown,
    Colors.pink,
    Colors.lime,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.yellow,
    Colors.grey,
  ];
  int i = 0;
  return expenseMap.entries.map((e) {
    final color = colors[i % colors.length];
    i++;
    return PieChartSectionData(
      value: e.value,
      color: color,
      title: e.key,
      radius: 38,
      titleStyle: const TextStyle(
          fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }).toList();
}
