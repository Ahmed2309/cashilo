import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../widgets/transaction/transation_tile_t.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String searchQuery = '';
  String selectedType = 'All';
  String selectedCategory = 'All';
  // Dummy data for demonstration
  final List<Map<String, dynamic>> transactions = [
    {
      'date': DateTime.now(),
      'category': 'Food',
      'note': 'Lunch',
      'amount': -20.0,
      'type': 'Expense',
    },
    {
      'date': DateTime.now(),
      'category': 'Salary',
      'note': '',
      'amount': 2000.0,
      'type': 'Income',
    },
    {
      'date': DateTime.now(),
      'category': 'Transport',
      'note': 'Taxi',
      'amount': -15.0,
      'type': 'Expense',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = transactions.where((tx) {
      final matchesType = selectedType == 'All' || tx['type'] == selectedType;
      final matchesCategory =
          selectedCategory == 'All' || tx['category'] == selectedCategory;
      final matchesSearch = searchQuery.isEmpty ||
          tx['category'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          tx['note'].toLowerCase().contains(searchQuery.toLowerCase());
      return matchesType && matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // Optional: Month filter dropdown
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by note or category',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: selectedType == 'All',
                  onSelected: (_) => setState(() => selectedType = 'All'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Income'),
                  selected: selectedType == 'Income',
                  onSelected: (_) => setState(() => selectedType = 'Income'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Expense'),
                  selected: selectedType == 'Expense',
                  onSelected: (_) => setState(() => selectedType = 'Expense'),
                ),
                // Add more category chips as needed
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Transaction List or Empty State
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_rounded,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          'No transactions yet.\nTap + to add one!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = filteredTransactions[index];
                      return Slidable(
                        key: ValueKey(tx),
                        startActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                // TODO: Edit transaction
                              },
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              icon: Icons.edit,
                              label: 'Edit',
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                // TODO: Delete transaction
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: TransactionTile(
                          date: tx['date'],
                          category: tx['category'],
                          note: tx['note'],
                          amount: tx['amount'],
                          type: tx['type'],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to AddTransactionPage
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
