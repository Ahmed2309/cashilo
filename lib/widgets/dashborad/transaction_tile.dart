import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type.toLowerCase() == 'income';
    final amountPrefix = isIncome ? '+' : '-';
    final amountColor = isIncome ? Colors.green : Colors.red;
    final chipColor =
        isIncome ? const Color(0xFFE0FFE0) : const Color(0xFFFFE0E0);
    final chipTextColor = isIncome ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.withOpacity(0.1),
          child: Icon(
            isIncome
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: Colors.deepPurple,
          ),
        ),
        title: Text(transaction.category),
        subtitle: Text(
          '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}'
          '${transaction.note.isNotEmpty ? " • ${transaction.note}" : ""}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$amountPrefix\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(color: amountColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(
                transaction.type,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: chipColor,
              labelStyle: TextStyle(color: chipTextColor),
            ),
          ],
        ),
      ),
    );
  }
}
