import 'package:flutter/material.dart';
import 'package:cashilo/constant.dart';
import '../../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type.toLowerCase() == 'income';
    final amountPrefix = isIncome ? '+' : '-';
    final amountColor = isIncome ? AppColors.secondary : AppColors.error;
    final chipColor = isIncome
        ? AppColors.secondary.withOpacity(0.12)
        : AppColors.error.withOpacity(0.12);
    final chipTextColor = isIncome ? AppColors.secondary : AppColors.error;

    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.10),
          child: Icon(
            isIncome
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          transaction.category,
          style: TextStyle(
            color: AppColors.headline,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}'
          '${transaction.note.isNotEmpty ? " • ${transaction.note}" : ""}',
          style: TextStyle(color: AppColors.primaryText, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$amountPrefix\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(
                transaction.type,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
              backgroundColor: chipColor,
              labelStyle: TextStyle(color: chipTextColor),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
