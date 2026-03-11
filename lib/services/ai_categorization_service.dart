class AICategorizationService {
  // Simulate network delay for calling an LLM
  Future<String> categorizeMerchantWithAI(String merchantName) async {
    await Future.delayed(const Duration(seconds: 1)); // Mock latency

    final normalized = merchantName.toLowerCase();

    // Simulating LLM inferences
    if (normalized.contains('cafe') || normalized.contains('bistro')) {
      return 'Food & Dining';
    } else if (normalized.contains('fuel') || normalized.contains('petrol')) {
      return 'Auto & Transport';
    } else if (normalized.contains('pharmacy') || normalized.contains('hospital')) {
      return 'Health & Wellness';
    } else if (normalized.contains('hotel') || normalized.contains('resort')) {
      return 'Travel';
    }

    // Default return if LLM fails
    return 'Miscellaneous'; 
  }
}
