import '../services/unit_converter.dart';

/// Construction of a fishing line. Diameter is what actually drives capacity.
enum LineType { mono, fluoro, braidSolid, braidHollow }

extension LineTypeX on LineType {
  String get label => switch (this) {
        LineType.mono => 'Mono',
        LineType.fluoro => 'Fluorocarbon',
        LineType.braidSolid => 'Braid (solid core)',
        LineType.braidHollow => 'Braid (hollow core)',
      };

  String get shortLabel => switch (this) {
        LineType.mono => 'Mono',
        LineType.fluoro => 'Fluoro',
        LineType.braidSolid => 'Solid braid',
        LineType.braidHollow => 'Hollow braid',
      };

  static LineType fromJson(String v) => switch (v) {
        'mono' => LineType.mono,
        'fluoro' => LineType.fluoro,
        'braid_solid' => LineType.braidSolid,
        'braid_hollow' => LineType.braidHollow,
        _ => throw ArgumentError('Unknown line type: $v'),
      };

  String get json => switch (this) {
        LineType.mono => 'mono',
        LineType.fluoro => 'fluoro',
        LineType.braidSolid => 'braid_solid',
        LineType.braidHollow => 'braid_hollow',
      };
}

class Line {
  final String id;
  final String brand;
  final String product;
  final LineType type;
  final double lbTest;

  /// Diameter in inches — the source of truth for capacity math.
  final double diameterIn;

  /// Effective cross-section scale; <1 packs tighter. Default 1.0.
  final double packingFactor;

  /// Provenance note. `VERIFY` anywhere in here flags an unconfirmed spec.
  final String? source;

  /// True for user-added lines (stored locally, editable/deletable).
  final bool custom;

  const Line({
    required this.id,
    required this.brand,
    required this.product,
    required this.type,
    required this.lbTest,
    required this.diameterIn,
    this.packingFactor = 1.0,
    this.source,
    this.custom = false,
  });

  double get diameterMm => inchesToMm(diameterIn);

  bool get unverified => source != null && source!.toUpperCase().contains('VERIFY');

  String get displayName => '$brand $product';

  /// Accepts either `diameter_in` or `diameter_mm` in JSON and normalizes.
  factory Line.fromJson(Map<String, dynamic> j, {bool custom = false}) {
    final double diaIn;
    if (j['diameter_in'] != null) {
      diaIn = (j['diameter_in'] as num).toDouble();
    } else if (j['diameter_mm'] != null) {
      diaIn = mmToInches((j['diameter_mm'] as num).toDouble());
    } else {
      throw ArgumentError('Line ${j['id']} missing diameter');
    }
    return Line(
      id: j['id'] as String,
      brand: j['brand'] as String,
      product: j['product'] as String,
      type: LineTypeX.fromJson(j['type'] as String),
      lbTest: (j['lb_test'] as num).toDouble(),
      diameterIn: diaIn,
      packingFactor: (j['packing_factor'] as num?)?.toDouble() ?? 1.0,
      source: j['source'] as String?,
      custom: custom,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand': brand,
        'product': product,
        'type': type.json,
        'lb_test': lbTest,
        'diameter_in': diameterIn,
        'packing_factor': packingFactor,
        'source': source,
      };
}
