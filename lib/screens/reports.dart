import 'package:flutter/material.dart';
import 'package:cashilo/models/transaction_model.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cashilo/widgets/reports/reports_pie_charts.dart';
import 'package:cashilo/widgets/reports/reports_bar_chart.dart';
import 'package:cashilo/widgets/reports/monthly_breakdown_list.dart';
import 'package:cashilo/constant.dart';

enum ChartRange { today, lastWeek, lastMonth, lastSixMonth, lastYear }

String chartRangeLabel(ChartRange range) {
  switch (range) {
    case ChartRange.today:
      return 'Today';
    case ChartRange.lastWeek:
      return 'Last Week';
    case ChartRange.lastMonth:
      return 'Last Month';
    case ChartRange.lastSixMonth:
      return 'Last 6 Months';
    case ChartRange.lastYear:
      return 'Last Year';
  }
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ChartRange _selectedRange = ChartRange.lastMonth;

  @override
  Widget build(BuildContext context) {
    final transactionBox = Hive.box<TransactionModel>('transactions');
    final allTransactions = transactionBox.values.toList();

    // PIE CHART: Filter transactions by selected range
    DateTime now = DateTime.now();
    DateTime start;
    switch (_selectedRange) {
      case ChartRange.today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case ChartRange.lastWeek:
        start = now.subtract(const Duration(days: 7));
        break;
      case ChartRange.lastMonth:
        start = DateTime(now.year, now.month - 1, now.day);
        break;
      case ChartRange.lastSixMonth:
        start = DateTime(now.year, now.month - 6, now.day);
        break;
      case ChartRange.lastYear:
        start = DateTime(now.year - 1, now.month, now.day);
        break;
    }

    final filteredTransactions = allTransactions
        .where((tx) => tx.date.isAfter(start.subtract(const Duration(days: 1))))
        .toList();

    // PIE CHART DATA
    double totalIncome = 0;
    double totalExpense = 0;
    double totalSaving = 0;
    final Map<String, double> incomeMap = {};
    final Map<String, double> expenseMap = {};

    for (final tx in filteredTransactions) {
      if (tx.type.toLowerCase() == 'income') {
        totalIncome += tx.amount;
        incomeMap[tx.category] = (incomeMap[tx.category] ?? 0) + tx.amount;
      } else if (tx.type.toLowerCase() == 'expense') {
        totalExpense += tx.amount;
        expenseMap[tx.category] = (expenseMap[tx.category] ?? 0) + tx.amount;
      }
      if (tx.category == 'Saving') {
        totalSaving += tx.amount;
      }
    }

    final hasPieData = totalIncome > 0 || totalExpense > 0 || totalSaving > 0;

    final mainPieSections = hasPieData
        ? buildMainPieSections(
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            totalSaving: totalSaving,
          )
        : [
            PieChartSectionData(
              value: 1,
              color: AppColors.card,
              title: 'No Data',
              radius: 40,
              titleStyle: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ];

    final incomePieSections = incomeMap.isNotEmpty
        ? buildIncomePieSections(context, incomeMap)
        : [
            PieChartSectionData(
              value: 1,
              color: AppColors.card,
              title: 'No Data',
              radius: 38,
              titleStyle: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ];

    final expensePieSections = expenseMap.isNotEmpty
        ? buildExpensePieSections(context, expenseMap)
        : [
            PieChartSectionData(
              value: 1,
              color: AppColors.card,
              title: 'No Data',
              radius: 38,
              titleStyle: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ];

    // BAR CHART
    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in allTransactions) {
      final month = DateFormat('yyyy-MM').format(tx.date);
      grouped.putIfAbsent(month, () => []).add(tx);
    }

    final sortedKeys = grouped.keys.toList()..sort();

    final barGroups = <BarChartGroupData>[];
    int i = 0;
    for (final key in sortedKeys) {
      final txs = grouped[key] ?? [];
      double groupIncome = 0;
      double groupExpense = 0;
      for (final tx in txs) {
        if (tx.type.toLowerCase() == 'income') {
          groupIncome += tx.amount;
        } else if (tx.type.toLowerCase() == 'expense') {
          groupExpense += tx.amount;
        }
      }
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
                toY: groupIncome, color: AppColors.secondary, width: 8),
            BarChartRodData(
                toY: groupExpense, color: AppColors.error, width: 8),
          ],
        ),
      );
      i++;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.headline,
                ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Select a date range to view your financial reports.',
            style: TextStyle(
              color: AppColors.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              const Text(
                'Chart Range:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<ChartRange>(
                value: _selectedRange,
                items: ChartRange.values.map((range) {
                  return DropdownMenuItem(
                    value: range,
                    child: Text(chartRangeLabel(range)),
                  );
                }).toList(),
                onChanged: (range) {
                  if (range != null) {
                    setState(() => _selectedRange = range);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ReportsPieChart(
            sections: mainPieSections,
            title: "Income, Expenses & Saving",
            height: 180,
          ),
          const SizedBox(height: 24),
          ReportsPieChart(
            sections: incomePieSections,
            title: "Income Breakdown",
            height: 180,
          ),
          const SizedBox(height: 24),
          ReportsPieChart(
            sections: expensePieSections,
            title: "Expense Breakdown",
            height: 180,
          ),
          const SizedBox(height: 24),
          Text(
            'Monthly Income & Expenses',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.headline,
                ),
          ),
          const SizedBox(height: 12),
          ReportsBarChart(barGroups: barGroups, sortedMonths: sortedKeys),
          const SizedBox(height: 24),
          Text(
            'Monthly Breakdown',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.headline,
                ),
          ),
          const SizedBox(height: 8),
          MonthlyBreakdownList(monthlyGroups: grouped),
        ],
      ),
    );
  }
}
