import 'package:cashilo/widgets/dashborad/add_to_saving_dialog.dart';
import 'package:cashilo/widgets/dashborad/withdraw_from_saving_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cashilo/models/goals_model.dart';
import 'package:cashilo/models/transaction_model.dart';
import 'package:hive/hive.dart';

class SavingActionButtons extends StatelessWidget {
  final double balance;
  final List<Goal> activeGoals;
  final List<Goal> goalsWithSavings;
  final Box<TransactionModel> transactionBox;
  final VoidCallback onSaved;

  const SavingActionButtons({
    super.key,
    required this.balance,
    required this.activeGoals,
    required this.goalsWithSavings,
    required this.transactionBox,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.savings),
          label: const Text('Add to Saving'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddToSavingDialog(
                balance: balance,
                activeGoals: activeGoals,
                transactionBox: transactionBox,
                onSaved: onSaved,
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.remove_circle, color: Colors.orange),
          label: const Text('Withdraw'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => WithdrawFromSavingDialog(
                goalsWithSavings: goalsWithSavings,
                transactionBox: transactionBox,
                onSaved: onSaved,
              ),
            );
          },
        ),
      ],
    );
  }
}
