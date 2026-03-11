class TransactionModel {
  final String id;
  final DateTime date;
  final double amount;
  final String merchant;
  final String category;
  final String type; // 'Debit' or 'Credit'
  final double? balance;
  final String? notes;
  final bool isManuallyCategorized;

  TransactionModel({
    required this.id,
    required this.date,
    required this.amount,
    required this.merchant,
    required this.category,
    required this.type,
    this.balance,
    this.notes,
    this.isManuallyCategorized = false,
  });

  TransactionModel copyWith({
    String? id,
    DateTime? date,
    double? amount,
    String? merchant,
    String? category,
    String? type,
    double? balance,
    String? notes,
    bool? isManuallyCategorized,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      notes: notes ?? this.notes,
      isManuallyCategorized: isManuallyCategorized ?? this.isManuallyCategorized,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'amount': amount,
      'merchant': merchant,
      'category': category,
      'type': type,
      'balance': balance,
      'notes': notes,
      'is_manually_categorized': isManuallyCategorized ? 1 : 0,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      amount: map['amount'],
      merchant: map['merchant'],
      category: map['category'],
      type: map['type'],
      balance: map['balance'],
      notes: map['notes'],
      isManuallyCategorized: map['is_manually_categorized'] == 1,
    );
  }
}
