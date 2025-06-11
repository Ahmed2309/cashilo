import 'package:flutter/material.dart';
import 'package:cashilo/models/goals_model.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final bool completed;
  final VoidCallback? onAdd;
  final ValueChanged<bool?>? onStopChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget? trailing;

  const GoalCard({
    super.key,
    required this.goal,
    required this.completed,
    this.onAdd,
    this.onStopChanged,
    this.onEdit,
    this.onDelete,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(goal.name),
        subtitle: Text('Saved: ${goal.savedAmount} / ${goal.targetAmount}'),
        leading: onStopChanged != null
            ? Checkbox(
                value: goal.stopped,
                onChanged: onStopChanged,
              )
            : null,
        trailing: trailing ??
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: onEdit,
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
              ],
            ),
        onTap: onEdit,
      ),
    );
  }
}
