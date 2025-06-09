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
  String category = '';
  String note = '';
  double amount = 0;
  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
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
                onChanged: (val) => setState(() => type = val ?? 'Income'),
                decoration: const InputDecoration(labelText: 'Type'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (val) => category = val,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter category' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Note'),
                onChanged: (val) => note = val,
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
                note: note,
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
