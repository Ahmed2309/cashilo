import 'package:cashilo/l10n/app_localizations.dart';
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
  double amount = 0;
  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final income = AppLocalizations.of(context)!.incomeCategories;
    final expense = AppLocalizations.of(context)!.expenseCategories;
    final categories = type == 'Income' ? income : expense;

    if (category.isEmpty && categories.isNotEmpty) {
      category = categories.first;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type == 'Income'
                      ? Icons.attach_money_rounded
                      : Icons.money_off_rounded,
                  color: type == 'Income' ? Colors.green : Colors.red,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.addTransaction,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  value: type,
                  items: [
                    DropdownMenuItem(
                      value: 'Income',
                      child: Text(AppLocalizations.of(context)!.income),
                    ),
                    DropdownMenuItem(
                      value: 'Expense',
                      child: Text(AppLocalizations.of(context)!.expense),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      type = val ?? 'Income';
                      final newCategories = type == 'Income' ? income : expense;
                      category = newCategories.first;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.type,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: category,
                  items: categories
                      .map((cat) =>
                          DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => category = val ?? categories.first),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.category,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.amount,
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => amount = double.tryParse(val) ?? 0,
                  validator: (val) => (double.tryParse(val ?? '') ?? 0) <= 0
                      ? AppLocalizations.of(context)!.enterValidAmount
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
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => date = picked);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.deepPurple.shade100),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.deepPurple.withOpacity(0.04),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 20, color: Colors.deepPurple),
                        const SizedBox(width: 10),
                        Text(
                          '${AppLocalizations.of(context)!.pickDate}: ${date.toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(AppLocalizations.of(context)!.cancel),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final newTx = TransactionModel(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            type: type,
                            amount: amount,
                            category: category,
                            date: date,
                            note: '',
                          );
                          widget.transactionBox.add(newTx);
                          Navigator.pop(context);
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
