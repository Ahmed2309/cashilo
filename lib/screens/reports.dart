import 'package:flutter/material.dart';
import 'package:cashilo/models/transaction_model.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

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
            BarChartRodData(toY: monthIncome, color: Colors.green, width: 8),
            BarChartRodData(toY: monthExpense, color: Colors.red, width: 8),
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
              color: Colors.green,
              title: 'Income',
              radius: 40,
              titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            PieChartSectionData(
              value: totalExpense,
              color: Colors.red,
              title: 'Expense',
              radius: 40,
              titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            PieChartSectionData(
              value: totalSaving,
              color: Colors.deepPurple,
              title: 'Saving',
              radius: 40,
              titleStyle: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ]
        : [
            PieChartSectionData(
              value: 1,
              color: Colors.grey[300]!,
              title: 'No Data',
              radius: 40,
              titleStyle: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Overview',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: pieSections,
                centerSpaceRadius: 32,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Monthly Income & Expenses',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
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
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      groupsSpace: 16,
                      barTouchData: BarTouchData(enabled: false),
                    ),
                  )
                : Center(child: Text('No monthly data')),
          ),
          const SizedBox(height: 24),
          Text(
            'Monthly Breakdown',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...monthlyGroups.entries.map((entry) {
            final month = entry.key;
            final txs = entry.value;
            double monthIncome = 0;
            double monthExpense = 0;
            double monthSaving = 0;
            for (final tx in txs) {
              if (tx.type.toLowerCase() == 'income') {
                monthIncome += tx.amount;
              } else if (tx.type.toLowerCase() == 'expense') {
                monthExpense += tx.amount;
              }
              if (tx.category == 'Saving') {
                monthSaving += tx.amount;
              }
            }
            return Card(
              child: ListTile(
                title: Text(DateFormat('MMMM yyyy')
                    .format(DateTime.parse('$month-01'))),
                subtitle: Text(
                  'Income: \$${monthIncome.toStringAsFixed(2)}\n'
                  'Expenses: \$${monthExpense.toStringAsFixed(2)}\n'
                  'Saved: \$${monthSaving.toStringAsFixed(2)}',
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
