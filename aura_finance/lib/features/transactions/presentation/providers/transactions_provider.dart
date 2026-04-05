import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/transaction.dart';

part 'transactions_provider.g.dart';

@riverpod
class Transactions extends _$Transactions {
  @override
  List<Transaction> build() {
    return [
      Transaction(
        id: '1',
        title: 'Groceries',
        amount: 45.50,
        date: DateTime.now().subtract(const Duration(days: 0)),
        category: 'Food',
        type: TransactionType.expense,
        mood: '😐',
      ),
      Transaction(
        id: '2',
        title: 'Salary Deposit',
        amount: 4200.00,
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Salary',
        type: TransactionType.income,
        mood: '😀',
      ),
      Transaction(
        id: '3',
        title: 'Uber Ride',
        amount: 15.20,
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Transport',
        type: TransactionType.expense,
        mood: '😤',
      ),
      Transaction(
        id: '4',
        title: 'Netflix Subscription',
        amount: 12.99,
        date: DateTime.now().subtract(const Duration(days: 3)),
        category: 'Entertainment',
        type: TransactionType.expense,
        mood: '🍿',
      ),
    ];
  }

  void addTransaction(Transaction transaction) {
    state = [transaction, ...state];
  }

  void removeTransaction(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  void updateTransaction(Transaction transaction) {
    state = [
      for (final t in state)
        if (t.id == transaction.id) transaction else t
    ];
  }
}
