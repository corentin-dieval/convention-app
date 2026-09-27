class ClientCart {
  final String id;
  final String conventionId;
  final int cartNumber;
  final double totalAmount;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? paymentMethod; // 'cash' | 'card'

  ClientCart({
    required this.id,
    required this.conventionId,
    required this.cartNumber,
    this.totalAmount = 0.0,
    this.isPaid = false,
    required this.createdAt,
    this.paidAt,
    this.paymentMethod,
  });

  ClientCart copyWith({
    String? id,
    String? conventionId,
    int? cartNumber,
    double? totalAmount,
    bool? isPaid,
    DateTime? createdAt,
    DateTime? paidAt,
    String? paymentMethod,
  }) {
    return ClientCart(
      id: id ?? this.id,
      conventionId: conventionId ?? this.conventionId,
      cartNumber: cartNumber ?? this.cartNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conventionId': conventionId,
      'cartNumber': cartNumber,
      'totalAmount': totalAmount,
      'isPaid': isPaid ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'paymentMethod': paymentMethod,
    };
  }

  factory ClientCart.fromMap(Map<String, dynamic> map) {
    return ClientCart(
      id: map['id'] as String,
      conventionId: map['conventionId'] as String,
      cartNumber: map['cartNumber'] as int,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      isPaid: (map['isPaid'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      paidAt: map['paidAt'] != null ? DateTime.parse(map['paidAt'] as String) : null,
      paymentMethod: map['paymentMethod'] as String?,
    );
  }
}

