import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sms_parser.dart';
import '../services/categorization_engine.dart';
import '../services/task_generator.dart';
import '../providers/transaction_provider.dart';

final mockDataInjectorProvider = Provider<MockDataInjector>((ref) {
  return MockDataInjector(
    ref,
    SmsParserService(),
    CategorizationEngine(),
    TaskGeneratorService(),
  );
});

class MockDataInjector {
  final Ref ref;
  final SmsParserService _smsParser;
  final CategorizationEngine _categorizationEngine;
  final TaskGeneratorService _taskGenerator;

  MockDataInjector(this.ref, this._smsParser, this._categorizationEngine,
      this._taskGenerator);

  Future<void> injectMockDataIfEmpty() async {
    // Check if DB is empty
    if (ref.read(transactionsProvider).isNotEmpty) {
      return;
    }

    final mockSmsMessages = [
      "Rs 500.00 debited from a/c **1234 on 01-10-26 to SWIGGY. Avl Bal 1500.",
      "Spent INR 1500.0 on credit card ending 4567 at UBER.",
      "Salary of Rs 50000 credited to a/c **1234 on 02-10-26.",
      "Rs.1200 has been debited towards UPI/12345/Netflix/",
      "Payment of INR 3,000.00 to AMAZON via Netbanking.",
      "Rs 15000.00 debited from a/c **1234 on 05-10-26 to RENT PMT.",
    ];

    final baseDate = DateTime.now().subtract(const Duration(days: 5));

    for (int i = 0; i < mockSmsMessages.length; i++) {
      final sms = mockSmsMessages[i];
      final date = baseDate.add(Duration(days: i));

      var tx = _smsParser.parseSms(sms, date);

      if (tx != null) {
        // Categorize
        if (tx.type == 'Debit' && tx.category == 'Uncategorized') {
          final cat = await _categorizationEngine.categorize(tx.merchant);
          tx = tx.copyWith(category: cat);
        }

        // Insert DB
        await ref.read(transactionsProvider.notifier).addTransaction(tx);

        // Generate possible tasks
        await _taskGenerator.analyzeTransactionAndGenerateTasks(tx);
      }
    }
  }
}
