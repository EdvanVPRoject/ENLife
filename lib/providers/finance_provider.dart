import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/transaction_item.dart';
import '../data/services/storage_service.dart';

class FinanceProvider extends ChangeNotifier {
  final StorageService _storage;
  List<TransactionItem> _items = [];

  FinanceProvider(this._storage);

  List<TransactionItem> get items => List.unmodifiable(_items);

  double get totalIncome => _items
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _items
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get netBalance => totalIncome - totalExpense;

  Map<String, double> get expenseByCategory {
    final map = <String, double>{};
    for (var tx in _items.where((t) => t.type == TransactionType.expense)) {
      map[tx.category] = (map[tx.category] ?? 0.0) + tx.amount;
    }
    return map;
  }

  Future<void> load() async {
    _items = await _storage.getTransactions();
    // Sort latest date first
    _items.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    DateTime? date,
    String? note,
  }) async {
    final newItem = TransactionItem(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date ?? DateTime.now(),
      note: note,
    );
    _items.insert(0, newItem);
    await _storage.saveTransactions(_items);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _items.removeWhere((t) => t.id == id);
    await _storage.saveTransactions(_items);
    notifyListeners();
  }
}
