import 'package:flutter/material.dart';
import 'package:cashilo/models/goals_model.dart';

class EditGoalDialog extends StatefulWidget {
  final Goal goal;
  final void Function(String name, double amount, DateTime? start,
      DateTime? end, String priority) onEdit;

  const EditGoalDialog({
    super.key,
    required this.goal,
    required this.onEdit,
  });

  @override
  State<EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends State<EditGoalDialog> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late String _priority;
  late String _period;

  static const List<String> periods = [
    '1 Month',
    '3 Months',
    '6 Months',
    '1 Year',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal.name);
    _amountController =
        TextEditingController(text: widget.goal.targetAmount.toString());
    _priority = widget.goal.priority;
    _period = _getPeriodFromDates(widget.goal.startDate, widget.goal.endDate) ??
        '1 Month';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String? _getPeriodFromDates(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    final days = end.difference(start).inDays;
    if (days <= 32) return '1 Month';
    if (days <= 95) return '3 Months';
    if (days <= 190) return '6 Months';
    return '1 Year';
  }

  DateTime? _calculateEndDate(String period) {
    final now = DateTime.now();
    switch (period) {
      case '1 Month':
        return DateTime(now.year, now.month + 1, now.day);
      case '3 Months':
        return DateTime(now.year, now.month + 3, now.day);
      case '6 Months':
        return DateTime(now.year, now.month + 6, now.day);
      case '1 Year':
        return DateTime(now.year + 1, now.month, now.day);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Goal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Goal Name'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Target Amount'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _period,
              items: periods
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) => setState(() => _period = val ?? '1 Month'),
              decoration: const InputDecoration(labelText: 'Period'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _priority,
              items: const [
                DropdownMenuItem(value: 'Low', child: Text('Low')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'High', child: Text('High')),
              ],
              onChanged: (val) => setState(() => _priority = val ?? 'Medium'),
              decoration: const InputDecoration(labelText: 'Priority'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _amountController.text.isNotEmpty) {
              final now = DateTime.now();
              final endDate = _calculateEndDate(_period);
              widget.onEdit(
                _nameController.text,
                double.tryParse(_amountController.text) ?? 0,
                now,
                endDate,
                _priority,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
