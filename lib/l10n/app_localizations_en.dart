// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Cashilo';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get about => 'About';

  @override
  String get noTransactionsToday => 'No transactions today.';

  @override
  String get monthlySavingGoalProgress => 'Monthly Saving Goal Progress';

  @override
  String get selectDateRange =>
      'Select a date range to view your financial reports.';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get seeAll => 'See All';

  @override
  String get showLess => 'Show Less';

  @override
  String get monthlySavingGoal => 'Monthly Saving Goal';

  @override
  String get cancel => 'Cancel';

  @override
  String get approve => 'Approve';

  @override
  String savingGoalAlert(String balance, String goal) =>
      'Your balance (\$$balance) is enough to cover the remaining monthly saving goal (\$$goal).\n\nDo you want to move this amount to your savings goals now?';

  @override
  String congratulationsMessage(String goal) =>
      '🎉 Congratulations! You\'ve reached your monthly saving goal (\$$goal).';

  @override
  String savingProgressMessage(String saved, String goal) =>
      'You\'ve saved \$$saved of \$$goal.';

  @override
  String get noTransactions => 'No transactions found.';
  @override
  String get addTransaction => 'Add Transaction';
  @override
  String get income => 'Income';
  @override
  String get expense => 'Expense';
  @override
  String get balance => 'Balance';
  @override
  String get saving => 'Total Saving';
  @override
  String get addToSaving => 'Add to Saving';
  @override
  String get withdraw => 'Withdraw';
  @override
  String get appDescription =>
      'Cashilo is a personal finance app that helps you track your income, expenses, and savings goals.';
  @override
  String get myGoal => 'My Goal';
  @override
  String get activeGoals => 'Active Goals';
  @override
  String get doneOrStoppedGoals => 'Stopped/Completed Goals';
  @override
  String get noGoalsYet => 'No goals yet. Tap + to add one!';
  @override
  String get transactions => 'Transactions';
  @override
  String get myGoals => 'My Goals';
  @override
  String get reports => 'Reports';
  @override
  List<String> get incomeCategories => [
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

  @override
  List<String> get expenseCategories => [
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
  @override
  String get type => 'Type';
  @override
  String get category => 'Category';
  @override
  String get amount => 'Amount';
  String get add => 'Add';
  String get enterValidAmount => 'Please enter a valid amount.';
  @override
  String get pickDate => 'Pick Date';
  @override
  String get dGoals => 'Distribute Among All';
  @override
  String get sGoal => 'Single Goal';
  @override
  String get withDraw => 'Withdraw from Saving';
  @override
  String get withdrawFromAll => 'Withdraw from All Savings';
  @override
  String amountWithMax(String max) => 'Max amount $max';
}
