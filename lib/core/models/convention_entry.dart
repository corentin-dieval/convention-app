class ConventionEntry {
  final int? id;
  final int conventionId;
  final int itemId;
  final String itemName;
  final int quantity;
  final double priceSnapshot;

  const ConventionEntry({
    this.id,
    required this.conventionId,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.priceSnapshot,
  });

  double get lineTotal => quantity * priceSnapshot;

  ConventionEntry copyWith({
    int? id,
    int? conventionId,
    int? itemId,
    String? itemName,
    int? quantity,
    double? priceSnapshot,
  }) {
    return ConventionEntry(
      id: id ?? this.id,
      conventionId: conventionId ?? this.conventionId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      priceSnapshot: priceSnapshot ?? this.priceSnapshot,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'convention_id': conventionId,
      'item_id': itemId,
      'item_name': itemName,
      'quantity': quantity,
      'price_snapshot': priceSnapshot,
    };
  }

  factory ConventionEntry.fromMap(Map<String, dynamic> map) {
    return ConventionEntry(
      id: map['id'] as int?,
      conventionId: map['convention_id'] as int,
      itemId: map['item_id'] as int,
      itemName: map['item_name'] as String,
      quantity: map['quantity'] as int,
      priceSnapshot: (map['price_snapshot'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory ConventionEntry.fromJson(Map<String, dynamic> json) =>
      ConventionEntry.fromMap(json);
}
