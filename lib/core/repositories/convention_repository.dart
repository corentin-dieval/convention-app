import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/convention.dart';

class ConventionRepository {
  final _db = DatabaseHelper.instance;

  Future<List<Convention>> getAll() async {
    final db = await _db.database;
    final rows =
        await db.query('conventions', orderBy: 'start_date DESC');
    return rows.map(Convention.fromMap).toList();
  }

  Future<Convention?> getById(int id) async {
    final db = await _db.database;
    final rows =
        await db.query('conventions', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Convention.fromMap(rows.first);
  }

  Future<Convention> insert(Convention convention) async {
    final db = await _db.database;
    final id = await db.insert('conventions', convention.toMap());
    return convention.copyWith(id: id);
  }

  Future<void> update(Convention convention) async {
    final db = await _db.database;
    await db.update(
      'conventions',
      convention.toMap(),
      where: 'id = ?',
      whereArgs: [convention.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('conventions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await _db.database;
    await db.delete('conventions');
  }

  Future<void> insertAll(List<Convention> conventions) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final c in conventions) {
      batch.insert('conventions', c.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
