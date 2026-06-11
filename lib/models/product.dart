class Product {
  final int? id;
  final String barcode;
  final String name;
  final double price;
  final int stock;
  final String? imagePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    this.id,
    required this.barcode,
    required this.name,
    required this.price,
    this.stock = 0,
    this.imagePath,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'barcode': barcode,
      'name': name,
      'price': price,
      'stock': stock,
      'image_path': imagePath,
      'created_at': createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      barcode: map['barcode'] as String,
      name: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int? ?? 0,
      imagePath: map['image_path'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

  Product copyWith({
    int? id,
    String? barcode,
    String? name,
    double? price,
    int? stock,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
