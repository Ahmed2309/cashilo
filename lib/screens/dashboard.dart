import 'package:cashilo/models/goals_model.dart';
import 'package:cashilo/models/transaction_model.dart';
import 'package:cashilo/widgets/dashborad/add_to_saving_dialog.dart';
import 'package:cashilo/widgets/dashborad/summary_card.dart';
import 'package:cashilo/widgets/dashborad/transaction_tile.dart';
import 'package:cashilo/widgets/dashborad/withdraw_from_saving_dialog.dart';
import 'package:cashilo/widgets/transaction/add_transaction_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthYear = DateFormat('MMMM yyyy').format(now);
    final double savingGoal = getTotalPeriodSavingGoal();

    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable:
            Hive.box<TransactionModel>('transactions').listenable(),
        builder: (context, Box<TransactionModel> box, _) {
          final transactions = box.values.toList();

          // Calculate totals from Hive data
          final totalIncome = transactions
              .where((tx) => tx.type.toLowerCase() == 'income')
              .fold<double>(0, (sum, tx) => sum + tx.amount);

          final totalExpenses = transactions
              .where((tx) => tx.type.toLowerCase() == 'expense')
              .fold<double>(0, (sum, tx) => sum + tx.amount);

          final savings = transactions
                  .where((tx) => tx.category == 'Saving')
                  .fold<double>(0, (sum, tx) => sum + tx.amount) -
              transactions
                  .where((tx) => tx.category == 'From Saving')
                  .fold<double>(0, (sum, tx) => sum + tx.amount);

          final savingProgress =
              savingGoal == 0 ? 0.0 : (savings / savingGoal).clamp(0, 1);

          // Recent transactions (latest 3)
          final recentTransactions = List<TransactionModel>.from(transactions)
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

          final availableSavings = savings - savingProgress * savingGoal;
          final monthlySavingGoal = getTotalPeriodSavingGoal();

          final monthlyGoalReached = savingProgress >= 1.0;

          // Only show alert if the monthly goal is NOT already reached
          if (!monthlyGoalReached &&
              availableSavings >= monthlySavingGoal &&
              monthlySavingGoal > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Monthly Saving Goal'),
                  content: Text(
                    'Your balance (\$${availableSavings.toStringAsFixed(2)}) is enough to cover your monthly saving goal (\$${monthlySavingGoal.toStringAsFixed(2)}).\n\nDo you want to move this amount to your savings goals now?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // Do nothing
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _calculateGoalSavings(activeGoals, availableSavings);
                        setState(() {});
                      },
                      child: const Text('Approve'),
                    ),
                  ],
                ),
              );
            });
          }

          return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    monthYear,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 150,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        SummaryCard(
                          icon: Icons.attach_money_rounded,
                          label: 'Income',
                          amount: totalIncome,
                          color: Colors.green,
                        ),
                        SummaryCard(
                          icon: Icons.money_off_rounded,
                          label: 'Expenses',
                          amount: totalExpenses,
                          color: Colors.red,
                        ),
                        SummaryCard(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'Balance',
                          amount: totalIncome - totalExpenses,
                          color: Colors.blue,
                        ),
                        SummaryCard(
                          icon: Icons.savings,
                          label: 'Total Saving',
                          amount: savings,
                          color: Colors.deepPurple,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Saving Goal Progress
                  Text(
                    'Monthly Saving Goal Progress',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: savingProgress.toDouble(),
                    minHeight: 14,
                    backgroundColor: Colors.grey[200],
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    monthlyGoalReached
                        ? "Congratulations! You've reached your monthly saving goal (\$${savingGoal.toStringAsFixed(2)})."
                        : "You've saved ${(savingProgress * 100).toStringAsFixed(0)}% of your goal (\$${savings.toStringAsFixed(2)} / \$${savingGoal.toStringAsFixed(2)}).",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 24),

                  // 4. Recent Transactions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showAll = !showAll;
                          });
                        },
                        child: Text(showAll ? 'Show Less' : 'See All'),
                      ),
                    ],
                  ),
                  ...displayedTransactions
                      .map((tx) => TransactionTile(transaction: tx)),

                  // Add to Saving and Withdraw buttons
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.savings),
                        label: const Text('Add to Saving'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple),
                        onPressed: () {
                          final goalBox = Hive.box<Goal>('goals');
                          final transactionBox =
                              Hive.box<TransactionModel>('transactions');
                          final activeGoals = goalBox.values
                              .where((g) =>
                                  g.savedAmount < g.targetAmount &&
                                  !(g.stopped))
                              .toList();

                          // Calculate balance
                          final transactions = transactionBox.values.toList();
                          final totalIncome = transactions
                              .where((tx) => tx.type.toLowerCase() == 'income')
                              .fold<double>(0, (sum, tx) => sum + tx.amount);
                          final totalExpenses = transactions
                              .where((tx) => tx.type.toLowerCase() == 'expense')
                              .fold<double>(0, (sum, tx) => sum + tx.amount);
                          final balance = totalIncome - totalExpenses;
                          final availableSavings = balance;

                          showDialog(
                            context: context,
                            builder: (context) => AddToSavingDialog(
                              balance: balance,
                              activeGoals: activeGoals,
                              transactionBox: transactionBox,
                              onSaved: () => setState(() {}),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.remove_circle,
                            color: Colors.orange),
                        label: const Text('Withdraw'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange),
                        onPressed: () {
                          final goalBox = Hive.box<Goal>('goals');
                          final transactionBox =
                              Hive.box<TransactionModel>('transactions');
                          final goalsWithSavings = goalBox.values
                              .where((g) => g.savedAmount > 0 && !(g.stopped))
                              .toList();

                          showDialog(
                            context: context,
                            builder: (context) => WithdrawFromSavingDialog(
                              goalsWithSavings: goalsWithSavings,
                              transactionBox: transactionBox,
                              onSaved: () => setState(() {}),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ));
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
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }

  double getTotalPeriodSavingGoal() {
    final goalBox = Hive.box<Goal>('goals');
    final goals = goalBox.values
        .where((g) => g.savedAmount < g.targetAmount && !(g.stopped))
        .toList();

    double total = 0.0;
    for (final g in goals) {
      if (g.startDate != null && g.endDate != null) {
        final days = g.endDate!.difference(g.startDate!).inDays;
        double monthlyPortion = 0.0;
        if (days <= 8) {
          // 1 week: multiply by 4.345 to get monthly equivalent
          monthlyPortion = g.targetAmount * 4.345;
        } else if (days <= 32) {
          // 1 month
          monthlyPortion = g.targetAmount;
        } else if (days <= 95) {
          // 3 months
          monthlyPortion = g.targetAmount / 3.0;
        } else if (days <= 190) {
          // 6 months
          monthlyPortion = g.targetAmount / 6.0;
        } else {
          // 1 year
          monthlyPortion = g.targetAmount / 12.0;
        }
        total += monthlyPortion;
      } else {
        // If no period, just use the full target
        total += g.targetAmount;
      }
    }
    return total;
  }

  void _calculateGoalSavings(List<Goal> goals, double monthlySavingGoal) {
    final transactionBox = Hive.box<TransactionModel>('transactions');
    double totalWeight = goals.fold(0, (sum, g) => sum + g.weight);
    double remainingSavings = monthlySavingGoal;

    for (final goal in goals) {
      final goalBox = Hive.box<Goal>('goals');
      final currentGoal = goalBox.get(goal.key);

      if (currentGoal != null) {
        final allocation = (goal.weight / totalWeight) * monthlySavingGoal;
        final toSave = allocation.clamp(
          0,
          currentGoal.targetAmount - currentGoal.savedAmount,
        );
        if (toSave > 0 && remainingSavings > 0) {
          // Create a transaction for this saving
          transactionBox.add(TransactionModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() +
                goal.key.toString(),
            type: 'Expense',
            amount: toSave.toDouble(),
            category: 'Saving',
            date: DateTime.now(),
            note: 'Auto-save for goal: ${currentGoal.name}',
          ));
          currentGoal.savedAmount += toSave;
          goalBox.put(goal.key, currentGoal);
          remainingSavings -= toSave;
        }
      }
    }

    // If there's any remaining savings, add it to the first goal
    if (remainingSavings > 0 && goals.isNotEmpty) {
      final goalBox = Hive.box<Goal>('goals');
      final firstGoal = goalBox.get(goals.first.key);
      if (firstGoal != null) {
        final toSave = remainingSavings.clamp(
          0,
          firstGoal.targetAmount - firstGoal.savedAmount,
        );
        if (toSave > 0) {
          transactionBox.add(TransactionModel(
            id: DateTime.now().millisecondsSinceEpoch.toString() +
                goals.first.key.toString(),
            type: 'Expense',
            amount: toSave.toDouble(),
            category: 'Saving',
            date: DateTime.now(),
            note: 'Auto-save for goal: ${firstGoal.name}',
          ));
          firstGoal.savedAmount += toSave;
          goalBox.put(goals.first.key, firstGoal);
        }
      }
    }
  }
}
