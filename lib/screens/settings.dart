import 'package:cashilo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cashilo/models/goals_model.dart';
import 'package:cashilo/models/transaction_model.dart';
import 'package:hive/hive.dart';
import 'package:cashilo/widgets/settings/language_selector.dart';
import 'package:cashilo/widgets/settings/currency_selector.dart';
import 'package:cashilo/constant.dart';
import 'package:cashilo/main.dart';

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
        title: Text(AppLocalizations.of(context)!.settings,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.headline)),
      ),
      backgroundColor: AppColors.background,
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
              // Set locale in the app
              Locale locale =
                  val == 'Arabic' ? const Locale('ar') : const Locale('en');
              // Call the callback from MainScreen or MyApp
              if (context.findAncestorStateOfType<MyAppState>() != null) {
                context
                    .findAncestorStateOfType<MyAppState>()!
                    .setLocale(locale);
              }
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
            leading: const Icon(Icons.notifications, color: AppColors.primary),
            title: Text(AppLocalizations.of(context)!.enableNotifications,
                style: TextStyle(color: AppColors.primaryText)),
            trailing: Switch(
              value: notificationsEnabled,
              activeColor: AppColors.primary,
              onChanged: (val) {
                setState(() {
                  notificationsEnabled = val;
                });
                // TODO: Save to persistent storage if needed
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode, color: AppColors.primary),
            title: Text(AppLocalizations.of(context)!.darkMode,
                style: TextStyle(color: AppColors.primaryText)),
            trailing: Switch(
              value: darkMode,
              activeColor: AppColors.primary,
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
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: Text(AppLocalizations.of(context)!.clearAllData,
                style: TextStyle(color: AppColors.primaryText)),
            subtitle: const Text(
              'This will delete all your goals and transactions.',
              style: TextStyle(color: AppColors.primaryText),
            ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                      ),
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
            leading: const Icon(Icons.info_outline, color: AppColors.primary),
            title: Text(AppLocalizations.of(context)!.about,
                style: const TextStyle(color: AppColors.primaryText)),
            subtitle: Text(
              AppLocalizations.of(context)!.appDescription,
              style: TextStyle(color: AppColors.primaryText),
            ),
          ),
        ],
      ),
    );
  }
}
