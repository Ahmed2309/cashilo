import 'package:flutter/material.dart';
import 'package:cashilo/models/goals_model.dart';
import 'package:cashilo/models/transaction_model.dart';
import 'package:hive/hive.dart';
import 'package:cashilo/constant.dart';

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
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'Withdraw from Saving',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
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
            title: Text(
              'Withdraw from all goals',
              style: const TextStyle(color: AppColors.primaryText),
            ),
            activeColor: AppColors.primary,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          if (!withdrawFromAll)
            DropdownButtonFormField<Goal>(
              value: selectedGoal,
              items: widget.goalsWithSavings
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
              labelText: withdrawFromAll
                  ? 'Amount (max \$${totalSaved.toStringAsFixed(2)})'
                  : selectedGoal != null
                      ? 'Amount (max \$${selectedGoal!.savedAmount.toStringAsFixed(2)})'
                      : 'Amount',
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
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Withdraw'),
        ),
      ],
    );
  }
}
