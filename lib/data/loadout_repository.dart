import '../models/loadout.dart';
import 'db.dart';

/// CRUD for saved loadouts.
class LoadoutRepository {
  Future<List<Loadout>> all() async {
    final db = await AppDb.instance.database;
    final rows = await db.query('loadouts', orderBy: 'name COLLATE NOCASE');
    return rows.map(Loadout.fromRow).toList();
  }

  /// Returns an existing saved loadout with the same reel, fill mode and
  /// segments (lines + pinned lengths) as [loadout], or null if none — used to
  /// block saving the same setup twice. Name is intentionally ignored.
  Future<Loadout?> findDuplicate(Loadout loadout) async {
    final db = await AppDb.instance.database;
    final row = loadout.toRow();
    final rows = await db.query(
      'loadouts',
      where: 'reel_id = ? AND mode = ? AND segments = ?',
      whereArgs: [row['reel_id'], row['mode'], row['segments']],
      limit: 1,
    );
    return rows.isEmpty ? null : Loadout.fromRow(rows.first);
  }

  Future<int> save(Loadout loadout) async {
    final db = await AppDb.instance.database;
    if (loadout.id == null) {
      return db.insert('loadouts', loadout.toRow());
    }
    await db.update('loadouts', loadout.toRow(),
        where: 'id = ?', whereArgs: [loadout.id]);
    return loadout.id!;
  }

  Future<void> delete(int id) async {
    final db = await AppDb.instance.database;
    await db.delete('loadouts', where: 'id = ?', whereArgs: [id]);
  }
}
