import 'package:cashilo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

String getLocalizedCategory(BuildContext context, String category) {
  final l = AppLocalizations.of(context)!;

  final categoryMap = {
    // Income
    'Salary': l.incomeCategories[0],
    'Bonus': l.incomeCategories[1],
    'Investment': l.incomeCategories[2],
    'Business': l.incomeCategories[3],
    'Gift': l.incomeCategories[4],
    'Refund': l.incomeCategories[5],
    'Freelance': l.incomeCategories[6],
    'Grants': l.incomeCategories[7],
    'Other': l.incomeCategories[8],

    // Expense
    'Food': l.expenseCategories[0],
    'Shopping': l.expenseCategories[1],
    'Bills': l.expenseCategories[2],
    'Transport': l.expenseCategories[3],
    'Health': l.expenseCategories[4],
    'Education': l.expenseCategories[5],
    'Entertainment': l.expenseCategories[6],
    'Travel': l.expenseCategories[7],
    'Groceries': l.expenseCategories[8],
    'Rent': l.expenseCategories[9],
    'Utilities': l.expenseCategories[10],
    'Insurance': l.expenseCategories[11],
    'Subscriptions': l.expenseCategories[12],
    'Charity': l.expenseCategories[13],
    'Personal Care': l.expenseCategories[14],
    'Taxes': l.expenseCategories[15],
    'Loan Payment': l.expenseCategories[16],
    'Pets': l.expenseCategories[17],
    'Gifts': l.expenseCategories[18],
    'Saving': l.savingN,
  };

  return categoryMap[category] ?? category;
}

Map<String, double> getLocalizedCategoryMap(
    BuildContext context, Map<String, double> categoryMap) {
  return categoryMap
      .map((key, value) => MapEntry(getLocalizedCategory(context, key), value));
}
