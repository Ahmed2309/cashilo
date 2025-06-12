import 'package:flutter/material.dart';
import 'package:cashilo/models/goals_model.dart';
import 'package:cashilo/models/transaction_model.dart';
import 'package:hive/hive.dart';
import 'package:cashilo/widgets/settings/language_selector.dart';
import 'package:cashilo/widgets/settings/currency_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkMode = false;

  String selectedLanguage = 'English';
  String selectedCurrency = 'USD';

  final List<String> languages = ['English', 'Arabic', 'French'];
  final List<String> currencies = ['USD', 'EUR', 'SAR', 'EGP'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          LanguageSelector(
            selectedLanguage: selectedLanguage,
            languages: languages,
            onChanged: (val) {
              setState(() {
                selectedLanguage = val;
              });
              // TODO: Apply language change in the app
            },
          ),
          CurrencySelector(
            selectedCurrency: selectedCurrency,
            currencies: currencies,
            onChanged: (val) {
              setState(() {
                selectedCurrency = val;
              });
              // TODO: Apply currency change in the app
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Enable Notifications'),
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (val) {
                setState(() {
                  notificationsEnabled = val;
                });
                // TODO: Save to persistent storage if needed
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: darkMode,
              onChanged: (val) {
                setState(() {
                  darkMode = val;
                });
                // TODO: Apply dark mode to the app if needed
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Data'),
            subtitle:
                const Text('This will delete all your goals and transactions.'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: const Text(
                      'Are you sure you want to delete all data? This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await Hive.box<Goal>('goals').clear();
                await Hive.box<TransactionModel>('transactions').clear();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data cleared.')),
                  );
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle:
                const Text('Cashilo v1.0\nA simple savings and goals tracker.'),
          ),
        ],
      ),
    );
  }
}
