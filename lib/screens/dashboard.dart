import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/dashborad/summary_card.dart';
import '../widgets/dashborad/transaction_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthYear = DateFormat('MMMM yyyy').format(now);

    // Dummy data for demonstration
    final double totalIncome = 5000;
    final double totalExpenses = 3200;
    final double budget = 4000;
    final double remaining = totalIncome - totalExpenses;
    final double budgetUsed = (totalExpenses / budget).clamp(0, 1);

    return Scaffold(
      body: SingleChildScrollView(
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
              height: 120,
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
                    amount: remaining,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Budget Overview
            Text(
              'Monthly Budget Progress',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: budgetUsed,
              minHeight: 14,
              backgroundColor: Colors.grey[200],
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text(
              "You've used ${(budgetUsed * 100).toStringAsFixed(0)}% of your budget.",
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
                    // TODO: Navigate to all transactions
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            ...List.generate(
                3, (index) => const TransactionTile()), // Dummy transactions
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add new transaction
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
