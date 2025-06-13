import 'package:flutter/material.dart';
import 'package:cashilo/models/transaction_model.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cashilo/widgets/reports/reports_pie_charts.dart';
import 'package:cashilo/widgets/reports/reports_bar_chart.dart';
import 'package:cashilo/widgets/reports/monthly_breakdown_list.dart';
import 'package:cashilo/constant.dart';

enum ChartRange { day, week, month, sixMonth, year }

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ChartRange _selectedRange = ChartRange.month;

  @override
  Widget build(BuildContext context) {
    final transactionBox = Hive.box<TransactionModel>('transactions');
    final transactions = transactionBox.values.toList();

    // Filter transactions by selected range
    DateTime now = DateTime.now();
    DateTime start;
    switch (_selectedRange) {
      case ChartRange.day:
        start = DateTime(now.year, now.month, now.day);
        break;
      case ChartRange.week:
        start = now.subtract(Duration(days: now.weekday - 1));
        break;
      case ChartRange.month:
        start = DateTime(now.year, now.month);
        break;
      case ChartRange.sixMonth:
        start = DateTime(now.year, now.month - 5);
        break;
      case ChartRange.year:
        start = DateTime(now.year);
        break;
    }
    final filteredTransactions = transactions.where((tx) => tx.date.isAfter(start.subtract(const Duration(days: 1)))).toList();

    double totalIncome = 0;
    double totalExpense = 0;
    double totalSaving = 0;

    // For income/expense breakdown by category
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

    // Group transactions by selected range
    final Map<String, List<TransactionModel>> grouped;
    List<String> sortedKeys;
    if (_selectedRange == ChartRange.day) {
      grouped = {};
      for (final tx in filteredTransactions) {
        final hour = DateFormat('HH').format(tx.date);
        grouped.putIfAbsent(hour, () => []).add(tx);
      }
      sortedKeys = grouped.keys.toList()..sort();
    } else if (_selectedRange == ChartRange.week) {
      grouped = {};
      for (final tx in filteredTransactions) {
        final day = DateFormat('EEE').format(tx.date);
        grouped.putIfAbsent(day, () => []).add(tx);
      }
      sortedKeys = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    } else if (_selectedRange == ChartRange.month || _selectedRange == ChartRange.sixMonth) {
      grouped = {};
      for (final tx in filteredTransactions) {
        final day = DateFormat('yyyy-MM-dd').format(tx.date);
        grouped.putIfAbsent(day, () => []).add(tx);
      }
      sortedKeys = grouped.keys.toList()..sort();
    } else {
      grouped = {};
      for (final tx in filteredTransactions) {
        final month = DateFormat('yyyy-MM').format(tx.date);
        grouped.putIfAbsent(month, () => []).add(tx);
      }
      sortedKeys = grouped.keys.toList()..sort();
    }

    // Prepare data for bar chart
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

    // Pie chart for overall breakdown
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
        ? buildIncomePieSections(incomeMap)
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
        ? buildExpensePieSections(expenseMap)
        : [
            PieChartSectionData(
              value: 1,
              color: AppColors.card,
              title: 'No Data',
              radius: 38,
              titleStyle: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
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
          // Timeline filter
          Row(
            children: [
              FilterChip(
                label: const Text('Day'),
                selected: _selectedRange == ChartRange.day,
                onSelected: (_) => setState(() => _selectedRange = ChartRange.day),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Week'),
                selected: _selectedRange == ChartRange.week,
                onSelected: (_) => setState(() => _selectedRange = ChartRange.week),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Month'),
                selected: _selectedRange == ChartRange.month,
                onSelected: (_) => setState(() => _selectedRange = ChartRange.month),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('6 Month'),
                selected: _selectedRange == ChartRange.sixMonth,
                onSelected: (_) => setState(() => _selectedRange = ChartRange.sixMonth),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Year'),
                selected: _selectedRange == ChartRange.year,
                onSelected: (_) => setState(() => _selectedRange = ChartRange.year),
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
            'Income & Expenses (${_selectedRange.name[0].toUpperCase()}${_selectedRange.name.substring(1)})',
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
