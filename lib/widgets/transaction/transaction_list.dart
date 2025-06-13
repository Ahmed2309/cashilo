import 'package:flutter/material.dart';
import 'package:cashilo/widgets/transaction/transation_tile_t.dart';
import '../../models/transaction_model.dart';
import 'package:cashilo/constant.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 80, color: AppColors.card),
            SizedBox(height: 16),
            Text(
              'No transactions yet.\nTap + to add one!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.primaryText, fontSize: 18),
            ),
          ],
        ),
      );
    }

    // Sort transactions by date descending (latest first)
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
          category: tx.category,
          note: tx.note,
          amount: tx.amount,
          type: tx.type,
        );
      },
    );
  }
}
