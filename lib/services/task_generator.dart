import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/task_item.dart';
import '../data/database_helper.dart';

class TaskGeneratorService {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  /// Analyzes a new transaction and generates a task if it matches certain rules
  Future<void> analyzeTransactionAndGenerateTasks(TransactionModel transaction) async {
    final lowerNotes = (transaction.notes ?? '').toLowerCase();
    final lowerMerchant = transaction.merchant.toLowerCase();

    // Trigger 1: Credit Card Bill Payment
    if (lowerNotes.contains('credit card') || lowerMerchant.contains('sbi card') || lowerMerchant.contains('hdfc card')) {
      if (transaction.type == 'Debit' && transaction.amount > 1000) {
        // If they paid a large amount to a CC, it might be the bill.
        // Instead of generating a generic "Pay Bill", maybe ask them to review the bill.
        final task = TaskItem(
          id: const Uuid().v4(),
          task: 'Review Credit Card Statement for ${transaction.merchant}',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          linkedTransactionId: transaction.id,
        );
        await dbHelper.insertTask(task);
      }
    }

    // Trigger 2: Rent Detection (Large round amount, perhaps specific dates or notes)
    if (lowerNotes.contains('rent') || lowerMerchant.contains('rent')) {
      // Add a reminder for next month's rent
      final task = TaskItem(
        id: const Uuid().v4(),
        task: 'Pay next month\'s rent',
        dueDate: DateTime.now().add(const Duration(days: 30)),
        linkedTransactionId: transaction.id,
      );
      await dbHelper.insertTask(task);
    }

    // Trigger 3: Subscription detection
    final subscriptions = ['netflix', 'spotify', 'amazon prime', 'hotstar', 'youtube premium'];
    if (subscriptions.any((sub) => lowerMerchant.contains(sub))) {
      // Add a review reminder for a subscription
      final task = TaskItem(
         id: const Uuid().v4(),
         task: 'Review $lowerMerchant subscription: Are you still using it?',
         dueDate: DateTime.now().add(const Duration(days: 28)), // Remind just before next billing cycle
         linkedTransactionId: transaction.id,
      );
      await dbHelper.insertTask(task);
    }
  }
}
