import 'package:cashilo/utils/category_helper.dart';
import 'package:flutter/material.dart';
import 'package:cashilo/widgets/transaction/transation_tile_t.dart';
import 'package:cashilo/models/transaction_model.dart';
import 'package:cashilo/constant.dart';
import 'package:cashilo/l10n/app_localizations.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 80, color: AppColors.card),
            const SizedBox(height: 16),
            Text(
              localizations.noTransactionsToday,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: AppColors.primaryText, fontSize: 18),
            ),
          ],
        ),
      );
    }

    final sortedTransactions = List<TransactionModel>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedTransactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final tx = sortedTransactions[index];
        return TransactionTile(
            date: tx.date,
            category: getLocalizedCategory(context, tx.category),
            note: tx.note,
            amount: tx.amount,
            type: tx.type);
      },
    );
  }
}
