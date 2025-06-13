import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../models/transaction_model.dart';
import 'package:cashilo/constant.dart';

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
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        'Edit Transaction',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
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
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle: const TextStyle(color: AppColors.primaryText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.card,
                ),
                dropdownColor: AppColors.background,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: category,
                items: categories
                    .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => category = val ?? categories.first),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: const TextStyle(color: AppColors.primaryText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.card,
                ),
                dropdownColor: AppColors.background,
              ),
              const SizedBox(height: 14),
              TextFormField(
                initialValue: amount.toString(),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: const TextStyle(color: AppColors.primaryText),
                  prefixIcon:
                      const Icon(Icons.attach_money, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.card,
                ),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.primaryText),
                onChanged: (val) => amount = double.tryParse(val) ?? 0,
                validator: (val) => (double.tryParse(val ?? '') ?? 0) <= 0
                    ? 'Enter valid amount'
                    : null,
              ),
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => date = picked);
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.card,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 20, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        'Pick Date: ${date.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(
                            fontSize: 15, color: AppColors.primaryText),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
