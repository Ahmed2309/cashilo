import 'package:flutter/material.dart';

class AppColors {
  // Light mode colors
  static const background = Color(0xFFF9F9F9);
  static const primaryText = Color(0xFF333333);
  static const headline = Color(0xFF1E2A38);
  static const primary = Color(0xFF00B8D9);
  static const secondary = Color(0xFF36B37E);
  static const warning = Color(0xFFFFAB00);
  static const error = Color(0xFFFF5630);
  static const card = Color(0xFFECECEC);
}

// App Strings
class AppStrings {
  static const appName = 'Cashilo';
  static const addTransaction = 'Add Transaction';
  static const income = 'Income';
  static const expense = 'Expense';
  static const balance = 'Balance';
  static const saving = 'Total Saving';
  static const addToSaving = 'Add to Saving';
  static const withdraw = 'Withdraw';
  static const monthlySavingGoal = 'Monthly Saving Goal';
}

// App Lists
const List<String> incomeCategories = [
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

const List<String> expenseCategories = [
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
  'Other'
];

const List<String> supportedLanguages = [
  'English',
  'Arabic',
  'French',
];

const List<String> supportedCurrencies = [
  'USD',
  'EUR',
  'SAR',
  'EGP',
];
