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
      version: 3, // bump this number whenever the schema below changes
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE addresses (
            id TEXT PRIMARY KEY,
            label TEXT NOT NULL UNIQUE,
            is_default INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE schedules (
            id TEXT PRIMARY KEY,
            address_id TEXT NOT NULL,
            bin_type TEXT NOT NULL,
            collection_weekday INTEGER NOT NULL,
            repeat_interval TEXT NOT NULL,
            start_date TEXT NOT NULL,
            notification_time TEXT,
            is_archived INTEGER NOT NULL DEFAULT 0,
            reminder_timing TEXT NOT NULL DEFAULT 'eveningBefore',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (address_id) REFERENCES addresses(id) ON DELETE CASCADE
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE addresses RENAME TO addresses_old',
          );

          await db.execute('''
            CREATE TABLE addresses (
              id TEXT PRIMARY KEY,
              label TEXT NOT NULL UNIQUE,
              is_default INTEGER NOT NULL DEFAULT 0,
              created_at TEXT NOT NULL
            )
          ''');

          await db.execute('''
            INSERT INTO addresses (
              id,
              label,
              is_default,
              created_at
            )
            SELECT
              id,
              label,
              is_default,
              created_at
            FROM addresses_old
          ''');

          await db.execute('DROP TABLE addresses_old');

          await db.execute('''
            ALTER TABLE schedules
            ADD COLUMN reminder_timing TEXT NOT NULL
            DEFAULT 'eveningBefore'
          ''');
        }

        if (oldVersion < 3) {
          await db.execute('''
            CREATE TABLE schedules_new (
              id TEXT PRIMARY KEY,
              address_id TEXT NOT NULL,
              bin_type TEXT NOT NULL,
              collection_weekday INTEGER NOT NULL,
              repeat_interval TEXT NOT NULL,
              start_date TEXT NOT NULL,
              notification_time TEXT,
              is_archived INTEGER NOT NULL DEFAULT 0,
              reminder_timing TEXT NOT NULL DEFAULT 'eveningBefore',
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              FOREIGN KEY (address_id) REFERENCES addresses(id) ON DELETE CASCADE
            )
          ''');

          await db.execute('''
            INSERT INTO schedules_new (
              id,
              address_id,
              bin_type,
              collection_weekday,
              repeat_interval,
              start_date,
              notification_time,
              is_archived,
              reminder_timing,
              created_at,
              updated_at
            )
            SELECT
              id,
              address_id,
              bin_type,
              collection_weekday,
              repeat_interval,
              start_date,
              notification_time,
              is_archived,
              reminder_timing,
              created_at,
              updated_at
            FROM schedules
          ''');

          await db.execute('DROP TABLE schedules');

          await db.execute(
            'ALTER TABLE schedules_new RENAME TO schedules',
          );
        }
      },
    );
  }
}