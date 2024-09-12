import 'package:expense_tracker/models/expense.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;

Future<Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'expense.db'),
    onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE user_expense(id TEXT PRIMARY KEY, title TEXT, amount REAL, dateTime TEXT, category INTEGER )');
    },
    version: 1,
  );
  return db;
}

class ExpenseNotifier extends StateNotifier<List<Expense>> {
  ExpenseNotifier() : super([]);

  Future<void> loadExpense() async {
    final db = await _getDatabase();
    final data = await db.query('user_expense');
    final expense = data
        .map(
          (row) => Expense(
            id: row['id'] as String,
            title: row['title'] as String,
            amount: row['amount'] as double,
            date: DateTime.parse(row['dateTime'] as String),
            category: Category.values[row['category'] as int],
          ),
        )
        .toList();

    state = expense;
  }

  void addExpense(
    String title,
    double amount,
    DateTime date,
    Category category,
  ) async {
    final newExpense = Expense(
      title: title,
      amount: amount,
      date: date,
      category: category,
    );
    final db = await _getDatabase();
    db.insert('user_expense', {
      'id': newExpense.id,
      'title': newExpense.title,
      'amount': newExpense.amount,
      'dateTime': newExpense.date.toIso8601String(),
      'category': newExpense.category.index,
    });
    state = [...state, newExpense];
  }

  void removeExpense(String id) async {
    final db = await _getDatabase();
    int result = await db.delete(
      'user_expense',
      where: 'id = ?',
      whereArgs: [id],
    );
    print(result);
    state = [
      for (final exp in state)
        if (exp.id != id) exp
    ];
  }
}

final expenseProvider = StateNotifierProvider<ExpenseNotifier, List<Expense>>(
  (ref) => ExpenseNotifier(),
);
