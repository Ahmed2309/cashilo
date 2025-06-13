import 'package:flutter/material.dart';
import 'package:cashilo/models/goals_model.dart';
import 'package:cashilo/models/transaction_model.dart';
import 'package:hive/hive.dart';
import 'package:cashilo/constant.dart';

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
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'Add to Saving',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text(
                    'Distribute Among All',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  value: 'all',
                  groupValue: mode,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => mode = v!),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text(
                    'Single Goal',
                    style: TextStyle(color: AppColors.primaryText),
                  ),
                  value: 'single',
                  groupValue: mode,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => mode = v!),
                  contentPadding: EdgeInsets.zero,
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
                        child: Text(g.name,
                            style:
                                const TextStyle(color: AppColors.primaryText)),
                      ))
                  .toList(),
              onChanged: (g) => setState(() => selectedGoal = g),
              decoration: InputDecoration(
                labelText: 'Goal',
                labelStyle: const TextStyle(color: AppColors.primaryText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              dropdownColor: AppColors.background,
            ),
          const SizedBox(height: 14),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.primaryText),
            decoration: InputDecoration(
              labelText: 'Amount (max \$${widget.balance.toStringAsFixed(2)})',
              labelStyle: const TextStyle(color: AppColors.primaryText),
              prefixIcon:
                  const Icon(Icons.attach_money, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              fillColor: AppColors.card,
              filled: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          child: const Text('Cancel'),
        ),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
