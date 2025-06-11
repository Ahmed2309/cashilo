import 'package:cashilo/widgets/transaction/edit_transation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../models/transaction_model.dart';
import 'transation_tile_t.dart';

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
            Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No transactions yet.\nTap + to add one!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    final transactionBox =
                        Hive.box<TransactionModel>('transactions');
                    final key = transactionBox.keyAt(index);
                    showDialog(
                      context: context,
                      builder: (context) => EditTransactionDialog(
                        transactionBox: transactionBox,
                        transactionKey: key,
                        transaction: tx,
                      ),
                    );
                  },
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    tx.delete();
                  },
                  tooltip: 'Delete',
                ),
              ],
            ),
            title: TransactionTile(
              date: tx.date,
              category: tx.category,
              note: tx.note,
              amount: tx.amount,
              type: tx.type,
            ),
          ),
        );
      },
    );
  }
}
