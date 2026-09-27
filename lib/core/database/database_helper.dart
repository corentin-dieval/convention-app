import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _dbName = 'convention_app.db';
  static const _dbVersion = 3;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        unit_price REAL NOT NULL,
        stock_quantity INTEGER NOT NULL DEFAULT 0,
        image_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE conventions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        is_closed INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE convention_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        convention_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        item_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price_snapshot REAL NOT NULL,
        FOREIGN KEY (convention_id) REFERENCES conventions (id) ON DELETE CASCADE,
        FOREIGN KEY (item_id) REFERENCES items (id)
      )
    ''');

    // Client Carts (anonymous carts during convention)
    await db.execute('''
      CREATE TABLE client_carts (
        id TEXT PRIMARY KEY,
        conventionId TEXT NOT NULL,
        cartNumber INTEGER NOT NULL,
        totalAmount REAL NOT NULL DEFAULT 0.0,
        isPaid INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        paidAt TEXT,
        paymentMethod TEXT,
        FOREIGN KEY (conventionId) REFERENCES conventions(id)
      )
    ''');

    // Cart Items (items in a client cart)
    await db.execute('''
      CREATE TABLE cart_items (
        id TEXT PRIMARY KEY,
        cartId TEXT NOT NULL,
        itemId TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        priceSnapshot REAL NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (cartId) REFERENCES client_carts(id),
        FOREIGN KEY (itemId) REFERENCES items(id)
      )
    ''');

    // Index for faster queries
    await db.execute('CREATE INDEX idx_client_carts_convention ON client_carts(conventionId)');
    await db.execute('CREATE INDEX idx_cart_items_cart ON cart_items(cartId)');;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS client_carts (
            id TEXT PRIMARY KEY,
            conventionId TEXT NOT NULL,
            cartNumber INTEGER NOT NULL,
            totalAmount REAL NOT NULL DEFAULT 0.0,
            isPaid INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL,
            paidAt TEXT,
            paymentMethod TEXT,
            FOREIGN KEY (conventionId) REFERENCES conventions(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS cart_items (
            id TEXT PRIMARY KEY,
            cartId TEXT NOT NULL,
            itemId TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            priceSnapshot REAL NOT NULL,
            createdAt TEXT NOT NULL,
            FOREIGN KEY (cartId) REFERENCES client_carts(id),
            FOREIGN KEY (itemId) REFERENCES items(id)
          )
        ''');

        await db.execute('CREATE INDEX IF NOT EXISTS idx_client_carts_convention ON client_carts(conventionId)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_cart_items_cart ON cart_items(cartId)');
      } catch (e) {
        print('Migration error (non-critical): $e');
      }
    }
    if (oldVersion < 3) {
      // Add paymentMethod column to client_carts
      try {
        await db.execute('ALTER TABLE client_carts ADD COLUMN paymentMethod TEXT');
      } catch (e) {
        // Column may already exist on fresh installs
      }
    }
  }

  Future<void> close() async => _db?.close();
}
