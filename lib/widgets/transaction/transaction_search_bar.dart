import 'package:flutter/material.dart';
import 'package:cashilo/constant.dart';

class TransactionSearchBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onChanged;

  const TransactionSearchBar({
    super.key,
    required this.searchQuery,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        style: const TextStyle(color: AppColors.primaryText),
        decoration: InputDecoration(
          hintText: 'Search by note or category',
          hintStyle: const TextStyle(color: AppColors.primaryText),
          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.card),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          filled: true,
          fillColor: AppColors.card,
          suffixIcon: IconButton(
            icon:
                const Icon(Icons.filter_list_rounded, color: AppColors.primary),
            onPressed: () {},
            tooltip: 'Filter',
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
