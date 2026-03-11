import '../models/transaction.dart';
import 'package:uuid/uuid.dart';

class SmsParserService {
  final List<RegExp> _debitPatterns = [
    // Standard format: Rs 500.00 debited from a/c **1234 on 01-01-26 to SWIGGY
    RegExp(r"(?:Rs\.?|INR)\s*([\d,]+\.?\d*).*?debited.*?to\s+([A-Za-z0-9\s]+?)(?:(?:\.|$|Avl|Avail))", caseSensitive: false),
    // Spent format: Spent INR 50.0 on credit card ... at UBER 
    RegExp(r"spent\s*(?:Rs\.?|INR)\s*([\d,]+\.?\d*).*?(?:at|to)\s+([A-Za-z0-9\s]+?)(?:(?:\.|$|on))", caseSensitive: false),
    // UPI format: Rs.500 has been debited towards UPI/12345/Swiggy/...
    RegExp(r"(?:Rs\.?|INR)\s*([\d,]+\.?\d*).*?debited.*?UPI/.*?/([A-Za-z0-9\s]+?)/", caseSensitive: false),
    // Payment format: Payment of INR 3,000.00 to AMAZON via...
    RegExp(r"payment\s*of\s*(?:Rs\.?|INR)\s*([\d,]+\.?\d*).*?(?:to|towards)\s+([A-Za-z0-9\s]+?)(?:(?:\.|$|via|using))", caseSensitive: false),
  ];

  final List<RegExp> _creditPatterns = [
    // Standard format: Rs 5000.00 credited to a/c **1234
    RegExp(r"(?:Rs\.?|INR)\s*([\d,]+\.?\d*).*?credited", caseSensitive: false),
    // Salary format: Salary of Rs 50000 credited
    RegExp(r"salary.*?(?:Rs\.?|INR)\s*([\d,]+\.?\d*).*?credited", caseSensitive: false),
  ];

  TransactionModel? parseSms(String smsBody, DateTime smsDate) {
    // Check for debits
    for (var pattern in _debitPatterns) {
      final match = pattern.firstMatch(smsBody);
      if (match != null) {
        final amountString = match.group(1)?.replaceAll(',', '');
        final amount = double.tryParse(amountString ?? '');
        final merchant = match.groupCount >= 2 ? match.group(2)?.trim() : 'Unknown';
        
        if (amount != null) {
          return TransactionModel(
            id: const Uuid().v4(),
            date: smsDate,
            amount: amount,
            merchant: _cleanMerchantName(merchant ?? 'Unknown'),
            category: 'Uncategorized', // To be updated by Categorization Engine later
            type: 'Debit',
            notes: smsBody,
          );
        }
      }
    }

    // Check for credits
    for (var pattern in _creditPatterns) {
      final match = pattern.firstMatch(smsBody);
      if (match != null) {
        final amountString = match.group(1)?.replaceAll(',', '');
        final amount = double.tryParse(amountString ?? '');
        
        if (amount != null) {
          return TransactionModel(
            id: const Uuid().v4(),
            date: smsDate,
            amount: amount,
            merchant: 'Self/Deposit', // Credits usually don't have merchant info like debits do
            category: 'Income',
            type: 'Credit',
            notes: smsBody,
          );
        }
      }
    }

    return null; // Could not parse
  }

  String _cleanMerchantName(String rawMerchant) {
    // Remove extra trailing words from regex slop
    return rawMerchant.replaceAll(RegExp(r"on\s.*|at\s.*", caseSensitive: false), '').trim();
  }
}
