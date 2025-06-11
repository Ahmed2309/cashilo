import 'package:cashilo/models/goals_model.dart';
import 'package:cashilo/widgets/goals/goal_cards.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';
import '../widgets/goals/goal_add_dialog.dart';
import '../widgets/goals/edit_goal_dialog.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late Box<Goal> goalBox;
  late Box<TransactionModel> transactionBox;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    goalBox = Hive.box<Goal>('goals');
    transactionBox = Hive.box<TransactionModel>('transactions');
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addGoal() {
    showDialog(
      context: context,
      builder: (context) => GoalAddDialog(
        onAdd: (name, amount, start, end, priority) {
          final goal = Goal(
            name: name,
            targetAmount: amount,
            savedAmount: 0,
            startDate: start,
            endDate: end,
            priority: priority,
          );
          goalBox.add(goal);
          setState(() {});
        },
      ),
    );
  }

  void _editGoal(Goal goal) {
    showDialog(
      context: context,
      builder: (context) => EditGoalDialog(
        goal: goal,
        onEdit: (name, amount, start, end, priority) {
          goal.name = name;
          goal.targetAmount = amount;
          goal.startDate = start;
          goal.endDate = end;
          goal.priority = priority;
          goal.save();
          setState(() {});
        },
      ),
    );
  }

  void _deleteGoal(Goal goal) async {
    await goal.delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final goals = goalBox.values.toList();

    // Separate goals
    final activeGoals = goals
        .where((g) => !g.stopped && g.savedAmount < g.targetAmount)
        .toList();
    final doneOrStoppedGoals = goals
        .where((g) => g.stopped || g.savedAmount >= g.targetAmount)
        .toList();

    // Calculate total income and expenses
    final transactions = transactionBox.values.toList();
    final totalIncome = transactions
        .where((tx) => tx.type.toLowerCase() == 'income')
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final totalExpenses = transactions
        .where((tx) => tx.type.toLowerCase() == 'expense')
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final availableSavings = totalIncome - totalExpenses;

    // Distribute savings to uncompleted goals by priority
    _calculateGoalSavings(activeGoals, availableSavings);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Goals'),
            Tab(text: 'Stopped/Completed'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: goals.isEmpty
            ? const Center(child: Text('No goals yet. Tap + to add one!'))
            : TabBarView(
                controller: _tabController,
                children: [
                  // Active Goals Tab
                  ListView(
                    children: [
                      ...activeGoals.map((goal) => GoalCard(
                            goal: goal,
                            onAdd: null,
                            completed: false,
                            onStopChanged: (val) {
                              goal.stopped = val ?? false;
                              goal.save();
                              setState(() {});
                            },
                            onEdit: () => _editGoal(goal),
                            onDelete: () => _deleteGoal(goal),
                          )),
                    ],
                  ),
                  // Stopped/Completed Goals Tab
                  ListView(
                    children: [
                      ...doneOrStoppedGoals.map((goal) => GoalCard(
                            goal: goal,
                            completed: goal.savedAmount >= goal.targetAmount,
                            onAdd: null,
                            onStopChanged: null,
                            onEdit: () => _editGoal(goal),
                            onDelete: () => _deleteGoal(goal),
                          )),
                    ],
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGoal,
        backgroundColor: Colors.deepPurple,
        tooltip: 'Add Goal',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Only allocate to uncompleted goals, sorted by priority
  List<Goal> _calculateGoalSavings(List<Goal> goals, double availableSavings) {
    const priorities = ['High', 'Medium', 'Low'];
    List<Goal> sortedGoals = [];
    for (final p in priorities) {
      sortedGoals.addAll(goals.where((g) => g.priority == p));
    }

    double remaining = availableSavings;
    List<Goal> updatedGoals = [];
    for (final goal in sortedGoals) {
      final needed = goal.targetAmount;
      final allocated = remaining >= needed ? needed : remaining;
      updatedGoals.add(
        Goal(
          name: goal.name,
          targetAmount: goal.targetAmount,
          savedAmount: allocated > 0 ? allocated : 0,
          startDate: goal.startDate,
          endDate: goal.endDate,
          priority: goal.priority,
        ),
      );
      remaining -= allocated;
      if (remaining <= 0) break;
    }
    // Add any goals that didn't get savings (if any)
    if (updatedGoals.length < goals.length) {
      updatedGoals.addAll(
          goals.where((g) => !updatedGoals.any((ug) => ug.name == g.name)));
    }
    return updatedGoals;
  }
}
