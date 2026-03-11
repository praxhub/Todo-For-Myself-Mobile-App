import 'package:flutter_test/flutter_test.dart';
import 'package:mytodo/services/sms_parser.dart';
import 'package:mytodo/services/categorization_engine.dart';

void main() {
  group('SmsParserService Tests', () {
    final parser = SmsParserService();
    final testDate = DateTime(2026, 1, 1);

    test('Parses standard debit correctly', () {
      final tx = parser.parseSms("Rs 500.00 debited from a/c **1234 on 01-01-26 to SWIGGY. Avl Bal 1500.", testDate);
      expect(tx, isNotNull);
      expect(tx!.amount, 500.0);
      expect(tx.merchant, 'SWIGGY');
      expect(tx.type, 'Debit');
    });

    test('Parses UPI debit correctly', () {
      final tx = parser.parseSms("Rs.1200 has been debited towards UPI/12345/Netflix/", testDate);
      expect(tx, isNotNull);
      expect(tx!.amount, 1200.0);
      expect(tx.merchant, 'Netflix');
      expect(tx.type, 'Debit');
    });

    test('Parses salary credit correctly', () {
      final tx = parser.parseSms("Salary of Rs 50000 credited to a/c **1234 on 02-10-26.", testDate);
      expect(tx, isNotNull);
      expect(tx!.amount, 50000.0);
      expect(tx.type, 'Credit');
    });
  });

  group('CategorizationEngine Tests', () {
    final engine = CategorizationEngine();

    test('Categorizes known merchants instantly', () async {
      expect(await engine.categorize('swiggy app'), 'Food & Dining');
      expect(await engine.categorize('UBER Trip'), 'Travel');
      expect(await engine.categorize('NETFLIX SUBSCRIPTION'), 'Entertainment');
    });

    test('Categorizes unknown merchants using AI mock', () async {
      expect(await engine.categorize('Some Random Cafe'), 'Food & Dining'); // Cafe triggers AI fallback rule
      expect(await engine.categorize('City Hospital'), 'Health & Wellness'); // Hospital triggers AI fallback rule
      expect(await engine.categorize('Random Corp'), 'Miscellaneous'); // Default AI mock
    });
  });
}
