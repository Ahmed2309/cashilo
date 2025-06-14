import 'package:cashilo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashilo/constant.dart';

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
    final amountPrefix = isIncome ? '+' : '-';
    final amountColor = isIncome ? AppColors.secondary : AppColors.error;
    final chipColor = isIncome
        ? AppColors.secondary.withOpacity(0.12)
        : AppColors.error.withOpacity(0.12);
    final chipTextColor = isIncome ? AppColors.secondary : AppColors.error;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: AppColors.card,
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
          category,
          style: const TextStyle(
            color: AppColors.headline,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${DateFormat.yMMMd().format(date)}${note.isNotEmpty ? ' • $note' : ''}',
          style: const TextStyle(color: AppColors.primaryText, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$amountPrefix\$${amount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                type == 'Income'
                    ? AppLocalizations.of(context)!.income
                    : AppLocalizations.of(context)!.expense,
                style: TextStyle(
                  color: chipTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
