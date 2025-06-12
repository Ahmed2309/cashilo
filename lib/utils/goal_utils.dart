import 'package:cashilo/models/goals_model.dart';
import 'package:cashilo/models/transaction_model.dart';
import 'package:hive/hive.dart';

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
      total += monthlyPortion;
    } else {
      total += g.targetAmount;
    }
  }
  return total;
}

void calculateGoalSavings(List<Goal> goals, double monthlySavingGoal) {
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
