import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final DateTime date;
  final String category;
  final String note;
  final double amount;
  final String type;

  const TransactionTile({
    super.key,
    required this.date,
    required this.category,
    required this.note,
    required this.amount,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = type == 'Income';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
          child: Icon(
            isIncome
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(category),
        subtitle: Text(
          '${DateFormat.yMMMd().format(date)}${note.isNotEmpty ? ' • $note' : ''}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'}\$${amount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(type, style: TextStyle(fontSize: 12)),
              backgroundColor: isIncome ? Colors.green[50] : Colors.red[50],
              labelStyle:
                  TextStyle(color: isIncome ? Colors.green : Colors.red),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}
