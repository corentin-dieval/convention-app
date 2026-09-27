import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/convention_entry.dart';

class ConventionEntryRepository {
  final _db = DatabaseHelper.instance;

  Future<List<ConventionEntry>> getForConvention(int conventionId) async {
    final db = await _db.database;
    final rows = await db.query(
      'convention_entries',
      where: 'convention_id = ?',
      whereArgs: [conventionId],
      orderBy: 'item_name ASC',
    );
    return rows.map(ConventionEntry.fromMap).toList();
  }

  Future<ConventionEntry> insert(ConventionEntry entry) async {
    final db = await _db.database;
    final id = await db.insert('convention_entries', entry.toMap());
    return entry.copyWith(id: id);
  }

  Future<void> update(ConventionEntry entry) async {
    final db = await _db.database;
    await db.update(
      'convention_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.delete('convention_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllForConvention(int conventionId) async {
    final db = await _db.database;
    await db.delete(
      'convention_entries',
      where: 'convention_id = ?',
      whereArgs: [conventionId],
    );
  }

  Future<void> deleteAll() async {
    final db = await _db.database;
    await db.delete('convention_entries');
  }

  Future<void> insertAll(List<ConventionEntry> entries) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final e in entries) {
      batch.insert('convention_entries', e.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
}
