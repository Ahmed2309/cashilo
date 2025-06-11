import 'package:flutter/material.dart';
import 'package:cashilo/models/goals_model.dart';
import 'package:cashilo/models/transaction_model.dart';
import 'package:hive/hive.dart';

class WithdrawFromSavingDialog extends StatefulWidget {
  final List<Goal> goalsWithSavings;
  final Box<TransactionModel> transactionBox;
  final VoidCallback? onSaved;

  const WithdrawFromSavingDialog({
    super.key,
    required this.goalsWithSavings,
    required this.transactionBox,
    this.onSaved,
  });

  @override
  State<WithdrawFromSavingDialog> createState() =>
      _WithdrawFromSavingDialogState();
}

class _WithdrawFromSavingDialogState extends State<WithdrawFromSavingDialog> {
  Goal? selectedGoal;
  final amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Withdraw from Saving'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Goal>(
            value: selectedGoal,
            items: widget.goalsWithSavings
                .map((g) => DropdownMenuItem(
                      value: g,
                      child: Text(g.name),
                    ))
                .toList(),
            onChanged: (g) => setState(() => selectedGoal = g),
            decoration: const InputDecoration(labelText: 'Goal'),
          ),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Amount'),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (selectedGoal != null) {
              final maxWithdraw = selectedGoal!.savedAmount;
              final value = double.tryParse(amountController.text) ?? 0;
              if (value > 0 && value <= maxWithdraw) {
                final newId = DateTime.now().millisecondsSinceEpoch;
                widget.transactionBox.add(TransactionModel(
                  id: newId.toString(),
                  type: 'Income',
                  amount: value,
                  category: 'From Saving',
                  date: DateTime.now(),
                  note: 'Withdraw from saving for ${selectedGoal!.name}',
                ));
                selectedGoal!.savedAmount -= value;
                selectedGoal!.save();
                widget.onSaved?.call();
                Navigator.pop(context);
              }
            }
          },
          child: const Text('Withdraw'),
        ),
      ],
    );
  }
}
