import 'package:cashilo/constant.dart';
import 'package:cashilo/models/goals_model.dart';
import 'package:cashilo/models/transaction_model.dart';
import 'package:cashilo/widgets/dashborad/summary_card.dart';
import 'package:cashilo/widgets/dashborad/transaction_tile.dart';
import 'package:cashilo/widgets/transaction/add_transaction_dialog.dart';
import 'package:cashilo/widgets/transaction/add_withdraw_button.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cashilo/utils/goal_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool showAll = false;
  bool _alertDismissed = false; // <-- Add this flag

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthYear = DateFormat('MMMM yyyy').format(now);
    final double savingGoal = getTotalPeriodSavingGoal();

    return Scaffold(
      backgroundColor: AppColors.background, // Set background color
      body: ValueListenableBuilder(
        valueListenable:
            Hive.box<TransactionModel>('transactions').listenable(),
        builder: (context, Box<TransactionModel> box, _) {
          final transactions = box.values.toList();

          // Filter only today's transactions
          final today = DateTime.now();
          final todayTransactions = transactions
              .where((tx) =>
                  tx.date.year == today.year &&
                  tx.date.month == today.month &&
                  tx.date.day == today.day)
              .toList();

          // Calculate totals from today's transactions
          final totalIncome = todayTransactions
              .where((tx) => tx.type.toLowerCase() == 'income')
              .fold<double>(0, (sum, tx) => sum + tx.amount);

          final totalExpenses = todayTransactions
              .where((tx) => tx.type.toLowerCase() == 'expense')
              .fold<double>(0, (sum, tx) => sum + tx.amount);

          final savings = todayTransactions
                  .where((tx) => tx.category == 'Saving')
                  .fold<double>(0, (sum, tx) => sum + tx.amount) -
              todayTransactions
                  .where((tx) => tx.category == 'From Saving')
                  .fold<double>(0, (sum, tx) => sum + tx.amount);

          final savingProgress =
              savingGoal == 0 ? 0.0 : (savings / savingGoal).clamp(0, 1);

          // Recent transactions (latest 3)
          final recentTransactions =
              List<TransactionModel>.from(todayTransactions)
                ..sort((a, b) => b.date.compareTo(a.date));
          final recent = recentTransactions.take(3).toList();

          // Choose which transactions to show
          final displayedTransactions = showAll ? recentTransactions : recent;

          // Monthly saving goal logic
          final goalBox = Hive.box<Goal>('goals');
          final activeGoals = goalBox.values
              .where((g) =>
                  g.savedAmount < g.targetAmount &&
                  !(g.stopped) &&
                  g.startDate != null &&
                  g.endDate != null)
              .toList();

          final monthlySavingGoal = getTotalPeriodSavingGoal();
          final remainingToCover =
              (monthlySavingGoal - savings).clamp(0, monthlySavingGoal);
          final monthlyGoalReached = remainingToCover == 0;

          // Calculate balance before using it
          final balance = totalIncome - totalExpenses;

          // Only show alert if the monthly goal is NOT already reached and balance can cover it
          if (!_alertDismissed &&
              !monthlyGoalReached &&
              balance >= remainingToCover &&
              remainingToCover > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Monthly Saving Goal'),
                  content: Text(
                    'Your balance (\$${balance.toStringAsFixed(2)}) is enough to cover the remaining monthly saving goal (\$${remainingToCover.toStringAsFixed(2)}).\n\nDo you want to move this amount to your savings goals now?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _alertDismissed = true;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        calculateGoalSavings(
                            activeGoals, remainingToCover.toDouble());
                        setState(() {
                          _alertDismissed = true;
                        });
                      },
                      child: const Text('Approve'),
                    ),
                  ],
                ),
              );
            });
          }

          // Monthly saving goal logic
          final goalsWithSavings = goalBox.values
              .where((g) => g.savedAmount > 0 && !(g.stopped))
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.headline,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  monthYear,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryText,
                      ),
                ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            icon: Icons.attach_money_rounded,
                            label: AppStrings.income,
                            amount: totalIncome,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
                            icon: Icons.money_off_rounded,
                            label: AppStrings.expense,
                            amount: totalExpenses,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SummaryCard(
                            icon: Icons.account_balance_wallet_rounded,
                            label: AppStrings.balance,
                            amount: totalIncome - totalExpenses,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SummaryCard(
                            icon: Icons.savings,
                            label: AppStrings.saving,
                            amount: savings,
                            color: AppColors.headline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.savings_rounded,
                                color: AppColors.primary, size: 28),
                            const SizedBox(width: 10),
                            Text(
                              'Monthly Saving Goal Progress',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.headline,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            LinearProgressIndicator(
                              value: savingProgress.toDouble(),
                              minHeight: 18,
                              backgroundColor: AppColors.card,
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "${(savingProgress * 100).toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          monthlyGoalReached
                              ? "🎉 Congratulations! You've reached your monthly saving goal (\$${savingGoal.toStringAsFixed(2)})."
                              : "You've saved \$${savings.toStringAsFixed(2)} of \$${savingGoal.toStringAsFixed(2)}.",
                          style: TextStyle(
                            color: monthlyGoalReached
                                ? AppColors.secondary
                                : AppColors.primaryText,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Recent Transactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.headline,
                          ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showAll = !showAll;
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                      child: Text(showAll ? 'Show Less' : 'See All'),
                    ),
                  ],
                ),
                displayedTransactions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            'No transactions today.',
                            style: TextStyle(
                              color: AppColors.primaryText,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        children: displayedTransactions
                            .map((tx) => TransactionTile(transaction: tx))
                            .toList(),
                      ),

                SavingActionButtons(
                  balance: balance,
                  activeGoals: activeGoals,
                  goalsWithSavings: goalsWithSavings,
                  transactionBox: Hive.box<TransactionModel>('transactions'),
                  onSaved: () => setState(() {}),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final box = Hive.box<TransactionModel>('transactions');
          showDialog(
            context: context,
            builder: (context) => AddTransactionDialog(transactionBox: box),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
