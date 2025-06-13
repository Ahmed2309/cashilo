import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashilo/models/transaction_model.dart';

class MonthlyBreakdownList extends StatelessWidget {
  final Map<String, List<TransactionModel>> monthlyGroups;
  const MonthlyBreakdownList({super.key, required this.monthlyGroups});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: monthlyGroups.entries.map((entry) {
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
            title: Text(
                DateFormat('MMMM yyyy').format(DateTime.parse('$month-01'))),
            subtitle: Text(
              'Income: \$${monthIncome.toStringAsFixed(2)}\n'
              'Expenses: \$${monthExpense.toStringAsFixed(2)}\n'
              'Saved: \$${monthSaving.toStringAsFixed(2)}',
            ),
          ),
        );
      }).toList(),
    );
  }
}
