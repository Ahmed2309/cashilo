import 'package:cashilo/constant.dart';
import 'package:cashilo/screens/dashboard.dart';
import 'package:cashilo/screens/goals.dart';
import 'package:cashilo/screens/reports.dart';
import 'package:cashilo/screens/settings.dart';
import 'package:cashilo/screens/transaction.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    Center(child: DashboardScreen()),
    Center(child: TransactionsPage()),
    Center(child: GoalsScreen()),
    Center(child: ReportsScreen()),
    Center(child: SettingsScreen()),
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
          'Cashilo',
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
          // Add more IconButton widgets here if you want more actions
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
            const DrawerHeader(
              decoration: BoxDecoration(
                color: selectedColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(32),
                ),
              ),
              child: Center(
                child: Text(
                  'Cashilo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_rounded),
              title: const Text('Dashboard'),
              selected: _selectedIndex == 0,
              selectedTileColor: selectedColor.withOpacity(0.1),
              onTap: () => _onDrawerItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_rounded),
              title: const Text('Transactions'),
              selected: _selectedIndex == 1,
              selectedTileColor: selectedColor.withOpacity(0.1),
              onTap: () => _onDrawerItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_rounded),
              title: const Text('My Goals'),
              selected: _selectedIndex == 2,
              selectedTileColor: selectedColor.withOpacity(0.1),
              onTap: () => _onDrawerItemTapped(2),
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart_rounded),
              title: const Text('Reports'),
              selected: _selectedIndex == 3,
              selectedTileColor: selectedColor.withOpacity(0.1),
              onTap: () => _onDrawerItemTapped(3),
            ),
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Settings'),
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
