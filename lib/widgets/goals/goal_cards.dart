import 'package:flutter/material.dart';
import 'package:cashilo/models/goals_model.dart';
import 'package:cashilo/constant.dart';

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
    final percent = (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0);
    return Card(
      color: completed ? AppColors.secondary.withOpacity(0.12) : AppColors.card,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  completed ? Icons.emoji_events_rounded : Icons.flag_rounded,
                  color: completed ? AppColors.secondary : AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          goal.name,
                          style: TextStyle(
                            color: AppColors.headline,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onEdit != null)
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: AppColors.primary),
                          onPressed: onEdit,
                          tooltip: 'Edit',
                        ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                  ),
                if (onStopChanged != null)
                  Checkbox(
                    value: goal.stopped,
                    onChanged: onStopChanged,
                    activeColor: AppColors.primary,
                  ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                LinearProgressIndicator(
                  value: percent,
                  minHeight: 18,
                  backgroundColor: AppColors.card,
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "${(percent * 100).toStringAsFixed(0)}%",
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
              'Saved: \$${goal.savedAmount.toStringAsFixed(2)} / \$${goal.targetAmount.toStringAsFixed(2)}',
              style: TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (completed)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  '🎉 Goal Completed!',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
