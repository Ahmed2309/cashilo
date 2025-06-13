import 'package:flutter/material.dart';
import 'package:cashilo/constant.dart';

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
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.card,
            labelStyle: TextStyle(
              color:
                  selectedType == 'All' ? Colors.white : AppColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
            onSelected: (_) => onTypeSelected('All'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color:
                    selectedType == 'All' ? AppColors.primary : AppColors.card,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Income'),
            selected: selectedType == 'Income',
            selectedColor: AppColors.secondary,
            backgroundColor: AppColors.card,
            labelStyle: TextStyle(
              color: selectedType == 'Income'
                  ? Colors.white
                  : AppColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
            onSelected: (_) => onTypeSelected('Income'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: selectedType == 'Income'
                    ? AppColors.secondary
                    : AppColors.card,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Expense'),
            selected: selectedType == 'Expense',
            selectedColor: AppColors.error,
            backgroundColor: AppColors.card,
            labelStyle: TextStyle(
              color: selectedType == 'Expense'
                  ? Colors.white
                  : AppColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
            onSelected: (_) => onTypeSelected('Expense'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: selectedType == 'Expense'
                    ? AppColors.error
                    : AppColors.card,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
