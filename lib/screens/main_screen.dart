import 'package:cashilo/constant.dart';
import 'package:cashilo/l10n/app_localizations.dart';
import 'package:cashilo/screens/dashboard.dart';
import 'package:cashilo/screens/goals.dart';
import 'package:cashilo/screens/reports.dart';
import 'package:cashilo/screens/settings.dart';
import 'package:cashilo/screens/transaction.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final void Function(Locale locale) onLocaleChange;

  const MainScreen({super.key, required this.onLocaleChange});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    DashboardScreen(),
    TransactionsPage(),
    GoalsScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.pop(context); // Close the drawer
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color selectedColor = AppColors.primary;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.appName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.background,
              ),
        ),
        centerTitle: true,
        backgroundColor: selectedColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifications',
            onPressed: () {
              // TODO: Handle notification tap
            },
          ),
        ],
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: selectedColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(32),
                ),
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_rounded),
              title: Text(AppLocalizations.of(context)!.dashboard),
              selected: _selectedIndex == 0,
              selectedTileColor: selectedColor.withOpacity(0.1),
              onTap: () => _onDrawerItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_rounded),
              title: Text(AppLocalizations.of(context)!.transactions),
              selected: _selectedIndex == 1,
              selectedTileColor: selectedColor.withOpacity(0.1),
              onTap: () => _onDrawerItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_rounded),
              title: Text(AppLocalizations.of(context)!.myGoals),
              selected: _selectedIndex == 2,
              selectedTileColor: selectedColor.withOpacity(0.1),
              onTap: () => _onDrawerItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart_rounded),
              title: Text(AppLocalizations.of(context)!.reports),
              selected: _selectedIndex == 3,
              selectedTileColor: selectedColor.withOpacity(0.1),
              onTap: () => _onDrawerItemTapped(3),
            ),
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: Text(AppLocalizations.of(context)!.settings),
              selected: _selectedIndex == 4,
              selectedTileColor: selectedColor.withOpacity(0.1),
              onTap: () => _onDrawerItemTapped(4),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
