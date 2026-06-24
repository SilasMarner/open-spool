import '../services/capacity_calculator.dart';

enum ReelType { spinning, conventional }

extension ReelTypeX on ReelType {
  String get label => this == ReelType.spinning ? 'Spinning' : 'Conventional';

  static ReelType fromJson(String v) => switch (v) {
        'spinning' => ReelType.spinning,
        'conventional' => ReelType.conventional,
        _ => throw ArgumentError('Unknown reel type: $v'),
      };

  String get json => this == ReelType.spinning ? 'spinning' : 'conventional';
}

/// A reel, anchored to one published line capacity. The diameter² model derives
/// everything else from [spoolK].
class Reel {
  final String id;
  final String brand;
  final String model;
  final ReelType type;

  /// Diameter (inches) of the line in the published anchor capacity.
  final double anchorDiameterIn;

  /// Yards of that line the reel is rated to hold.
  final double anchorYards;

  /// Human label for the anchor, e.g. "80 lb mono".
  final String anchorLabel;

  final String? source;
  final bool custom;

  const Reel({
    required this.id,
    required this.brand,
    required this.model,
    required this.type,
    required this.anchorDiameterIn,
    required this.anchorYards,
    required this.anchorLabel,
    this.source,
    this.custom = false,
  });

  /// Usable spool volume constant K = anchorYards · anchorDiameter².
  double get spoolK => spoolConstant(
        anchorYards: anchorYards,
        anchorDiameterIn: anchorDiameterIn,
      );

  bool get unverified => source != null && source!.toUpperCase().contains('VERIFY');

  String get displayName => '$brand $model';

  factory Reel.fromJson(Map<String, dynamic> j, {bool custom = false}) => Reel(
        id: j['id'] as String,
        brand: j['brand'] as String,
        model: j['model'] as String,
        type: ReelTypeX.fromJson(j['type'] as String),
        anchorDiameterIn: (j['anchor_diameter_in'] as num).toDouble(),
        anchorYards: (j['anchor_yards'] as num).toDouble(),
        anchorLabel: j['anchor_label'] as String,
        source: j['source'] as String?,
        custom: custom,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand': brand,
        'model': model,
        'type': type.json,
        'anchor_diameter_in': anchorDiameterIn,
        'anchor_yards': anchorYards,
        'anchor_label': anchorLabel,
        'source': source,
      };
}
