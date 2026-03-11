import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/task_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // In-memory fallback for Web presentation
  final List<TransactionModel> _webTransactions = [];
  final List<TaskItem> _webTasks = [];

  DatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is bypassed on Web. Use in-memory fallbacks.');
    }
    if (_database != null) return _database!;
    _database = await _initDB('finpilot.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Hardcoded password for Phase 1. 
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      password: 'finpilot_secure_key_123', 
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textNullableType = 'TEXT';
    const boolType = 'BOOLEAN NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const realNullableType = 'REAL';

    await db.execute('''
CREATE TABLE transactions (
  id $idType,
  date $intType,
  amount $realType,
  merchant $textType,
  category $textType,
  type $textType,
  balance $realNullableType,
  notes $textNullableType,
  is_manually_categorized $boolType
)
''');

    await db.execute('''
CREATE TABLE tasks (
  id $idType,
  task $textType,
  due_date $intType,
  linked_transaction_id $textNullableType,
  is_completed $boolType,
  FOREIGN KEY (linked_transaction_id) REFERENCES transactions (id) ON DELETE SET NULL
)
''');

    await db.execute('''
CREATE TABLE category_preferences (
  merchant $textType PRIMARY KEY,
  category $textType,
  user_override $boolType,
  frequency $intType
)
''');
  }

  // --- Transactions CRUD ---
  Future<TransactionModel> insertTransaction(TransactionModel transaction) async {
    if (kIsWeb) {
      _webTransactions.add(transaction);
      return transaction;
    }
    final db = await instance.database;
    await db.insert('transactions', transaction.toMap());
    return transaction;
  }

  Future<List<TransactionModel>> readAllTransactions() async {
    if (kIsWeb) {
      final sorted = List<TransactionModel>.from(_webTransactions);
      sorted.sort((a, b) => b.date.compareTo(a.date));
      return sorted;
    }
    final db = await instance.database;
    final orderBy = 'date DESC';
    final result = await db.query('transactions', orderBy: orderBy);
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    if (kIsWeb) {
      final index = _webTransactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _webTransactions[index] = transaction;
        return 1;
      }
      return 0;
    }
    final db = await instance.database;
    return db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(String id) async {
    if (kIsWeb) {
      _webTransactions.removeWhere((t) => t.id == id);
      return 1;
    }
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Tasks CRUD ---
  Future<TaskItem> insertTask(TaskItem task) async {
    if (kIsWeb) {
      _webTasks.add(task);
      return task;
    }
    final db = await instance.database;
    await db.insert('tasks', task.toMap());
    return task;
  }

  Future<List<TaskItem>> readAllTasks() async {
    if (kIsWeb) {
      final sorted = List<TaskItem>.from(_webTasks);
      sorted.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return sorted;
    }
    final db = await instance.database;
    final orderBy = 'due_date ASC';
    final result = await db.query('tasks', orderBy: orderBy);
    return result.map((json) => TaskItem.fromMap(json)).toList();
  }

  Future<int> updateTask(TaskItem task) async {
    if (kIsWeb) {
      final index = _webTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _webTasks[index] = task;
        return 1;
      }
      return 0;
    }
    final db = await instance.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(String id) async {
    if (kIsWeb) {
      _webTasks.removeWhere((t) => t.id == id);
      return 1;
    }
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    if (kIsWeb) return;
    final db = await instance.database;
    db.close();
  }
}
