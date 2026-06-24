enum SegmentRole { backing, topshot }

extension SegmentRoleX on SegmentRole {
  String get label => this == SegmentRole.backing ? 'Backing' : 'Topshot';
  String get json => this == SegmentRole.backing ? 'backing' : 'topshot';
  static SegmentRole fromJson(String v) =>
      v == 'topshot' ? SegmentRole.topshot : SegmentRole.backing;
}

/// One line in a setup. [fixedYards] is set on the pinned segment of a topshot
/// mix (the other is computed); null means "fill / compute this one".
class LineSegment {
  final String lineId;
  final SegmentRole role;
  final double? fixedYards;

  const LineSegment({
    required this.lineId,
    required this.role,
    this.fixedYards,
  });

  LineSegment copyWith({String? lineId, SegmentRole? role, double? fixedYards}) =>
      LineSegment(
        lineId: lineId ?? this.lineId,
        role: role ?? this.role,
        fixedYards: fixedYards ?? this.fixedYards,
      );

  factory LineSegment.fromJson(Map<String, dynamic> j) => LineSegment(
        lineId: j['line_id'] as String,
        role: SegmentRoleX.fromJson(j['role'] as String),
        fixedYards: (j['fixed_yards'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'line_id': lineId,
        'role': role.json,
        'fixed_yards': fixedYards,
      };
}
