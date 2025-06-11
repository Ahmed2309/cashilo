import 'package:flutter/material.dart';
import 'package:cashilo/models/goals_model.dart';
import 'package:cashilo/models/transaction_model.dart';
import 'package:hive/hive.dart';

class AddToSavingDialog extends StatefulWidget {
  final double balance;
  final List<Goal> activeGoals;
  final Box<TransactionModel> transactionBox;
  final VoidCallback? onSaved;

  const AddToSavingDialog({
    super.key,
    required this.balance,
    required this.activeGoals,
    required this.transactionBox,
    this.onSaved,
  });

  @override
  State<AddToSavingDialog> createState() => _AddToSavingDialogState();
}

class _AddToSavingDialogState extends State<AddToSavingDialog> {
  String mode = 'all'; // 'all' or 'single'
  Goal? selectedGoal;
  final amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add to Saving'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Distribute Among All'),
                  value: 'all',
                  groupValue: mode,
                  onChanged: (v) => setState(() => mode = v!),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Single Goal'),
                  value: 'single',
                  groupValue: mode,
                  onChanged: (v) => setState(() => mode = v!),
                ),
              ),
            ],
          ),
          if (mode == 'single')
            DropdownButtonFormField<Goal>(
              value: selectedGoal,
              items: widget.activeGoals
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
              labelText: 'Amount (max \$${widget.balance.toStringAsFixed(2)})',
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
            if (value <= 0 || value > widget.balance) return;
            final newId = DateTime.now().millisecondsSinceEpoch;
            if (mode == 'single') {
              if (selectedGoal == null) return;
              final remaining =
                  selectedGoal!.targetAmount - selectedGoal!.savedAmount;
              final addValue = value.clamp(0, remaining);
              if (addValue > 0) {
                widget.transactionBox.add(TransactionModel(
                  id: newId.toString(),
                  type: 'Expense',
                  amount: addValue.toDouble(),
                  category: 'Saving',
                  date: DateTime.now(),
                  note: 'Transfer to saving for ${selectedGoal!.name}',
                ));
                selectedGoal!.savedAmount += addValue;
                selectedGoal!.save();
              }
            } else {
              // Distribute among all goals proportionally to their monthly portion
              List<double> monthlyPortions = [];
              double totalMonthlyPortion = 0.0;
              for (final g in widget.activeGoals) {
                double monthlyPortion = 0.0;
                if (g.startDate != null && g.endDate != null) {
                  final days = g.endDate!.difference(g.startDate!).inDays;
                  if (days <= 8) {
                    monthlyPortion = g.targetAmount * 4.345;
                  } else if (days <= 32) {
                    monthlyPortion = g.targetAmount;
                  } else if (days <= 95) {
                    monthlyPortion = g.targetAmount / 3.0;
                  } else if (days <= 190) {
                    monthlyPortion = g.targetAmount / 6.0;
                  } else {
                    monthlyPortion = g.targetAmount / 12.0;
                  }
                } else {
                  monthlyPortion = g.targetAmount;
                }
                final remaining = g.targetAmount - g.savedAmount;
                monthlyPortion = monthlyPortion.clamp(0, remaining);
                monthlyPortions.add(monthlyPortion);
                totalMonthlyPortion += monthlyPortion;
              }
              double remainingValue = value;
              for (int i = 0; i < widget.activeGoals.length; i++) {
                final g = widget.activeGoals[i];
                final portion = monthlyPortions[i];
                if (portion == 0 || totalMonthlyPortion == 0) continue;
                double alloc = (portion / totalMonthlyPortion) * value;
                alloc = alloc.clamp(0, g.targetAmount - g.savedAmount);
                alloc = alloc.clamp(0, remainingValue);
                if (alloc > 0) {
                  widget.transactionBox.add(TransactionModel(
                    id: (newId + i).toString(),
                    type: 'Expense',
                    amount: alloc,
                    category: 'Saving',
                    date: DateTime.now(),
                    note: 'Transfer to saving for ${g.name}',
                  ));
                  g.savedAmount += alloc;
                  g.save();
                  remainingValue -= alloc;
                  if (remainingValue <= 0) break;
                }
              }
            }
            widget.onSaved?.call();
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
