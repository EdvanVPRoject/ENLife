enum TransactionType { income, expense }

class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? note;

  TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'type': type.name,
    'category': category,
    'date': date.toIso8601String(),
    'note': note,
  };

  factory TransactionItem.fromJson(Map<String, dynamic> json) => TransactionItem(
    id: json['id'],
    title: json['title'],
    amount: (json['amount'] as num).toDouble(),
    type: TransactionType.values.byName(json['type']),
    category: json['category'],
    date: DateTime.parse(json['date']),
    note: json['note'],
  );
}
