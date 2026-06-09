import 'invoice_item.dart';

class Invoice {
  final int? id;
  final double total;
  final DateTime createdAt;
  final List<InvoiceItem>? items;

  Invoice({
    this.id,
    required this.total,
    DateTime? createdAt,
    this.items,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'total': total,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] as int?,
      total: (map['total'] as num).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Invoice copyWith({
    int? id,
    double? total,
    DateTime? createdAt,
    List<InvoiceItem>? items,
  }) {
    return Invoice(
      id: id ?? this.id,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
