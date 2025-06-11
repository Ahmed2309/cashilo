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
  bool withdrawFromAll = false;

  @override
  Widget build(BuildContext context) {
    final totalSaved = widget.goalsWithSavings
        .fold<double>(0, (sum, g) => sum + g.savedAmount);

    return AlertDialog(
      title: const Text('Withdraw from Saving'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            value: withdrawFromAll,
            onChanged: (val) {
              setState(() {
                withdrawFromAll = val ?? false;
                if (withdrawFromAll) selectedGoal = null;
              });
            },
            title: const Text('Withdraw from all goals'),
          ),
          if (!withdrawFromAll)
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
            decoration: InputDecoration(
              labelText: withdrawFromAll
                  ? 'Amount (max \$${totalSaved.toStringAsFixed(2)})'
                  : selectedGoal != null
                      ? 'Amount (max \$${selectedGoal!.savedAmount.toStringAsFixed(2)})'
                      : 'Amount',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final value = double.tryParse(amountController.text) ?? 0;
            if (withdrawFromAll) {
              if (value > 0 && value <= totalSaved) {
                double remaining = value;
                final total = widget.goalsWithSavings
                    .fold<double>(0, (sum, g) => sum + g.savedAmount);
                for (final g in widget.goalsWithSavings) {
                  if (remaining <= 0) break;
                  final portion = g.savedAmount / total;
                  double take = (portion * value).clamp(0, g.savedAmount);
                  if (take > remaining) take = remaining;
                  if (take > 0) {
                    widget.transactionBox.add(TransactionModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString() +
                          g.key.toString(),
                      type: 'Income',
                      amount: take,
                      category: 'From Saving',
                      date: DateTime.now(),
                      note: 'Withdraw from saving for ${g.name}',
                    ));
                    g.savedAmount -= take;
                    g.save();
                    remaining -= take;
                  }
                }
                widget.onSaved?.call();
                Navigator.pop(context);
              }
            } else if (selectedGoal != null) {
              final maxWithdraw = selectedGoal!.savedAmount;
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
