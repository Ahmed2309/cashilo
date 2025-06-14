import 'package:cashilo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashilo/constant.dart';
import '../../models/transaction_model.dart';
import '../../utils/category_helper.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
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
          getLocalizedCategory(context, transaction.category),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
        subtitle: Text(
          '${DateFormat.yMMMd().format(transaction.date)}'
          '${transaction.note.isNotEmpty ? ' • ${transaction.note}' : ''}',
          style: const TextStyle(color: AppColors.primaryText, fontSize: 13),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$amountPrefix\$${transaction.amount.abs().toStringAsFixed(2)}',
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
                transaction.type == 'Income'
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
