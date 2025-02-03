import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LoginHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_db.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
        CREATE TABLE users (
          user_id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          password TEXT,
          first_name TEXT,
          last_name TEXT
        )
      ''');
      },
    );
  }

  static Future<void> registerUser(String username, String password,
      String firstName, String lastName) async {
    final db = await database;
    await db.insert('users', {
      'username': username,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
    });
  }

  static Future<bool> checkUserExists(String username, String password) async {
    final db = await database;
    var result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  static Future<Map<String, dynamic>?> getUserDetails(String username) async {
    final db = await database;
    var result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first : null;
  }
}
