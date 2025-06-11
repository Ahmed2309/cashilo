import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../models/transaction_model.dart';

class EditTransactionDialog extends StatefulWidget {
  final Box<TransactionModel> transactionBox;
  final int transactionKey;
  final TransactionModel transaction;

  const EditTransactionDialog({
    super.key,
    required this.transactionBox,
    required this.transactionKey,
    required this.transaction,
  });

  @override
  State<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late String type;
  late String category;
  late double amount;
  late DateTime date;

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
  void initState() {
    super.initState();
    type = widget.transaction.type;
    category = widget.transaction.category;
    amount = widget.transaction.amount;
    date = widget.transaction.date;
  }

  @override
  Widget build(BuildContext context) {
    final categories = type == 'Income' ? incomeCategories : expenseCategories;

    return AlertDialog(
      title: const Text('Edit Transaction'),
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
                initialValue: amount.toString(),
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
              final updatedTx = TransactionModel(
                id: widget.transaction.id,
                type: type,
                amount: amount,
                category: category,
                date: date,
                note: widget.transaction.note,
              );
              widget.transactionBox.put(widget.transactionKey, updatedTx);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
