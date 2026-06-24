import 'dart:convert';

import 'line_segment.dart';

/// A saved, named reel setup the user can revisit.
enum LoadoutMode { straight, topshot }

extension LoadoutModeX on LoadoutMode {
  String get json => this == LoadoutMode.straight ? 'straight' : 'topshot';
  static LoadoutMode fromJson(String v) =>
      v == 'topshot' ? LoadoutMode.topshot : LoadoutMode.straight;
}

class Loadout {
  /// sqflite rowid; null until persisted.
  final int? id;
  final String name;
  final String reelId;
  final LoadoutMode mode;
  final List<LineSegment> segments;

  const Loadout({
    this.id,
    required this.name,
    required this.reelId,
    required this.mode,
    required this.segments,
  });

  Loadout copyWith({int? id, String? name, String? reelId, LoadoutMode? mode, List<LineSegment>? segments}) =>
      Loadout(
        id: id ?? this.id,
        name: name ?? this.name,
        reelId: reelId ?? this.reelId,
        mode: mode ?? this.mode,
        segments: segments ?? this.segments,
      );

  factory Loadout.fromRow(Map<String, dynamic> row) => Loadout(
        id: row['id'] as int?,
        name: row['name'] as String,
        reelId: row['reel_id'] as String,
        mode: LoadoutModeX.fromJson(row['mode'] as String),
        segments: (jsonDecode(row['segments'] as String) as List)
            .map((e) => LineSegment.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toRow() => {
        if (id != null) 'id': id,
        'name': name,
        'reel_id': reelId,
        'mode': mode.json,
        'segments': jsonEncode(segments.map((s) => s.toJson()).toList()),
      };
}
