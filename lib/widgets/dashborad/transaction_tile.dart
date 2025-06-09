import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.deepPurple.withOpacity(0.1),
          child: Icon(Icons.fastfood_rounded, color: Colors.deepPurple),
        ),
        title: const Text('Food & Drinks'),
        subtitle: const Text('June 8, 2025'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              '-\$25.00',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Chip(
              label: Text('Expense', style: TextStyle(fontSize: 12)),
              backgroundColor: Color(0xFFFFE0E0),
              labelStyle: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
