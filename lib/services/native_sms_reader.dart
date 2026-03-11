import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../services/sms_parser.dart';
import '../services/categorization_engine.dart';
import '../services/task_generator.dart';
import '../providers/transaction_provider.dart';

final nativeSmsReaderProvider = Provider<NativeSmsReader>((ref) {
  return NativeSmsReader(
    ref,
    SmsParserService(),
    CategorizationEngine(),
    TaskGeneratorService(),
  );
});

class NativeSmsReader {
  final Ref ref;
  final SmsParserService _smsParser;
  final CategorizationEngine _categorizationEngine;
  final TaskGeneratorService _taskGenerator;

  static const platform = MethodChannel('com.finpilot.ai/sms');

  NativeSmsReader(this.ref, this._smsParser, this._categorizationEngine,
      this._taskGenerator);

  Future<void> fetchAndProcessRecentSms() async {
    // 1. Check Permissions
    final status = await Permission.sms.request();
    if (!status.isGranted) {
      return;
    }

    try {
      // 2. Call Native Android Method
      final List<dynamic> result = await platform.invokeMethod('getRecentSms');

      // 3. Process each SMS
      for (var smsString in result) {
        final parts = smsString.toString().split("||");
        if (parts.length == 2) {
          final dateStr = parts[0];
          final body = parts[1];

          final date = DateTime.fromMillisecondsSinceEpoch(int.parse(dateStr));

          var tx = _smsParser.parseSms(body, date);

          if (tx != null) {
            // Check if we already have this transaction (simplistic check for phase 1)
            final currentTransactions = ref.read(transactionsProvider);
            final exists = currentTransactions.any((t) =>
                t.date == tx!.date &&
                t.amount == tx.amount &&
                t.merchant == tx.merchant);

            if (!exists) {
              if (tx.type == 'Debit' && tx.category == 'Uncategorized') {
                final cat = await _categorizationEngine.categorize(tx.merchant);
                tx = tx.copyWith(category: cat);
              }

              await ref.read(transactionsProvider.notifier).addTransaction(tx);
              await _taskGenerator.analyzeTransactionAndGenerateTasks(tx);
            }
          }
        }
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to get SMS: '${e.message}'.");
    }
  }
}
