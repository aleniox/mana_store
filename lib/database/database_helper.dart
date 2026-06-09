import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'mana_store.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        image_path TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.rollback);
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> upsertProductByBarcode(Product product) async {
    final db = await database;
    final existing = await getProductByBarcode(product.barcode);
    if (existing != null) {
      await db.update(
        'products',
        product.copyWith(id: existing.id).toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    } else {
      await db.insert('products', product.toMap());
    }
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products', orderBy: 'name ASC');
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: 'name LIKE ? OR barcode LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<int> insertInvoice(Invoice invoice, List<InvoiceItem> items) async {
    final db = await database;
    return await db.transaction((txn) async {
      final invoiceId = await txn.insert('invoices', invoice.toMap());
      for (final item in items) {
        await txn.insert('invoice_items', item.copyWith(invoiceId: invoiceId).toMap());
        await txn.rawUpdate(
          'UPDATE products SET stock = stock - ? WHERE id = ?',
          [item.quantity, item.productId],
        );
      }
      return invoiceId;
    });
  }

  Future<List<Invoice>> getAllInvoices() async {
    final db = await database;
    final maps = await db.query('invoices', orderBy: 'created_at DESC');
    return maps.map((m) => Invoice.fromMap(m)).toList();
  }

  Future<Invoice?> getInvoiceWithItems(int id) async {
    final db = await database;
    final invoiceMaps = await db.query(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (invoiceMaps.isEmpty) return null;
    final invoice = Invoice.fromMap(invoiceMaps.first);
    final itemMaps = await db.query(
      'invoice_items',
      where: 'invoice_id = ?',
      whereArgs: [id],
    );
    final items = itemMaps.map((m) => InvoiceItem.fromMap(m)).toList();
    return invoice.copyWith(items: items);
  }

  Future<double> getTodayRevenue() async {
    final db = await database;
    final startOfDay = DateTime.now().copyWith(
      hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0,
    );
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(total), 0) as total FROM invoices WHERE created_at >= ?',
      [startOfDay.millisecondsSinceEpoch],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<int> getTodayInvoiceCount() async {
    final db = await database;
    final startOfDay = DateTime.now().copyWith(
      hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0,
    );
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM invoices WHERE created_at >= ?',
      [startOfDay.millisecondsSinceEpoch],
    );
    return result.first['count'] as int;
  }

  Future<int> getProductCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    return result.first['count'] as int;
  }

  Future<List<Invoice>> getInvoicesInRange(DateTime from, DateTime to) async {
    final db = await database;
    final maps = await db.query(
      'invoices',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [from.millisecondsSinceEpoch, to.millisecondsSinceEpoch],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Invoice.fromMap(m)).toList();
  }

  Future<double> getYearlyRevenue(int year) async {
    final db = await database;
    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31, 23, 59, 59, 999);
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(total), 0) as total FROM invoices WHERE created_at >= ? AND created_at <= ?',
      [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<double> getMonthlyRevenue(int year, int month) async {
    final db = await database;
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(total), 0) as total FROM invoices WHERE created_at >= ? AND created_at <= ?',
      [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    return (result.first['total'] as num).toDouble();
  }

  Future<List<Map<String, dynamic>>> getRevenueByMonth(int year) async {
    final db = await database;
    final start = DateTime(year, 1, 1);
    final end = DateTime(year, 12, 31, 23, 59, 59, 999);
    final result = await db.rawQuery(
      '''SELECT CAST(strftime('%m', created_at / 1000, 'unixepoch') AS INTEGER) as month,
         COALESCE(SUM(total), 0) as revenue,
         COUNT(*) as count
         FROM invoices
         WHERE created_at >= ? AND created_at <= ?
         GROUP BY month ORDER BY month''',
      [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> getRevenueByYear() async {
    final db = await database;
    final result = await db.rawQuery(
      '''SELECT CAST(strftime('%Y', created_at / 1000, 'unixepoch') AS INTEGER) as year,
         COALESCE(SUM(total), 0) as revenue,
         COUNT(*) as count
         FROM invoices
         GROUP BY year ORDER BY year DESC''',
    );
    return result;
  }

  Future<String> exportDatabase() async {
    final dbPath = await getDatabasesPath();
    return p.join(dbPath, 'mana_store.db');
  }

  Future<void> importDatabase(String sourcePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'mana_store.db');
    
    // Close existing connection
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    // Copy new database file
    final sourceFile = File(sourcePath);
    await sourceFile.copy(path);
    
    // Re-open
    _database = await _initDatabase();
  }
}
