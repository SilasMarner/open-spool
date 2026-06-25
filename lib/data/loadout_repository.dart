import '../models/loadout.dart';
import 'db.dart';

/// CRUD for saved loadouts.
class LoadoutRepository {
  Future<List<Loadout>> all() async {
    final db = await AppDb.instance.database;
    final rows = await db.query('loadouts',
        orderBy: 'position ASC, name COLLATE NOCASE');
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
      // New favorites go to the end of the list.
      final row = loadout.toRow();
      final r = await db
          .rawQuery('SELECT COALESCE(MAX(position), -1) + 1 AS p FROM loadouts');
      row['position'] = r.first['p'] as int;
      return db.insert('loadouts', row);
    }
    await db.update('loadouts', loadout.toRow(),
        where: 'id = ?', whereArgs: [loadout.id]);
    return loadout.id!;
  }

  /// Re-insert a previously deleted favorite (keeps its id/position) — used to
  /// implement Undo. Positions are normalised separately via [reorder].
  Future<void> restore(Loadout loadout) async {
    final db = await AppDb.instance.database;
    await db.insert('loadouts', loadout.toRow());
  }

  /// Persist a new manual order: [orderedIds] is the favorites' ids top-to-
  /// bottom, written back as the `position` column.
  Future<void> reorder(List<int> orderedIds) async {
    final db = await AppDb.instance.database;
    final batch = db.batch();
    for (var i = 0; i < orderedIds.length; i++) {
      batch.update('loadouts', {'position': i},
          where: 'id = ?', whereArgs: [orderedIds[i]]);
    }
    await batch.commit(noResult: true);
  }

  Future<void> delete(int id) async {
    final db = await AppDb.instance.database;
    await db.delete('loadouts', where: 'id = ?', whereArgs: [id]);
  }
}
