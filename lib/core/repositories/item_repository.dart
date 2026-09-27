import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/item.dart';

class ItemRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Item>> getAll() async {
    final db = await _db.database;
    final rows = await db.query('items', orderBy: 'name ASC');
    return rows.map(Item.fromMap).toList();
  }

  Future<Item?> getById(int id) async {
    final db = await _db.database;
    final rows = await db.query('items', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Item.fromMap(rows.first);
  }

  Future<Item> insert(Item item) async {
    final db = await _db.database;
    final id = await db.insert('items', item.toMap());
    return item.copyWith(id: id);
  }

  Future<void> update(Item item) async {
    final db = await _db.database;
    await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await _db.database;
    await db.delete('items');
  }

  Future<void> decrementStock(int itemId, int quantity) async {
    final db = await _db.database;
    await db.rawUpdate(
      'UPDATE items SET stock_quantity = MAX(0, stock_quantity - ?) WHERE id = ?',
      [quantity, itemId],
    );
  }

  Future<void> insertAll(List<Item> items) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final item in items) {
      batch.insert('items', item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
