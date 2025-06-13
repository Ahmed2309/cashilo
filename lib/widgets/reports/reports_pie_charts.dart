import 'package:cashilo/l10n/app_localizations.dart';
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
        // Show total amount
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Total: \$${totalValue.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
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
    BuildContext context, Map<String, double> incomeMap) {
  final income = AppLocalizations.of(context)!.incomeCategories;
  final colors = incomeCategoryColors;

  return incomeMap.entries.map((e) {
    final idx = income.indexOf(e.key);
    final color = colors[idx % colors.length];
    return PieChartSectionData(
      value: e.value,
      color: color,
      title: e.key,
      radius: 38,
      titleStyle: const TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }).toList();
}

List<PieChartSectionData> buildExpensePieSections(
    BuildContext context, Map<String, double> expenseMap) {
  final expenses = AppLocalizations.of(context)!.expenseCategories;
  final colors = expenseCategoryColors;

  return expenseMap.entries.map((e) {
    final idx = expenses.indexOf(e.key);
    final color = colors[idx % colors.length];
    return PieChartSectionData(
      value: e.value,
      color: color,
      title: e.key,
      radius: 38,
      titleStyle: const TextStyle(
        fontSize: 12,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }).toList();
}
