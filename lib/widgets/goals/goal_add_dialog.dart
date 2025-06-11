import 'package:flutter/material.dart';

class GoalAddDialog extends StatefulWidget {
  final void Function(
      String name, double amount, DateTime? start, DateTime? end) onAdd;

  const GoalAddDialog({super.key, required this.onAdd});

  @override
  State<GoalAddDialog> createState() => _GoalAddDialogState();
}

class _GoalAddDialogState extends State<GoalAddDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _period = '1 Month';

  static const List<String> periods = [
    '1 Month',
    '3 Months',
    '6 Months',
    '1 Year',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
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
      title: const Text('Add Goal'),
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
              widget.onAdd(
                _nameController.text,
                double.tryParse(_amountController.text) ?? 0,
                now,
                endDate,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
