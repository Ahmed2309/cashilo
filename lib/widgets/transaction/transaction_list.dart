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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 80, color: AppColors.card),
            const SizedBox(height: 16),
            const Text(
              'No transactions yet.\nTap + to add one!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.primaryText, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final tx = transactions[index];
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
