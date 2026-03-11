import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction.dart';
import '../data/database_helper.dart';

final databaseProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final transactionsProvider = NotifierProvider<TransactionNotifier, List<TransactionModel>>(() {
  return TransactionNotifier();
});

class TransactionNotifier extends Notifier<List<TransactionModel>> {
  @override
  List<TransactionModel> build() {
    loadTransactions();
    return [];
  }

  Future<void> loadTransactions() async {
    final dbHelper = ref.read(databaseProvider);
    final transactions = await dbHelper.readAllTransactions();
    state = transactions;
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final dbHelper = ref.read(databaseProvider);
    await dbHelper.insertTransaction(transaction);
    await loadTransactions();
  }

  double get totalSpentThisMonth {
    final now = DateTime.now();
    return state
        .where((t) => t.type == 'Debit' && t.date.month == now.month && t.date.year == now.year)
        .fold(0.0, (sum, item) => sum + item.amount);
  }
}
