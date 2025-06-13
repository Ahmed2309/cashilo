import 'package:flutter/material.dart';
import 'package:cashilo/models/transaction_model.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cashilo/widgets/reports/reports_pie_charts.dart';
import 'package:cashilo/widgets/reports/reports_bar_chart.dart';
import 'package:cashilo/widgets/reports/monthly_breakdown_list.dart';
import 'package:cashilo/constant.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionBox = Hive.box<TransactionModel>('transactions');
    final transactions = transactionBox.values.toList();

    double totalIncome = 0;
    double totalExpense = 0;
    double totalSaving = 0;

    for (final tx in transactions) {
      if (tx.type.toLowerCase() == 'income') {
        totalIncome += tx.amount;
      } else if (tx.type.toLowerCase() == 'expense') {
        totalExpense += tx.amount;
      }
      if (tx.category == 'Saving') {
        totalSaving += tx.amount;
      }
    }

    // Group transactions by month
    final Map<String, List<TransactionModel>> monthlyGroups = {};
    for (final tx in transactions) {
      final month = DateFormat('yyyy-MM').format(tx.date);
      monthlyGroups.putIfAbsent(month, () => []).add(tx);
    }

    // Prepare data for bar chart (monthly income/expense)
    final sortedMonths = monthlyGroups.keys.toList()..sort();
    final barGroups = <BarChartGroupData>[];
    int i = 0;
    for (final month in sortedMonths) {
      final txs = monthlyGroups[month]!;
      double monthIncome = 0;
      double monthExpense = 0;
      for (final tx in txs) {
        if (tx.type.toLowerCase() == 'income') {
          monthIncome += tx.amount;
        } else if (tx.type.toLowerCase() == 'expense') {
          monthExpense += tx.amount;
        }
      }
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
                toY: monthIncome, color: AppColors.secondary, width: 8),
            BarChartRodData(
                toY: monthExpense, color: AppColors.error, width: 8),
          ],
        ),
      );
      i++;
    }

    // Pie chart for overall breakdown
    final hasPieData = totalIncome > 0 || totalExpense > 0 || totalSaving > 0;
    final pieSections = hasPieData
        ? <PieChartSectionData>[
            PieChartSectionData(
              value: totalIncome,
              color: AppColors.secondary,
              title: AppStrings.income,
              radius: 40,
              titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            PieChartSectionData(
              value: totalExpense,
              color: AppColors.error,
              title: AppStrings.expense,
              radius: 40,
              titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            PieChartSectionData(
              value: totalSaving,
              color: AppColors.primary,
              title: AppStrings.saving,
              radius: 40,
              titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ]
        : [
            PieChartSectionData(
              value: 1,
              color: AppColors.card,
              title: 'No Data',
              radius: 40,
              titleStyle: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.headline,
                ),
          ),
          const SizedBox(height: 12),
          ReportsPieChart(sections: pieSections),
          const SizedBox(height: 24),
          Text(
            'Monthly Income & Expenses',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.headline,
                ),
          ),
          const SizedBox(height: 12),
          ReportsBarChart(barGroups: barGroups, sortedMonths: sortedMonths),
          const SizedBox(height: 24),
          Text(
            'Monthly Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.headline,
                ),
          ),
          const SizedBox(height: 8),
          MonthlyBreakdownList(monthlyGroups: monthlyGroups),
        ],
      ),
    );
  }
}
