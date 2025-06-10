import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../models/transaction_model.dart';

class AddTransactionDialog extends StatefulWidget {
  final Box<TransactionModel> transactionBox;
  const AddTransactionDialog({super.key, required this.transactionBox});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  String type = 'Income';
  String category = 'Salary';
  double amount = 0;
  DateTime date = DateTime.now();

  final List<String> incomeCategories = [
    'Salary',
    'Bonus',
    'Investment',
    'Other'
  ];
  final List<String> expenseCategories = [
    'Food',
    'Shopping',
    'Bills',
    'Transport',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    final categories = type == 'Income' ? incomeCategories : expenseCategories;

    return AlertDialog(
      title: const Text('Add Transaction'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'Income', child: Text('Income')),
                  DropdownMenuItem(value: 'Expense', child: Text('Expense')),
                ],
                onChanged: (val) {
                  setState(() {
                    type = val ?? 'Income';
                    category = (type == 'Income'
                            ? incomeCategories
                            : expenseCategories)
                        .first;
                  });
                },
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              DropdownButtonFormField<String>(
                value: category,
                items: categories
                    .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => category = val ?? categories.first),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onChanged: (val) => amount = double.tryParse(val) ?? 0,
                validator: (val) => (double.tryParse(val ?? '') ?? 0) <= 0
                    ? 'Enter valid amount'
                    : null,
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => date = picked);
                },
                child: Text(
                    'Pick Date: ${date.toLocal().toString().split(' ')[0]}'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newTx = TransactionModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                type: type,
                amount: amount,
                category: category,
                date: date,
                note: '', // No note
              );
              widget.transactionBox.add(newTx);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
