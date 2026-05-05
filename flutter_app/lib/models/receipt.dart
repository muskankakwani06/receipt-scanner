import 'dart:convert';

class Receipt {
  final int? id;
  final String merchant;
  final DateTime date;
  final double subtotal;
  final double tax;
  final double total;
  final String currency;
  final List<ReceiptItem> items;
  final DateTime savedAt;
  final String? imageUrl;

  Receipt({
    this.id,
    required this.merchant,
    required this.date,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.currency,
    required this.items,
    required this.savedAt,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'merchant': merchant,
      'date': date.toIso8601String(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'currency': currency,
      'items': jsonEncode(items.map((x) => x.toMap()).toList()),
      'savedAt': savedAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'],
      merchant: map['merchant'] ?? '',
      date: DateTime.parse(map['date']),
      subtotal: map['subtotal']?.toDouble() ?? 0.0,
      tax: map['tax']?.toDouble() ?? 0.0,
      total: map['total']?.toDouble() ?? 0.0,
      currency: map['currency'] ?? '₹',
      items: List<ReceiptItem>.from(
        jsonDecode(map['items'] ?? '[]').map((x) => ReceiptItem.fromMap(x)),
      ),
      savedAt: DateTime.parse(map['savedAt']),
      imageUrl: map['imageUrl'],
    );
  }

  Receipt copyWith({
    int? id,
    String? merchant,
    DateTime? date,
    double? subtotal,
    double? tax,
    double? total,
    String? currency,
    List<ReceiptItem>? items,
    DateTime? savedAt,
    String? imageUrl,
  }) {
    return Receipt(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      items: items ?? this.items,
      savedAt: savedAt ?? this.savedAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class ReceiptItem {
  final String name;
  final double price;
  final String category;

  ReceiptItem({
    required this.name,
    required this.price,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
    };
  }

  factory ReceiptItem.fromMap(Map<String, dynamic> map) {
    return ReceiptItem(
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      category: map['category'] ?? 'Other',
    );
  }
}
