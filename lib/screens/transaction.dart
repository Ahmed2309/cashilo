import 'package:cashilo/widgets/transaction/add_transaction_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction/transaction_search_bar.dart';
import '../widgets/transaction/transaction_filter_chips.dart';
import '../widgets/transaction/transaction_list.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String searchQuery = '';
  String selectedType = 'All';

  late Box<TransactionModel> transactionBox;

  @override
  void initState() {
    super.initState();
    transactionBox = Hive.box<TransactionModel>('transactions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TransactionSearchBar(
            searchQuery: searchQuery,
            onChanged: (val) => setState(() => searchQuery = val),
          ),
          TransactionFilterChips(
            selectedType: selectedType,
            onTypeSelected: (type) => setState(() => selectedType = type),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: transactionBox.listenable(),
              builder: (context, Box<TransactionModel> box, _) {
                final allTransactions =
                    box.values.toList().cast<TransactionModel>();
                final filteredTransactions = allTransactions.where((tx) {
                  final matchesType =
                      selectedType == 'All' || tx.type == selectedType;
                  final matchesSearch = searchQuery.isEmpty ||
                      tx.category
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()) ||
                      tx.note.toLowerCase().contains(searchQuery.toLowerCase());
                  return matchesType && matchesSearch;
                }).toList();

                return TransactionList(transactions: filteredTransactions);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) =>
                AddTransactionDialog(transactionBox: transactionBox),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
      ),
    );
  }
}
