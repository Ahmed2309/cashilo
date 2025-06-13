import 'package:cashilo/l10n/app_localizations.dart';
import 'package:cashilo/models/goals_model.dart';
import 'package:cashilo/widgets/goals/goal_cards.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction_model.dart';
import '../widgets/goals/goal_add_dialog.dart';
import '../widgets/goals/edit_goal_dialog.dart';
import 'package:cashilo/constant.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryText),
        title: Text(
          AppLocalizations.of(context)!.myGoal,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.headline,
              ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.primaryText,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: AppLocalizations.of(context)!.activeGoals),
            Tab(text: AppLocalizations.of(context)!.doneOrStoppedGoals),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: goals.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flag_rounded,
                        size: 60, color: AppColors.card),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noGoalsYet,
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
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
        backgroundColor: AppColors.primary,
        tooltip: 'Add Goal',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
