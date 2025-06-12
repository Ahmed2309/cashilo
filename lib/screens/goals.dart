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
        onAdd: (name, amount, start, end) {
          final goal = Goal(
            name: name,
            targetAmount: amount,
            savedAmount: 0,
            startDate: start,
            endDate: end,
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
        onEdit: (name, amount, start, end) {
          goal.name = name;
          goal.targetAmount = amount;
          goal.startDate = start;
          goal.endDate = end;
          goal.save();
          setState(() {});
        },
      ),
    );
  }

  void _deleteGoal(Goal goal) async {
    if (goal.savedAmount > 0) {
      transactionBox.add(TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'Income',
        amount: goal.savedAmount,
        category: 'From Saving',
        date: DateTime.now(),
        note: 'Goal deleted: ${goal.name}',
      ));
    }
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

    return Scaffold(
      appBar: AppBar(
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
                  Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            ...activeGoals.map((goal) => GoalCard(
                                  goal: goal,
                                  onAdd: null,
                                  completed: false,
                                  onStopChanged: (val) {
                                    if (val == true && !goal.stopped) {
                                      // User stopped the goal manually
                                      if (goal.savedAmount > 0) {
                                        transactionBox.add(TransactionModel(
                                          id: DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString(),
                                          type: 'Income',
                                          amount: goal.savedAmount,
                                          category: 'From Saving',
                                          date: DateTime.now(),
                                          note: 'Stopped goal: ${goal.name}',
                                        ));
                                        goal.savedAmount = 0;
                                      }
                                      goal.stopped = true;
                                      goal.save();
                                      setState(() {});
                                    } else if (val == false && goal.stopped) {
                                      // User re-activated the goal (optional: reset progress)
                                      goal.stopped = false;
                                      goal.savedAmount = 0;
                                      goal.save();
                                      setState(() {});
                                    }
                                  },
                                  onEdit: () => _editGoal(goal),
                                  onDelete: () => _deleteGoal(goal),
                                )),
                          ],
                        ),
                      ),
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
                            // Add this:
                            trailing: (goal.stopped &&
                                    goal.savedAmount < goal.targetAmount)
                                ? IconButton(
                                    icon: const Icon(Icons.refresh,
                                        color: Colors.green),
                                    tooltip: 'Reactivate (reset progress)',
                                    onPressed: () {
                                      setState(() {
                                        goal.stopped = false;
                                        goal.savedAmount = 0;
                                        goal.save();
                                      });
                                    },
                                  )
                                : null,
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
}
