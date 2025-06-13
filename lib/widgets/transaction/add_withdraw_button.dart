import 'package:cashilo/l10n/app_localizations.dart';
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
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.savings, color: Colors.white),
            label: Text(
              AppLocalizations.of(context)!.addToSaving,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 3,
              shadowColor: Colors.deepPurple.withOpacity(0.2),
            ),
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
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.remove_circle, color: Colors.white),
            label: Text(
              AppLocalizations.of(context)!.withdraw,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 3,
              shadowColor: Colors.orange.withOpacity(0.2),
            ),
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
        ),
      ],
    );
  }
}
