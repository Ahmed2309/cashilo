import 'package:cashilo/models/goals_model.dart';
import 'package:flutter/material.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onAdd;
  final bool completed;
  final ValueChanged<bool?>? onStopChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    this.onAdd,
    this.completed = false,
    this.onStopChanged,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.targetAmount == 0
        ? 0.0
        : (goal.savedAmount / goal.targetAmount).clamp(0, 1);
    return Card(
      color: completed ? Colors.green[50] : null,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Row(
          children: [
            Text(goal.name),
            if (completed)
              const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.check_circle, color: Colors.green),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Period: ${goal.startDate?.toLocal().toString().split(' ')[0] ?? '-'} - ${goal.endDate?.toLocal().toString().split(' ')[0] ?? '-'}',
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: progress.toDouble(),
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              color: completed ? Colors.green : Colors.deepPurple,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 4),
            Text(
              'Saved: \$${goal.savedAmount.toStringAsFixed(2)} / \$${goal.targetAmount.toStringAsFixed(2)} (${(progress * 100).toStringAsFixed(0)}%)',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onStopChanged != null)
              Checkbox(
                value: goal.stopped,
                onChanged: onStopChanged,
                activeColor: Colors.orange,
              ),
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
            if (onAdd != null)
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: onAdd,
                tooltip: 'Add to Savings',
              ),
          ],
        ),
      ),
    );
  }
}
