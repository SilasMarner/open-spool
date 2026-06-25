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
      version: 2,
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          // Add a manual sort order. Seed it from the previous name ordering so
          // existing favorites keep a stable position on first launch.
          await db.execute(
              'ALTER TABLE loadouts ADD COLUMN position INTEGER NOT NULL DEFAULT 0');
          final rows = await db.query('loadouts', orderBy: 'name COLLATE NOCASE');
          for (var i = 0; i < rows.length; i++) {
            await db.update('loadouts', {'position': i},
                where: 'id = ?', whereArgs: [rows[i]['id']]);
          }
        }
      },
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE loadouts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            reel_id TEXT NOT NULL,
            mode TEXT NOT NULL,
            segments TEXT NOT NULL,
            position INTEGER NOT NULL DEFAULT 0
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
