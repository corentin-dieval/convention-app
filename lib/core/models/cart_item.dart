class CartItem {
  final String id;
  final String cartId;
  final String itemId;
  final int quantity;
  final double priceSnapshot;
  final DateTime createdAt;

  CartItem({
    required this.id,
    required this.cartId,
    required this.itemId,
    required this.quantity,
    required this.priceSnapshot,
    required this.createdAt,
  });

  CartItem copyWith({
    String? id,
    String? cartId,
    String? itemId,
    int? quantity,
    double? priceSnapshot,
    DateTime? createdAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      priceSnapshot: priceSnapshot ?? this.priceSnapshot,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cartId': cartId,
      'itemId': itemId,
      'quantity': quantity,
      'priceSnapshot': priceSnapshot,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      cartId: map['cartId'] as String,
      itemId: map['itemId'] as String,
      quantity: map['quantity'] as int,
      priceSnapshot: (map['priceSnapshot'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

