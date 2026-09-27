import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/client_cart.dart';
import '../models/cart_item.dart';
import 'package:uuid/uuid.dart';

class ClientCartRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  static const uuid = Uuid();

  Future<String> createCart(ClientCart cart) async {
    final db = await _databaseHelper.database;
    await db.insert('client_carts', cart.toMap());
    return cart.id;
  }

  Future<List<ClientCart>> getCartsByConvention(String conventionId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'client_carts',
      where: 'conventionId = ?',
      whereArgs: [conventionId],
      orderBy: 'cartNumber ASC',
    );
    return result.map((map) => ClientCart.fromMap(map)).toList();
  }

  Future<int> getNextCartNumber(String conventionId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT MAX(cartNumber) as maxNum FROM client_carts WHERE conventionId = ?',
      [conventionId],
    );
    final maxNum = result.first['maxNum'] as int?;
    return (maxNum ?? 0) + 1;
  }

  Future<void> updateCartTotal(String cartId, double totalAmount) async {
    final db = await _databaseHelper.database;
    await db.update(
      'client_carts',
      {'totalAmount': totalAmount},
      where: 'id = ?',
      whereArgs: [cartId],
    );
  }

  Future<void> markCartAsPaid(String cartId, {String? paymentMethod}) async {
    final db = await _databaseHelper.database;
    await db.update(
      'client_carts',
      {
        'isPaid': 1,
        'paidAt': DateTime.now().toIso8601String(),
        'paymentMethod': paymentMethod,
      },
      where: 'id = ?',
      whereArgs: [cartId],
    );
  }

  Future<void> deleteCart(String cartId) async {
    final db = await _databaseHelper.database;
    await db.delete('cart_items', where: 'cartId = ?', whereArgs: [cartId]);
    await db.delete('client_carts', where: 'id = ?', whereArgs: [cartId]);
  }
}

class CartItemRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  static const uuid = Uuid();

  Future<String> addItemToCart(CartItem cartItem) async {
    final db = await _databaseHelper.database;
    await db.insert('cart_items', cartItem.toMap());
    return cartItem.id;
  }

  Future<List<CartItem>> getCartItems(String cartId) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'cart_items',
      where: 'cartId = ?',
      whereArgs: [cartId],
      orderBy: 'createdAt ASC',
    );
    return result.map((map) => CartItem.fromMap(map)).toList();
  }

  Future<void> updateItemQuantity(String cartItemId, int quantity) async {
    final db = await _databaseHelper.database;
    if (quantity <= 0) {
      await db.delete('cart_items', where: 'id = ?', whereArgs: [cartItemId]);
    } else {
      await db.update(
        'cart_items',
        {'quantity': quantity},
        where: 'id = ?',
        whereArgs: [cartItemId],
      );
    }
  }

  Future<void> removeItemFromCart(String cartItemId) async {
    final db = await _databaseHelper.database;
    await db.delete('cart_items', where: 'id = ?', whereArgs: [cartItemId]);
  }
}

