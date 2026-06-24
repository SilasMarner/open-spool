import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import '../models/line.dart';
import '../models/reel.dart';
import 'db.dart';

/// In-memory catalog of reels and lines: the bundled JSON assets merged with any
/// user-created custom entries from the local DB. Call [load] once at startup;
/// call [reload] after adding/removing custom entries.
class Catalog {
  Catalog._();
  static final Catalog instance = Catalog._();

  final List<Reel> reels = [];
  final List<Line> lines = [];

  final Map<String, Reel> _reelById = {};
  final Map<String, Line> _lineById = {};

  Reel? reel(String id) => _reelById[id];
  Line? line(String id) => _lineById[id];

  Future<void> load() async {
    final reelJson = jsonDecode(await rootBundle.loadString('assets/data/reels.json'))
        as Map<String, dynamic>;
    final lineJson = jsonDecode(await rootBundle.loadString('assets/data/lines.json'))
        as Map<String, dynamic>;

    final seedReels = (reelJson['reels'] as List)
        .map((e) => Reel.fromJson(e as Map<String, dynamic>))
        .toList();
    final seedLines = (lineJson['lines'] as List)
        .map((e) => Line.fromJson(e as Map<String, dynamic>))
        .toList();

    final db = await AppDb.instance.database;
    final customReelRows = await db.query('custom_reels');
    final customLineRows = await db.query('custom_lines');

    final customReels =
        customReelRows.map((r) => Reel.fromJson(r, custom: true)).toList();
    final customLines =
        customLineRows.map((r) => Line.fromJson(r, custom: true)).toList();

    reels
      ..clear()
      ..addAll([...seedReels, ...customReels]);
    lines
      ..clear()
      ..addAll([...seedLines, ...customLines]);

    _reelById
      ..clear()
      ..addEntries(reels.map((r) => MapEntry(r.id, r)));
    _lineById
      ..clear()
      ..addEntries(lines.map((l) => MapEntry(l.id, l)));
  }

  Future<void> reload() => load();

  Future<void> addCustomReel(Reel reel) async {
    final db = await AppDb.instance.database;
    await db.insert('custom_reels', reel.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await reload();
  }

  Future<void> addCustomLine(Line line) async {
    final db = await AppDb.instance.database;
    final row = line.toJson()..remove('packing_factor');
    row['packing_factor'] = line.packingFactor;
    await db.insert('custom_lines', row,
        conflictAlgorithm: ConflictAlgorithm.replace);
    await reload();
  }
}
