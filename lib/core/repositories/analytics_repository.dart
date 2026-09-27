import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class AnalyticsRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<double> getTotalRevenue() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(totalAmount), 0) as total FROM client_carts WHERE isPaid = 1',
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<Map<String, double>> getRevenueByConvention() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT c.id, c.name, COALESCE(SUM(cc.totalAmount), 0) as revenue
      FROM conventions c
      LEFT JOIN client_carts cc ON c.id = cc.conventionId AND cc.isPaid = 1
      GROUP BY c.id, c.name
      ORDER BY revenue DESC
    ''');

    // Include the id in the key so conventions with the same name stay distinct.
    return {
      for (final row in result)
        '${row['name']} (#${row['id']})': (row['revenue'] as num).toDouble(),
    };
  }

  Future<int> getTotalTransactions() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM client_carts WHERE isPaid = 1',
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<double> getAverageCartValue() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COALESCE(AVG(totalAmount), 0) as avg FROM client_carts WHERE isPaid = 1',
    );
    return (result.first['avg'] as num).toDouble();
  }

  Future<List<Map<String, dynamic>>> getTopSellingItems({int limit = 10}) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT i.id, i.name, SUM(ci.quantity) as totalQuantity,
             SUM(ci.quantity * ci.priceSnapshot) as totalRevenue
      FROM cart_items ci
      JOIN items i ON ci.itemId = i.id
      JOIN client_carts cc ON ci.cartId = cc.id
      WHERE cc.isPaid = 1
      GROUP BY i.id, i.name
      ORDER BY totalQuantity DESC
      LIMIT ?
    ''', [limit]);

    return result
        .map((row) => {
              'itemId': row['id'] as int,
              'name': row['name'] as String,
              'quantity': row['totalQuantity'] as int,
              'revenue': (row['totalRevenue'] as num).toDouble(),
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAllConventionStats() async {
    final db = await _databaseHelper.database;
    // Aggregate carts and cart items separately to avoid multiplying cart
    // totals when a paid cart contains multiple different items.
    final result = await db.rawQuery('''
      SELECT c.id, c.name,
        COALESCE(s.revenue, 0) as revenue,
        COALESCE(s.transactions, 0) as transactions,
        COALESCE(s.avgCart, 0) as avgCart,
        COALESCE(i.itemsSold, 0) as itemsSold
      FROM conventions c
      LEFT JOIN (
        SELECT conventionId, SUM(totalAmount) as revenue,
               COUNT(*) as transactions, AVG(totalAmount) as avgCart
        FROM client_carts
        WHERE isPaid = 1
        GROUP BY conventionId
      ) s ON c.id = s.conventionId
      LEFT JOIN (
        SELECT cc.conventionId, SUM(ci.quantity) as itemsSold
        FROM client_carts cc
        JOIN cart_items ci ON ci.cartId = cc.id
        WHERE cc.isPaid = 1
        GROUP BY cc.conventionId
      ) i ON c.id = i.conventionId
      ORDER BY revenue DESC
    ''');

    return result
        .map((row) => {
              'id': row['id'] as int,
              'name': row['name'] as String,
              'revenue': (row['revenue'] as num).toDouble(),
              'transactions': row['transactions'] as int,
              'avgCart': (row['avgCart'] as num).toDouble(),
              'itemsSold': row['itemsSold'] as int,
            })
        .toList();
  }
}
