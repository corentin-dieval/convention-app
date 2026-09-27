class Item {
  final int? id;
  final String name;
  final String description;
  final double unitPrice;
  final int stockQuantity;
  final String? imagePath;

  const Item({
    this.id,
    required this.name,
    required this.description,
    required this.unitPrice,
    required this.stockQuantity,
    this.imagePath,
  });

  Item copyWith({
    int? id,
    String? name,
    String? description,
    double? unitPrice,
    int? stockQuantity,
    String? imagePath,
    bool clearImage = false,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      unitPrice: unitPrice ?? this.unitPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imagePath: clearImage ? null : (imagePath ?? this.imagePath),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'description': description,
      'unit_price': unitPrice,
      'stock_quantity': stockQuantity,
      'image_path': imagePath,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      unitPrice: (map['unit_price'] as num).toDouble(),
      stockQuantity: map['stock_quantity'] as int,
      imagePath: map['image_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory Item.fromJson(Map<String, dynamic> json) => Item.fromMap(json);
}
