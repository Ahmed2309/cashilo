import 'package:cashilo/l10n/app_localizations.dart';
import 'package:cashilo/widgets/transaction/add_transaction_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction/transaction_search_bar.dart';
import '../widgets/transaction/transaction_filter_chips.dart';
import '../widgets/transaction/transaction_list.dart';
import 'package:cashilo/constant.dart';

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
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.transactions,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.headline),
          ),
          const SizedBox(height: 10),
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
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
