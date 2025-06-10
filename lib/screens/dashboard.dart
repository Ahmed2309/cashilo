import 'package:cashilo/models/goals_model.dart';
import 'package:cashilo/models/transaction_model.dart';
import 'package:cashilo/widgets/transaction/add_transaction_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../widgets/dashborad/summary_card.dart';
import '../widgets/dashborad/transaction_tile.dart';

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
    final double savingGoal = getTopPriorityPeriodSavingGoal();

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

          final savings = totalIncome - totalExpenses;
          final savingProgress =
              savingGoal == 0 ? 0.0 : (savings / savingGoal).clamp(0, 1);

          // Recent transactions (latest 3)
          final recentTransactions = List<TransactionModel>.from(transactions)
            ..sort((a, b) => b.date.compareTo(a.date));
          final recent = recentTransactions.take(3).toList();

          // Choose which transactions to show
          final displayedTransactions = showAll ? recentTransactions : recent;

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
                          amount: savings,
                          color: Colors.blue,
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
                    "You've saved ${(savingProgress * 100).toStringAsFixed(0)}% of your goal (\$${savings.toStringAsFixed(2)} / \$${savingGoal.toStringAsFixed(2)}).",
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

  double getTopPriorityGoalSavedAmount() {
    final goalBox = Hive.box<Goal>('goals');
    final goals = goalBox.values.toList();

    const priorities = ['High', 'Medium', 'Low'];
    for (final priority in priorities) {
      final filtered = goals.where((g) => g.priority == priority).toList();
      if (filtered.isNotEmpty) {
        return filtered.fold(0.0, (sum, g) => sum + (g.savedAmount));
      }
    }
    return 0.0;
  }

  double getTopPrioritySavingGoal() {
    final goalBox = Hive.box<Goal>('goals');
    final goals =
        goalBox.values.where((g) => g.savedAmount < g.targetAmount).toList();

    const priorities = ['High', 'Medium', 'Low'];
    for (final priority in priorities) {
      final filtered = goals.where((g) => g.priority == priority).toList();
      if (filtered.isNotEmpty) {
        return filtered.fold(0.0, (sum, g) => sum + g.targetAmount);
      }
    }
    return 0.0;
  }

  double getTopPriorityMonthlySavingGoal() {
    final goalBox = Hive.box<Goal>('goals');
    final goals = goalBox.values
        .where((g) => g.savedAmount < g.targetAmount && !(g.stopped))
        .toList();

    const priorities = ['High', 'Medium', 'Low'];
    for (final priority in priorities) {
      final filtered = goals.where((g) => g.priority == priority).toList();
      if (filtered.isNotEmpty) {
        double total = 0.0;
        for (final g in filtered) {
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
    }
    return 0.0;
  }

  double getTopPriorityPeriodSavingGoal() {
    final goalBox = Hive.box<Goal>('goals');
    final goals = goalBox.values
        .where((g) => g.savedAmount < g.targetAmount && !(g.stopped))
        .toList();

    const priorities = ['High', 'Medium', 'Low'];
    for (final priority in priorities) {
      final filtered = goals.where((g) => g.priority == priority).toList();
      if (filtered.isNotEmpty) {
        double total = 0.0;
        for (final g in filtered) {
          // Calculate period length in months
          if (g.startDate != null && g.endDate != null) {
            final days = g.endDate!.difference(g.startDate!).inDays;
            double periodCount = 1;
            if (days <= 8) {
              periodCount = (days / 7).ceilToDouble(); // treat as weeks
              total += g.targetAmount / periodCount;
            } else if (days <= 32) {
              periodCount = (days / 30).ceilToDouble(); // treat as months
              total += g.targetAmount / periodCount;
            } else if (days <= 95) {
              periodCount = (days / 90).ceilToDouble(); // treat as 3 months
              total += g.targetAmount / periodCount;
            } else if (days <= 190) {
              periodCount = (days / 180).ceilToDouble(); // treat as 6 months
              total += g.targetAmount / periodCount;
            } else {
              periodCount = (days / 365).ceilToDouble(); // treat as year
              total += g.targetAmount / periodCount;
            }
          } else {
            // If no period, just use the full target
            total += g.targetAmount;
          }
        }
        return total;
      }
    }
    return 0.0;
  }
}
