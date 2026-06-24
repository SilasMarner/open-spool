import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Local SQLite store for user-created data: saved loadouts plus any custom
/// reels and lines. The shipped catalog stays read-only in JSON assets.
class AppDb {
  AppDb._();
  static final AppDb instance = AppDb._();

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      p.join(dir, 'reel_planner.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE loadouts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            reel_id TEXT NOT NULL,
            mode TEXT NOT NULL,
            segments TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE custom_reels (
            id TEXT PRIMARY KEY,
            brand TEXT NOT NULL,
            model TEXT NOT NULL,
            type TEXT NOT NULL,
            anchor_diameter_in REAL NOT NULL,
            anchor_yards REAL NOT NULL,
            anchor_label TEXT NOT NULL,
            source TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE custom_lines (
            id TEXT PRIMARY KEY,
            brand TEXT NOT NULL,
            product TEXT NOT NULL,
            type TEXT NOT NULL,
            lb_test REAL NOT NULL,
            diameter_in REAL NOT NULL,
            packing_factor REAL NOT NULL,
            source TEXT
          )
        ''');
      },
    );
  }
}
