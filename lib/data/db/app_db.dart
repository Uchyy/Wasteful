// data/database/app_database.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wasteful.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE addresses (
            id TEXT PRIMARY KEY,
            label TEXT NOT NULL,
            is_default INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE schedules (
            id TEXT PRIMARY KEY,
            address_id TEXT NOT NULL,
            collection_weekday INTEGER NOT NULL,
            repeat_interval TEXT NOT NULL,
            start_date TEXT NOT NULL,
            notification_time TEXT,
            is_archived INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (address_id) REFERENCES addresses (id) ON DELETE CASCADE
          )
        ''');

        // Join table: a schedule can cover multiple bin types
        await db.execute('''
          CREATE TABLE schedule_bin_types (
            schedule_id TEXT NOT NULL,
            bin_type TEXT NOT NULL,
            PRIMARY KEY (schedule_id, bin_type),
            FOREIGN KEY (schedule_id) REFERENCES schedules (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }
}