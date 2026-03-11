import 'ai_categorization_service.dart';

class CategorizationEngine {
  final AICategorizationService _aiService = AICategorizationService();

  // A simple static map for Phase 1. 
  // In Phase 2, this will be supplemented by an AI API.
  static const Map<String, String> _merchantRules = {
    'swiggy': 'Food & Dining',
    'zomato': 'Food & Dining',
    'uber': 'Travel',
    'ola': 'Travel',
    'netflix': 'Entertainment',
    'amazon': 'Shopping',
    'flipkart': 'Shopping',
    'irctc': 'Travel',
    'bigbasket': 'Groceries',
    'blinkit': 'Groceries',
    'zepto': 'Groceries',
    'jio': 'Utilities',
    'airtel': 'Utilities',
    'bescom': 'Utilities',
    'dmark': 'Groceries',
    'starbucks': 'Food & Dining',
  };

  /// Categorization with AI Fallback.
  /// If it finds a sub-string match in our rules, it returns the category.
  Future<String> categorize(String merchantName) async {
    if (merchantName.isEmpty || merchantName.toLowerCase() == 'unknown') {
      return 'Uncategorized';
    }

    final lowerMerchant = merchantName.toLowerCase();

    for (var entry in _merchantRules.entries) {
      if (lowerMerchant.contains(entry.key)) {
        return entry.value;
      }
    }

    // AI Fallback
    return await _aiService.categorizeMerchantWithAI(merchantName);
  }
}
