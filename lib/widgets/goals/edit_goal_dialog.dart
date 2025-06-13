import 'package:flutter/material.dart';
import 'package:cashilo/models/goals_model.dart';
import 'package:cashilo/constant.dart';

class EditGoalDialog extends StatefulWidget {
  final Goal goal;
  final void Function(
    String name,
    double amount,
    DateTime? start,
    DateTime? end,
  ) onEdit;

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: AppColors.background,
      title: const Text(
        'Edit Goal',
        style: TextStyle(
          color: AppColors.headline,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Goal Name',
                labelStyle: const TextStyle(color: AppColors.primaryText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Target Amount',
                labelStyle: const TextStyle(color: AppColors.primaryText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _period,
              items: periods
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) => setState(() => _period = val ?? '1 Month'),
              decoration: InputDecoration(
                labelText: 'Period',
                labelStyle: const TextStyle(color: AppColors.primaryText),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.error)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _amountController.text.isNotEmpty) {
              final now = DateTime.now();
              final endDate = _calculateEndDate(_period);
              widget.onEdit(_nameController.text,
                  double.tryParse(_amountController.text) ?? 0, now, endDate);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
