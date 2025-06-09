import 'package:flutter/material.dart';

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
        decoration: InputDecoration(
          hintText: 'Search by note or category',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
