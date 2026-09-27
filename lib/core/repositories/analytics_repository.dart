import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class AnalyticsRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<double> getTotalRevenue() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(totalAmount) as total FROM client_carts WHERE isPaid = 1',
    );
    final total = result.first['total'] as double?;
    return total ?? 0.0;
  }

  Future<Map<String, double>> getRevenueByConvention() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT c.id, c.name, COALESCE(SUM(cc.totalAmount), 0) as revenue
      FROM conventions c
      LEFT JOIN client_carts cc ON c.id = cc.conventionId AND cc.isPaid = 1
      GROUP BY c.id
      ORDER BY revenue DESC
    ''');

    final map = <String, double>{};
    for (final row in result) {
      final name = row['name'] as String;
      final revenue = (row['revenue'] as num).toDouble();
      map[name] = revenue;
    }
    return map;
  }

  Future<int> getTotalTransactions() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM client_carts WHERE isPaid = 1',
    );
    final count = result.first['count'] as int?;
    return count ?? 0;
  }

  Future<double> getAverageCartValue() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT AVG(totalAmount) as avg FROM client_carts WHERE isPaid = 1',
    );
    final avg = result.first['avg'] as double?;
    return avg ?? 0.0;
  }

  Future<List<Map<String, dynamic>>> getTopSellingItems({int limit = 10}) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT i.id, i.name, SUM(ci.quantity) as totalQuantity, SUM(ci.quantity * ci.priceSnapshot) as totalRevenue
      FROM cart_items ci
      JOIN items i ON ci.itemId = i.id
      JOIN client_carts cc ON ci.cartId = cc.id
      WHERE cc.isPaid = 1
      GROUP BY i.id
      ORDER BY totalQuantity DESC
      LIMIT ?
    ''', [limit]);

    return result.map((row) => {
      'itemId': row['id'] as String,
      'name': row['name'] as String,
      'quantity': row['totalQuantity'] as int,
      'revenue': (row['totalRevenue'] as num).toDouble(),
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getAllConventionStats() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        c.id,
        c.name,
        COALESCE(SUM(cc.totalAmount), 0) as revenue,
        COUNT(DISTINCT CASE WHEN cc.isPaid = 1 THEN cc.id END) as transactions,
        COALESCE(AVG(CASE WHEN cc.isPaid = 1 THEN cc.totalAmount END), 0) as avgCart,
        COUNT(ci.id) as itemsSold
      FROM conventions c
      LEFT JOIN client_carts cc ON c.id = cc.conventionId
      LEFT JOIN cart_items ci ON cc.id = ci.cartId
      GROUP BY c.id
      ORDER BY revenue DESC
    ''');

    return result.map((row) => {
      'id': row['id'] as String,
      'name': row['name'] as String,
      'revenue': (row['revenue'] as num).toDouble(),
      'transactions': row['transactions'] as int,
      'avgCart': (row['avgCart'] as num).toDouble(),
      'itemsSold': row['itemsSold'] as int,
    }).toList();
  }
}

