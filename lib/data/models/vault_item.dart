enum VaultCategory { ktp, sim, bank, bpjs, warranty, note }

class VaultItem {
  final String id;
  final String title;
  final String numberOrCode;
  final String holderName;
  final VaultCategory category;
  final DateTime? expiryDate;
  final String? notes;

  VaultItem({
    required this.id,
    required this.title,
    required this.numberOrCode,
    required this.holderName,
    required this.category,
    this.expiryDate,
    this.notes,
  });

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysRemaining = expiryDate!.difference(DateTime.now()).inDays;
    return daysRemaining <= 30 && daysRemaining >= 0;
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'numberOrCode': numberOrCode,
    'holderName': holderName,
    'category': category.name,
    'expiryDate': expiryDate?.toIso8601String(),
    'notes': notes,
  };

  factory VaultItem.fromJson(Map<String, dynamic> json) => VaultItem(
    id: json['id'],
    title: json['title'],
    numberOrCode: json['numberOrCode'],
    holderName: json['holderName'] ?? '',
    category: VaultCategory.values.byName(json['category']),
    expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
    notes: json['notes'],
  );
}
