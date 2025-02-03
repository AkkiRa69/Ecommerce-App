import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const List<Map<String, dynamic>> products = [
  {
    "id": 924,
    "brand": "nyx",
    "name": "Sweet Cheeks Blush Palette",
    "price": "20.0",
    "price_sign": "\$",
    "currency": "USD",
    "image_link":
        "https://www.nyxcosmetics.com/dw/image/v2/AANG_PRD/on/demandware.static/-/Sites-cpd-nyxusa-master-catalog/default/dwa0a9cf48/ProductImages/2016/Face/Sweet_Cheeks_Blush_Palette/sweetcheeksblushpalette_main.jpg?sw=390&sh=390&sm=fit",
    "product_link":
        "https://www.nyxcosmetics.com/sweet-cheeks-blush-palette/NYX_359.html?cgid=blush",
    "website_link": "https://www.nyxcosmetics.com",
    "description":
        "Get swept away by our drop-dead gorgeous Sweet Cheeks Blush Palette. This collection features eight highly pigmented and buttery-smooth colors that flawlessly suit any skin tone.",
    "rating": null,
    "category": null,
    "product_type": "blush",
    "tag_list": [],
    "created_at": "2017-12-24T02:28:47.814Z",
    "updated_at": "2017-12-24T02:30:48.645Z",
  },
  // Add other product data here...
];

class ProductDatabase {
  static final ProductDatabase instance = ProductDatabase._init();
  static Database? _database;

  ProductDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('product.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    print('Database Path: $path'); // Print the database path for debugging

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        brand TEXT,
        name TEXT,
        price TEXT,
        price_sign TEXT,
        currency TEXT,
        image_link TEXT,
        product_link TEXT,
        website_link TEXT,
        description TEXT,
        rating REAL,
        category TEXT,
        product_type TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future<void> insertProducts() async {
    final db = await instance.database;
    try {
      for (var product in products) {
        await db.insert(
          'products',
          product,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      print('Data inserted successfully!');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await instance.database;
    return await db.query('products');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

void main() async {
  final db = ProductDatabase.instance;

  // Insert predefined product data into the database
  await db.insertProducts();

  // Fetch all products from the database
  final products = await db.getAllProducts();
  print(products);

  // Close the database
  await db.close();
}
