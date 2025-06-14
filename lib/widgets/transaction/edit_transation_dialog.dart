import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../models/transaction_model.dart';
import 'package:cashilo/constant.dart';
import 'package:cashilo/l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    type = widget.transaction.type;
    category = widget.transaction.category;
    amount = widget.transaction.amount;
    date = widget.transaction.date;
  }

  String getEnglishCategory(
    String localized,
    List<String> english,
    List<String> localizedList,
  ) {
    final index = localizedList.indexOf(localized);
    return index != -1 ? english[index] : localized;
  }

  @override
  Widget build(BuildContext context) {
    final incomeLocalized = AppLocalizations.of(context)!.incomeCategories;
    final expenseLocalized = AppLocalizations.of(context)!.expenseCategories;
    final incomeEnglish = [
      'Salary',
      'Bonus',
      'Investment',
      'Business',
      'Gift',
      'Refund',
      'Freelance',
      'Grants',
      'Other'
    ];
    final expenseEnglish = [
      'Food',
      'Shopping',
      'Bills',
      'Transport',
      'Health',
      'Education',
      'Entertainment',
      'Travel',
      'Groceries',
      'Rent',
      'Utilities',
      'Insurance',
      'Subscriptions',
      'Charity',
      'Personal Care',
      'Taxes',
      'Loan Payment',
      'Pets',
      'Gifts',
      'Saving',
      'Other'
    ];

    final categories = type == 'Income' ? incomeLocalized : expenseLocalized;

    // Display category in localized form
    final localizedCategoryIndex =
        (type == 'Income' ? incomeEnglish : expenseEnglish).indexOf(category);
    final displayedCategory = localizedCategoryIndex != -1
        ? categories[localizedCategoryIndex]
        : category;

    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        AppLocalizations.of(context)!.editTransaction,
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
                    category =
                        (type == 'Income' ? incomeLocalized : expenseLocalized)
                            .first;
                  });
                },
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.type,
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
                value: displayedCategory,
                items: categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (val) =>
                    setState(() => category = val ?? categories.first),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.category,
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
                  labelText: AppLocalizations.of(context)!.amount,
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
                        '${AppLocalizations.of(context)!.pickDate}: ${date.toLocal().toString().split(' ')[0]}',
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
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final englishCategory = getEnglishCategory(
                category,
                type == 'Income' ? incomeEnglish : expenseEnglish,
                type == 'Income' ? incomeLocalized : expenseLocalized,
              );

              final updatedTx = TransactionModel(
                id: widget.transaction.id,
                type: type,
                amount: amount,
                category: englishCategory,
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
          child: Text(AppLocalizations.of(context)!.saveButton),
        ),
      ],
    );
  }
}
