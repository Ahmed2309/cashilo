import 'package:flutter/material.dart';

class TransactionFilterChips extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeSelected;

  const TransactionFilterChips({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: selectedType == 'All',
            onSelected: (_) => onTypeSelected('All'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Income'),
            selected: selectedType == 'Income',
            onSelected: (_) => onTypeSelected('Income'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Expense'),
            selected: selectedType == 'Expense',
            onSelected: (_) => onTypeSelected('Expense'),
          ),
        ],
      ),
    );
  }
}
