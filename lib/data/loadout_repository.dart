import '../models/loadout.dart';
import 'db.dart';

/// CRUD for saved loadouts.
class LoadoutRepository {
  Future<List<Loadout>> all() async {
    final db = await AppDb.instance.database;
    final rows = await db.query('loadouts', orderBy: 'name COLLATE NOCASE');
    return rows.map(Loadout.fromRow).toList();
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
